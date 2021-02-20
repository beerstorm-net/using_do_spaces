import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'blocs/do_spaces/do_spaces_actions.dart';
import 'blocs/do_spaces/do_spaces_bloc.dart';
import 'blocs/simple_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  await Firebase.initializeApp();
  runApp(BlocProvider<DoSpacesBloc>(
    lazy: false,
    create: (context) => DoSpacesBloc(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO Spaces with Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'DO Spaces with Flutter Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _filePicker = ImagePicker();
  DoSpacesActions _doSpacesActions;
  String _status = "";
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    if (_doSpacesActions == null) {
      _doSpacesActions = DoSpacesActions(context: buildContext);
    }

    return BlocListener<DoSpacesBloc, DoSpacesState>(
        listener: (context, state) {
          if (state is MediaUploadedState) {
            setState(() {
              if (state.errorMessage.isEmpty) {
                _status = "Media UPLOADED...";
                _imageUrl = state.mediaUrl;
              } else {
                _status = "Upload FAILED... \n${state.errorMessage}";
                _imageUrl = "";
              }
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("STATUS: $_status"),
                SizedBox(
                  height: 8,
                ),
                if (_imageUrl.isNotEmpty)
                  Container(
                    child: Column(
                      children: [
                        Text("imageUrl: $_imageUrl"),
                        Image.network(_imageUrl),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  child: Text("Pick Image"),
                  onPressed: () => _pickImageThenUpload(),
                ),
              ],
            ),
          ),
        ));
  }

  _pickImageThenUpload() async {
    final PickedFile pickedFile = await _filePicker.getImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    //if (pickedFile == null) return null;
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      Map _mediaMeta = await _doSpacesActions.generateCloudImageUrl(localFile: file);
      print("mediaMeta: $_mediaMeta");

      if (_mediaMeta.containsKey("success")) {
        setState(() {
          _status = "URL generated! Uploading in progress...";
          //_imageUrl = _mediaMeta["downloadUrl"];

          _doSpacesActions.doUploadMedia(_mediaMeta);
          //BlocProvider.of<DoSpacesBloc>(context).add(MediaUploadEvent(_mediaMeta));
        });
      } else {
        setState(() {
          _status = "Error while generating cloud image url!!!";
        });
      }
    }
  }
}

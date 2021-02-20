import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'do_spaces_event.dart';
part 'do_spaces_state.dart';

class DoSpacesBloc extends Bloc<DoSpacesEvent, DoSpacesState> {
  DoSpacesBloc() : super(InitialDoSpacesState());

  @override
  DoSpacesState get initialState => InitialDoSpacesState();

  @override
  Stream<DoSpacesState> mapEventToState(DoSpacesEvent event) async* {
    if (event is MediaUploadEvent) {
      yield* _uploadMediaToCloud(event);
    }
  }

  Stream<DoSpacesState> _uploadMediaToCloud(MediaUploadEvent event) async* {
    print("Uploading for ${event.mediaMeta}");

    String _errorMessage = "";
    try {
      File fileToUpload = event.mediaMeta['file'];

      Map<String, String> uploadHeaders = Map();
      uploadHeaders[HttpHeaders.contentTypeHeader] = event.mediaMeta['uploadHeaders']['Content-Type'];
      uploadHeaders['x-amz-acl'] = event.mediaMeta['uploadHeaders']['x-amz-acl'];

      print("uploadHeaders: $uploadHeaders");

      Uint8List bodyToUpload = fileToUpload.readAsBytesSync();
      var response = await http.put(
        event.mediaMeta['uploadUrl'],
        headers: uploadHeaders,
        body: bodyToUpload,
      );
      print('upload response -> ${response.toString()}');
      if (response.statusCode <= 201) {
        print('Successfully uploaded file to cloud!');

        yield MediaUploadedState(event.mediaMeta['downloadUrl']);
      } else {
        print('Error uploading photo: ${response.statusCode.toString()} | ${response.reasonPhrase}');
        print('Error uploading photo: response -> ${response.toString()}');

        _errorMessage = "Error uploading photo: response -> ${response.toString()}";
      }
    } catch (e) {
      print('Error uploading photo: ${e.toString()}');
      _errorMessage = 'Error uploading photo: ${e.toString()}';
    }

    if (_errorMessage.isNotEmpty) {
      yield MediaUploadedState("", errorMessage: _errorMessage);
    }
  }
}

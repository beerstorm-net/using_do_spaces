import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'do_spaces_bloc.dart';

class DoSpacesActions {
  BuildContext _context;
  DoSpacesActions({@required BuildContext context})
      : assert(context != null),
        _context = context;

  doUploadMedia(Map<dynamic, dynamic> mediaMeta) {
    print('doUploadMedia: $mediaMeta');
    BlocProvider.of<DoSpacesBloc>(_context).add(MediaUploadEvent(mediaMeta));
  }

  Future<Map<dynamic, dynamic>> generateCloudImageUrl({File localFile, String localFileUrl}) async {
    final HttpsCallable generateCloudImageUrl = FirebaseFunctions.instanceFor(region: "europe-west3")
        .httpsCallable("generateCloudImageUrl", options: HttpsCallableOptions(timeout: const Duration(seconds: 30)));

    Map<dynamic, dynamic> mediaMeta = Map();
    try {
      // extract file type from the name/extension
      String imageUrl = localFile != null ? localFile.uri.toString() : localFileUrl;
      String fileExt = imageUrl.substring(imageUrl.lastIndexOf("."));
      final HttpsCallableResult result = await generateCloudImageUrl.call(<String, dynamic>{
        "fileType": fileExt.toLowerCase(),
      });

      mediaMeta = result.data;
      print('imageMeta: ${mediaMeta.toString()}');
      /*
      {
      success: true,
      message: uploadUrl generated,
      uploadUrl: https://BUCKET_NAME.REGION.digitaloceanspaces.com/di...etcetc...,
      uploadHeaders: {x-amz-acl: public-read, Content-Type: image/jpg},
      downloadUrl: https://BUCKET_NAME.REGION.digitaloceanspaces.com/di...
      }
       */

      if (mediaMeta['success']) {
        if (localFile != null) {
          mediaMeta['file'] = localFile;
        } else if (localFileUrl.isNotEmpty) {
          File file;
          try {
            file = File.fromUri(Uri.parse(localFileUrl));
          } catch (ex1) {
            print("Error while loading $localFileUrl | $ex1");
          }
          if (file == null || (!file.existsSync() && localFileUrl.startsWith("file://"))) {
            localFileUrl = localFileUrl.substring(localFileUrl.indexOf("://") + 3);
            file = File.fromUri(Uri.parse(localFileUrl));
          }
          mediaMeta['file'] = file; // File(localFileUrl);
        }
        //doUploadMedia(mediaMeta);
      }
      //} on CloudFunctionsException catch (e) {
    } catch (e) {
      print('caught exception/error');

      print(e.code);
      print(e.message);
      print(e.details);
      print(e);
    }

    return mediaMeta;
  }
}

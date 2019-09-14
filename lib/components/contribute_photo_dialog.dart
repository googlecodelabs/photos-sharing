/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/trip_page.dart';
import 'package:sharing_codelab/util/to_be_implemented.dart';

class ContributePhotoDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContributePhotoDialogState();
}

class _ContributePhotoDialogState extends State<ContributePhotoDialog> {
  File _image;
  String _uploadToken;
  bool _isUploading = false;

  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                _buildUploadButton(context),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Add a description',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      )),
                ),
                Align(
                  child: _buildAddButton(context),
                  alignment: const FractionalOffset(1, 0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  RaisedButton _buildAddButton(BuildContext context) {
    if (_image == null) {
      // No image has been selected yet
      return const RaisedButton(
        child: Text('ADD'),
        onPressed: null,
      );
    }

    if (_uploadToken == null) {
      // Upload has not completed yet
      return const RaisedButton(
        child: Text('Waiting for image upload'),
        onPressed: null,
      );
    }

    // Otherwise, the upload has completed and an upload token is set
    return RaisedButton(
      child: const Text('ADD'),
      onPressed: () => Navigator.pop(
            context,
            ContributePhotoResult(
              _uploadToken,
              descriptionController.text,
            ),
          ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    if (_image != null) {
      // An image has been selected, display it in the dialog
      return Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.file(_image),
              _isUploading ? const LinearProgressIndicator() : Container(),
            ],
          ),
        ),
      );
    }

    // TODO(developer): Implement error display

    // No image has been selected yet
    return Container(
      padding: const EdgeInsets.all(12),
      child: FlatButton.icon(
        onPressed: () => _getImage(context),
        label: const Text('UPLOAD PHOTO'),
        textColor: Colors.green[800],
        icon: const Icon(Icons.file_upload),
      ),
    );
  }

  Future _getImage(BuildContext context) async {
    // codelab step7
    // Use the image_picker package to prompt the user for a photo from their
    // device.
    final File image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    // Store the image that was selected.
    setState(() {
      _image = image;
      _isUploading = true;
    });

    // Make a request to upload the image to Google Photos once it was selected.
    final String uploadToken =
    await ScopedModel.of<PhotosLibraryApiModel>(context)
        .uploadMediaItem(image);

    setState(() {
      // Once the upload process has completed, store the upload token.
      // This token is used together with the description to create the media
      // item later.
      _uploadToken = uploadToken;
      _isUploading = false;
    });
  }
}

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

class ContributePhotoDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContributePhotoDialogState();
}

class _ContributePhotoDialogState extends State<ContributePhotoDialog> {
  File _image;
  String _uploadToken;
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: IntrinsicHeight(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                child: FlatButton.icon(
                  onPressed: () => _getImage(context),
                  label: Text("UPLOAD PHOTO"),
                  textColor: Colors.green,
                  icon: const Icon(Icons.file_upload),
                ),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: 'Add a description',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    )),
              ),
              Align(
                child: RaisedButton(
                  child: Text('ADD'),
                  onPressed: _uploadToken == null
                      ? null
                      : () => Navigator.pop(
                            context,
                            ContributePhotoResult(
                              _uploadToken,
                              descriptionController.text,
                            ),
                          ),
                ),
                alignment: FractionalOffset(1, 0),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _getImage(BuildContext context) async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    print(image);
    setState(() {
      _image = image;
    });

    String uploadToken = await ScopedModel.of<PhotosLibraryApiModel>(context)
        .uploadMediaItem(image);
    setState(() {
      _uploadToken = uploadToken;
    });
  }
}

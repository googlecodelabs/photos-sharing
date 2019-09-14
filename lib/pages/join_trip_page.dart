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

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_response.dart';
import 'package:sharing_codelab/photos_library_api/share_album_response.dart';
import 'package:sharing_codelab/util/to_be_implemented.dart';

class JoinTripPage extends StatefulWidget {
  @override
  _JoinTripPageState createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController shareTokenFormController =
      TextEditingController();

  @override
  void dispose() {
    shareTokenFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: _isLoading
            ? Center(child: const CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: shareTokenFormController,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: 'Paste the share token',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 0,
                      ),
                      child: const Text(
                        'This will join an album in your Google Photos account',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Center(
                      child: RaisedButton(
                        onPressed: () => _joinTrip(context),
                        child: const Text('Join Trip'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _joinTrip(BuildContext context) async {
    // codelab step9
    // Show loading indicator
    setState(() => _isLoading = true);

    // Call the API to join an album with the entered share token
    await ScopedModel.of<PhotosLibraryApiModel>(context)
      .joinSharedAlbum(shareTokenFormController.text);

    // Hide loading indicator
    setState(() => _isLoading = false);

    // Return to the previous screen
    Navigator.pop(context);
  }
}

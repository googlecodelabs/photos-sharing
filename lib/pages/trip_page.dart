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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/contribute_photo_dialog.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';

class TripPage extends StatefulWidget {
  final Future<SearchMediaItemsResponse> searchResponse;
  final Album album;

  const TripPage({Key key, this.searchResponse, this.album}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TripPageState(searchResponse: searchResponse, album: album);
}

class _TripPageState extends State<TripPage> {
  _TripPageState({this.searchResponse, this.album});

  final Album album;
  Future<SearchMediaItemsResponse> searchResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: 370,
            child: Text(
              album.title ?? '[no title]',
              style: TextStyle(
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 254,
            child: FlatButton(
              onPressed: () =>
                  _showShareToken(context, album.shareInfo.shareToken),
              textColor: Colors.green,
              child: const Text('SHARE WITH GOOGLE PHOTOS'),
            ),
          ),
          Container(
            width: 348,
            margin: const EdgeInsets.only(bottom: 32),
            child: PrimaryRaisedButton(
              label: const Text('Contribute'),
              onPressed: () => _contributePhoto(context),
            ),
          ),
          FutureBuilder<SearchMediaItemsResponse>(
            future: searchResponse,
            builder: _buildMediaItemList,
          )
        ],
      ),
    );
  }

  void _showShareToken(BuildContext context, String shareToken) {
    TextEditingController shareTokenController =
        new TextEditingController(text: shareToken);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Use this share token'),
          content: TextField(controller: shareTokenController),
          actions: <Widget>[
            FlatButton(
              child: const Text("Copy and Close"),
              onPressed: () async {
                await ClipboardManager.copyToClipBoard(shareToken);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future _contributePhoto(context) async {
    setState(() {
      searchResponse = showDialog<ContributePhotoResult>(
          context: context,
          builder: (BuildContext context) {
            return ContributePhotoDialog();
          }).then((ContributePhotoResult result) {
        return ScopedModel.of<PhotosLibraryApiModel>(context)
            .addMediaItemToAlbum(
                result.uploadToken, album.id, result.description);
      }).then((BatchCreateMediaItemsResponse lolWot) {
        return ScopedModel.of<PhotosLibraryApiModel>(context)
            .searchMediaItems(album.id);
      });
    });
  }

  Widget _buildMediaItemList(
      BuildContext context, AsyncSnapshot<SearchMediaItemsResponse> snapshot) {
    if (snapshot.hasData) {
      print(snapshot.data.mediaItems);
      if (snapshot.data.mediaItems == null) {
        return Container();
      }

      return Expanded(
        child: ListView.builder(
          itemCount: snapshot.data.mediaItems.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildMediaItem(snapshot.data.mediaItems[index]);
          },
        ),
      );
    }

    if (snapshot.hasError) {
      print(snapshot.error);
      return Container();
    }

    return Center(
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildMediaItem(MediaItem mediaItem) {
    return Column(
      children: <Widget>[
        Center(
          child: CachedNetworkImage(
            imageUrl: '${mediaItem.baseUrl}=w364',
            placeholder: (BuildContext context, String url) =>
                const CircularProgressIndicator(),
            errorWidget: (BuildContext context, String url, Object error) {
              print(error);
              return const Icon(Icons.error);
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 2),
          width: 364,
          child: Text(
            mediaItem.description ?? '',
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class ContributePhotoResult {
  ContributePhotoResult(this.uploadToken, this.description);

  String uploadToken;
  String description;
}

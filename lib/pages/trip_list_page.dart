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
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/create_trip_page.dart';
import 'package:sharing_codelab/pages/join_trip_page.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/components/trip_app_bar.dart';
import 'package:sharing_codelab/pages/trip_page.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';

class TripListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TripAppBar(),
      body: _buildTripList(),
    );
  }

  Widget _buildTripList() {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (BuildContext context, Widget child,
          PhotosLibraryApiModel photosLibraryApi) {
        if (!photosLibraryApi.hasSharedAlbums) {
          return Center(
            child: const CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: photosLibraryApi.sharedAlbums.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _buildButtons(context);
            }

            return _buildTripCard(context,
                photosLibraryApi.sharedAlbums[index - 1], photosLibraryApi);
          },
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Album sharedAlbum,
      PhotosLibraryApiModel photosLibraryApi) {
    final String url = sharedAlbum.coverPhotoBaseUrl ?? 'blah';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 33,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => TripPage(
                      album: sharedAlbum,
                      searchResponse:
                          photosLibraryApi.searchMediaItems(sharedAlbum.id),
                    ),
              ),
            ),
        child: Column(
          children: <Widget>[
            Container(
              child: _buildTripThumbnail(sharedAlbum),
            ),
            Container(
              height: 52,
              padding: const EdgeInsets.only(left: 14),
              child: Align(
                alignment: const FractionalOffset(0, 0.5),
                child: Text(
                  sharedAlbum.title ?? '[no title]',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripThumbnail(Album sharedAlbum) {
    if (sharedAlbum.coverPhotoBaseUrl == null) {
      return Container(
        child: Center(child: const Text('FIX ME WITH PLACEHOLDER')),
        height: 160,
        width: 346,
        color: Colors.black12,
      );
    }

    return CachedNetworkImage(
      imageUrl: '${sharedAlbum.coverPhotoBaseUrl}=w346-h160-c',
      placeholder: (BuildContext context, String url) =>
          const CircularProgressIndicator(),
      errorWidget: (BuildContext context, String url, Object error) {
        print(error);
        return const Icon(Icons.error);
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment(0, 0.9),
        colors: [
          Color(0x44000000),
          Color(0x22ffffff),
        ],
      )),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          PrimaryRaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => CreateTripPage(),
                ),
              );
            },
            label: const Text('CREATE A TRIP ALBUM'),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              ' - or - ',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FlatButton(
            textColor: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => JoinTripPage(),
                ),
              );
            },
            child: const Text('JOIN A TRIP ALBUM'),
          ),
        ],
      ),
    );
  }
}

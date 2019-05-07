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

import 'dart:collection';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/create_album_request.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_request.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_response.dart';
import 'package:sharing_codelab/photos_library_api/list_shared_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/photos_library_api_client.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/share_album_request.dart';
import 'package:sharing_codelab/photos_library_api/share_album_response.dart';

class PhotosLibraryApiModel extends Model {
  PhotosLibraryApiModel() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;
      notifyListeners();
    });
  }

  List<Album> _sharedAlbums = <Album>[];
  bool hasSharedAlbums = false;
  PhotosLibraryApiClient client;

  GoogleSignInAccount _currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/photoslibrary',
    'https://www.googleapis.com/auth/photoslibrary.sharing'
  ]);
  GoogleSignInAccount get user => _currentUser;

  bool isLoggedIn() {
    return _currentUser != null;
  }

  Future<void> signIn() async {
    await _googleSignIn.signIn();
    client = PhotosLibraryApiClient(_currentUser.authHeaders);
    updateSharedAlbums();
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    client = null;
  }

  Future<void> signInSilently() async {
    await _googleSignIn.signInSilently();
    client = PhotosLibraryApiClient(_currentUser.authHeaders);
    updateSharedAlbums();
  }

  Future<Album> createAlbum(String title) async {
    return client
        .createAlbum(CreateAlbumRequest.fromTitle(title))
        .then((Album album) {
      return album;
    });
  }

  Future<JoinSharedAlbumResponse> joinSharedAlbum(String shareToken) {
    return client
        .joinSharedAlbum(JoinSharedAlbumRequest(shareToken))
        .then((JoinSharedAlbumResponse response) {
      updateSharedAlbums();
      return response;
    });
  }

  Future<ShareAlbumResponse> shareAlbum(String id) async {
    return client
        .shareAlbum(ShareAlbumRequest.defaultOptions(id))
        .then((ShareAlbumResponse response) {
      updateSharedAlbums();
      return response;
    });
  }

  Future<SearchMediaItemsResponse> searchMediaItems(String albumId) async {
    return client
        .searchMediaItems(SearchMediaItemsRequest.albumId(albumId))
        .then((SearchMediaItemsResponse response) {
      return response;
    });
  }

  Future<String> uploadMediaItem(File image) {
    return client.uploadMediaItem(image);
  }

  Future<BatchCreateMediaItemsResponse> addMediaItemToAlbum(
      String uploadToken, String albumId, String description) {
    return client
        .batchCreateMediaItems(BatchCreateMediaItemsRequest.inAlbum(
            uploadToken, albumId, description))
        .then((BatchCreateMediaItemsResponse response) {
      print(response.newMediaItemResults[0].toJson());
      return response;
    });
  }

  UnmodifiableListView<Album> get sharedAlbums =>
      UnmodifiableListView<Album>(_sharedAlbums ?? <Album>[]);

  void updateSharedAlbums() {
    hasSharedAlbums = false;
    client.listSharedAlbums().then(
      (ListSharedAlbumsResponse response) {
        _sharedAlbums = response.sharedAlbums;
        notifyListeners();
        hasSharedAlbums = true;
      },
    );
  }
}

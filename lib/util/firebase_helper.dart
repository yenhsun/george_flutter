import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUser {
  // singleton start
  factory FirebaseUser() => _getInstance();

  static FirebaseUser get instance => _getInstance();
  static FirebaseUser _instance;

  FirebaseUser._internal() {
    debugPrint("init FirebaseUser");
  }

  static FirebaseUser _getInstance() {
    if (_instance == null) {
      _instance = new FirebaseUser._internal();
    }
    return _instance;
  }

  // singleton finish

  AuthData _authData;

  DocumentReference _userDocumentReference;

  void setAuthData(AuthData data) {
    debugPrint("setAuthData");
    _authData = data;
  }

  Observable<void> updateUser() {
    debugPrint("updateUser self: ${identityHashCode(this)}");
    debugPrint("updateUser authData: $_authData");
    var map = Map<String, String>();
    map[FireStoreConstants.usersEmail] = _authData.googleSignInAccount.email;
    map[FireStoreConstants.usersDisplayName] =
        _authData.googleSignInAccount.displayName;
    map[FireStoreConstants.usersPhotoUrl] =
        _authData.googleSignInAccount.photoUrl;

    _userDocumentReference = Firestore.instance
        .collection(FireStoreConstants.collectionUsers)
        .document(_authData.googleSignInAccount.id);

    return Observable.fromFuture(
            _userDocumentReference.setData(map, merge: true))
        .doOnDone(() {
      Fimber.i("update user done");
    });
  }

  Observable<List<FavoriteList>> getFavoriteList() {
    return Observable.fromFuture(_userDocumentReference
            .collection(FireStoreConstants.collectionFavoriteList)
            .getDocuments())
        .flatMap((userCollectionFavoriteList) {
      return Observable.fromFuture(Firestore.instance
              .collection(FireStoreConstants.collectionFavoriteList)
              .getDocuments())
          .map((favoriteListCollectionSnapshot) {
        var rtn = List<DocumentSnapshot>();
        userCollectionFavoriteList.documents.forEach((userFavoriteListItem) {
          favoriteListCollectionSnapshot.documents.forEach((favoriteListItem) {
            if (userFavoriteListItem.documentID ==
                favoriteListItem.documentID) {
              rtn.add(favoriteListItem);
            }
          });
        });
        return rtn;
      }).map((documentSnapshotList) {
        var rtn = List<FavoriteList>();
        documentSnapshotList.forEach((snapshot) {
          rtn.add(FavoriteList(snapshot));
        });
        return rtn;
      });
    });
  }

  Observable<void> addNewFavoriteList(String name) {
    debugPrint("addNewFavoriteList self: ${identityHashCode(this)}");
    var map = Map<String, String>();
    map[FireStoreConstants.favoriteListName] = name;
    map[FireStoreConstants.favoriteListCreateTime] =
        DateTime.now().millisecondsSinceEpoch.toString();
    map[FireStoreConstants.favoriteListCreateBy] = _authData.googleSignInAccount.displayName;

    final documentReference = Firestore.instance
        .collection(FireStoreConstants.collectionFavoriteList)
        .document();

    final list = List<Observable>();
    list.add(Observable.fromFuture(Firestore.instance
        .collection(FireStoreConstants.collectionUsers)
        .document(_authData.googleSignInAccount.id)
        .collection(FireStoreConstants.collectionFavoriteList)
        .document(documentReference.documentID)
        .setData(Map())));

    list.add(Observable.fromFuture(documentReference.setData(map)));

    return Observable.merge(list);
  }
}

class FavoriteList {
  final DocumentSnapshot snapshot;

  FavoriteList(this.snapshot);
}

class FireStoreConstants {
  static final String collectionUsers = "users";
  static final String usersEmail = "email";
  static final String usersDisplayName = "displayName";
  static final String usersPhotoUrl = "photoUrl";

  static final String collectionFavoriteList = "list_favorite";
  static final String favoriteListName = "name";
  static final String favoriteListCreateTime = "create_time";
  static final String favoriteListCreateBy = "create_by";
}

class AuthData {
  final GoogleSignInAccount googleSignInAccount;
  final GoogleSignInAuthentication googleSignInAuthentication;

  AuthData(this.googleSignInAccount, this.googleSignInAuthentication);
}

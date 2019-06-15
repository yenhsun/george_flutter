import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUser {
  // singleton start
  static final FirebaseUser _singleton = new FirebaseUser._internal();

  factory FirebaseUser() {
    return _singleton;
  }

  FirebaseUser._internal();

  // singleton finish

  AuthData authData;

  Observable<void> updateUser() {
    var map = Map<String, String>();
    map[FireStoreConstants.usersEmail] = authData.googleSignInAccount.email;
    map[FireStoreConstants.usersDisplayName] = authData.googleSignInAccount.displayName;
    map[FireStoreConstants.usersPhotoUrl] = authData.googleSignInAccount.photoUrl;

    return Observable.fromFuture(Firestore.instance
            .collection(FireStoreConstants.collectionUsers)
            .document(authData.googleSignInAccount.id)
            .setData(map, merge: true))
        .doOnDone(() {
      Fimber.i("update user done");
    });
  }
}

class FireStoreConstants {
  static final String collectionUsers = "users";
  static final String usersEmail = "email";
  static final String usersDisplayName = "displayName";
  static final String usersPhotoUrl = "photoUrl";
}

class AuthData {
  GoogleSignInAccount googleSignInAccount;
  GoogleSignInAuthentication googleSignInAuthentication;

  AuthData(GoogleSignInAccount googleSignInAccount,
      GoogleSignInAuthentication googleSignInAuthentication)
      : this.googleSignInAccount = googleSignInAccount,
        this.googleSignInAuthentication = googleSignInAuthentication;
}

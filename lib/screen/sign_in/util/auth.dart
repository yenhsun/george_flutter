import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/util/firebase_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class Auth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseUser _firebaseUser = FirebaseUser();

  Observable<bool> isSignIn() {
    return Observable.fromFuture(_googleSignIn.isSignedIn());
  }

  Observable<AuthData> signIn() {
    return Observable.fromFuture(_googleSignIn.signIn())
        .concatMap((GoogleSignInAccount account) {
      return Observable.fromFuture(account.authentication)
          .map((GoogleSignInAuthentication auth) {
        return AuthData(account, auth);
      }).doOnEach((notification) {
        if (notification.error == null) {
          Fimber.d("update authData");
          _firebaseUser.authData = notification.value;
        }
      }).concatMap((authData) {
        return _firebaseUser.updateUser().map((dynamic) {
          return authData;
        });
      });
    });
  }

  Observable<GoogleSignInAccount> signOut() {
    return Observable.fromFuture(_googleSignIn.signOut());
  }
}

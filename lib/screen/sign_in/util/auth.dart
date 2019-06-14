import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthData {
  GoogleSignInAccount googleSignInAccount;
  GoogleSignInAuthentication googleSignInAuthentication;

  AuthData(GoogleSignInAccount googleSignInAccount,
      GoogleSignInAuthentication googleSignInAuthentication)
      : this.googleSignInAccount = googleSignInAccount,
        this.googleSignInAuthentication = googleSignInAuthentication;
}

class Auth {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  Observable<bool> isSignIn() {
    return Observable.fromFuture(_googleSignIn.isSignedIn());
  }

  Observable<AuthData> signIn() {
    return Observable.fromFuture(_googleSignIn.signIn())
        .concatMap((GoogleSignInAccount account) {
      return Observable.fromFuture(account.authentication)
          .map((GoogleSignInAuthentication auth) {
            final rtn = AuthData(account, auth);
            debugPrint("AuthData: $rtn");
        return rtn;
      });
    });
  }

  Observable<GoogleSignInAccount> signOut() {
    return Observable.fromFuture(_googleSignIn.signOut());
  }
}

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  Auth({
    @required this.googleSignIn,
    @required this.firebaseAuth,
  });

  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    debugPrint("googleAccount: $googleAccount");
    final GoogleSignInAuthentication googleAuth =
    await googleAccount.authentication;
    debugPrint("googleAuth: $googleAuth");
    return firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }
}

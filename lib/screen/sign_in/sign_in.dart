import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toast/toast.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: Center(child: GoogleSignInButton2()),
    );
  }
}

class GoogleSignInButton2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignInState();
  }
}

class SignInState extends State<GoogleSignInButton2> {
  final auth =
  Auth(firebaseAuth: FirebaseAuth.instance, googleSignIn: GoogleSignIn());

  Future<FirebaseUser> firebaseUser;

  void _signIn() {
    setState(() {
      firebaseUser = auth.signInWithGoogle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseUser,
      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.displayName.isNotEmpty) {
            Toast.show("Hiiii ${snapshot.data.displayName}", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            return Text("QQQQ");
          } else {
            Toast.show("Failed to get user display name", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            return Text("22222");
          }
        } else {
          return RaisedButton(
            textColor: Colors.white,
            color: Color.fromARGB(0xff, 0x42, 0x85, 0xF4),
            padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Image.asset(
                  'assets/ic_google_white_24dp.png',
                ),
                Padding(padding: EdgeInsets.fromLTRB(2, 0, 6, 0)),
                Text(
                  'Sign in with Google',
                  textAlign: TextAlign.center,
                )
              ],
            ),
            onPressed: () {
              _signIn();
            },
          );
        }
      },
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final auth =
  Auth(firebaseAuth: FirebaseAuth.instance, googleSignIn: GoogleSignIn());

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      textColor: Colors.white,
      color: Color.fromARGB(0xff, 0x42, 0x85, 0xF4),
      padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Image.asset(
            'assets/ic_google_white_24dp.png',
          ),
          Padding(padding: EdgeInsets.fromLTRB(2, 0, 6, 0)),
          Text(
            'Sign in with Google',
            textAlign: TextAlign.center,
          )
        ],
      ),
      onPressed: () {
        auth.signInWithGoogle().then((FirebaseUser user) {
          if (user.displayName.isNotEmpty) {
            Toast.show("Hi ${user.displayName}", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        }).catchError((error) {
          debugPrint('error: $error');
        });
      },
    );
  }
}

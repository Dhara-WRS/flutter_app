import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:epics_pj/view/widgets/showMessage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  get user => _auth.currentUser;
  FirebaseAuth getAuth() {
    return _auth;
  }

  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      return e.message;
    }
  }

  Future<String?> pwdReset({required email, required context}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).then((value) {
        Navigator.pop(context);
        showMessage("Password reset link has been sent.", context);
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    log("signing in with google");
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    log("googleUser");

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    log('error:${googleAuth!.accessToken}');

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // Future<UserCredential> signInWithFacebook() async {
  //   // Trigger the sign-in flow
  //   final LoginResult loginResult =
  //       await FacebookAuth.instance.login(permissions: ['email']);
  //   log(loginResult.status.toString());
  //   // Create a credential from the access token
  //   final OAuthCredential facebookAuthCredential =
  //       FacebookAuthProvider.credential(loginResult.accessToken!.token);

  //   var userData = await FacebookAuth.instance.getUserData();
  //   var userEmail = userData['email'];
  //   print("userEmail");
  //   // Once signed in, return the UserCredential
  //   return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  // }

  //SIGN OUT METHOD
  Future<void> signOut() async {
    // await FacebookAuth.instance.logOut();
    await _googleSignIn.signOut();
    await _auth.signOut();
    print('User Signed Out!');
  }
}

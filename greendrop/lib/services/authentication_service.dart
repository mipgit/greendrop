import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService with ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get displayName => _auth.currentUser?.displayName;
  String? get email => _auth.currentUser?.email;

  AuthenticationService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn() {

    print('AuthenticationService initialized');
    _auth.authStateChanges().listen((User? user) {
      print('authStateChanges triggered: user = $user');
      if (user != null) {
        _currentUser = _googleSignIn.currentUser;
        print('User signed in: $_currentUser');
      } else {
        _currentUser = null;
        print('User signed out');
      }
      notifyListeners();
    });
  }

  Future<void> signIn() async {
    try {
      print('Attempting Google sign-in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in canceled by user');
        return;
      }

      print('Google sign-in successful: $googleUser');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google authentication retrieved: accessToken = ${googleAuth.accessToken}, idToken = ${googleAuth.idToken}');

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with credential...');
      await _auth.signInWithCredential(credential);

      _currentUser = googleUser;
      print('Sign-in successful: $_currentUser');
      notifyListeners();
    } catch (error) {
      print('Error during sign-in: $error');
    }
  }

  Future<void> signOut() async {
    try {
      print('Signing out...');
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      print('Sign-out successful');
      notifyListeners();
    } catch (error) {
      print('Error during sign-out: $error');
    }
  }
}
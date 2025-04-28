import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService with ChangeNotifier {
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;
  bool _isGuest = false;

  GoogleSignInAccount? get currentUser => _currentUser;
  String? get displayName => _auth.currentUser?.displayName;
  String? get email => _auth.currentUser?.email;
  bool get isGuest => _isGuest;



  AuthenticationService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn() {
    print('AuthenticationService initialized');
    _listenToAuthChanges(); 
  }


  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((User? user) {
      print('authStateChanges triggered: user = $user');
      _updateCurrentUser(user);
      _updateIsGuest(user);
      notifyListeners();
    });

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      print('Google onCurrentUserChanged triggered: account = $account');
      _currentUser = account;
      notifyListeners();
      if (account != null && _auth.currentUser != null) {
        _reauthenticateWithGoogle(account);
      }
    });

    _googleSignIn.signInSilently(); 
  }

  void _updateIsGuest(User? user) {
    _isGuest = user?.isAnonymous ?? false;
  }



  Future<void> _reauthenticateWithGoogle(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      print('Firebase re-authenticated with Google.');
    } catch (e) {
      print('Error re-authenticating with Google: $e');
    }
  }



  void _updateCurrentUser(User? firebaseUser) async {
    if (firebaseUser != null && _googleSignIn.currentUser == null) {
      _currentUser = await _googleSignIn.signInSilently();
      notifyListeners();
    } else if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
    } else if (_googleSignIn.currentUser != null && _googleSignIn.currentUser?.id != firebaseUser.uid) {
      print('Warning: Firebase user ID does not match Google user ID.');
      _currentUser = _googleSignIn.currentUser;
      notifyListeners();
    } else if (_googleSignIn.currentUser != null) {
      _currentUser = _googleSignIn.currentUser;
      notifyListeners();
    }
  }



  Future<void> signInAnonymously() async {
    try {
      print('Attempting anonymous/guest sign-in...');
      await _auth.signInAnonymously();
      print('Anonymous sign-in successful. User UID: ${_auth.currentUser?.uid}');
    } catch (e) {
      print('Error during anonymous sign-in: $e');
    }
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
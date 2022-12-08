import 'dart:async';

import 'package:chat_app/data/models/user_chat_model.dart';
import 'package:chat_app/utils/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _preferences;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required GoogleSignIn googleSignIn,
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences preferences,
  })  : _googleSignIn = googleSignIn,
        _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _preferences = preferences;

  // Get UserFirebaseId from Storage
  String? getUserFirebaseId() {
    return _preferences.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLogged = await _googleSignIn.isSignedIn();
    if (isLogged && getUserFirebaseId()?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    // STATUS IN PROGRESS
    notify(Status.authenticating);

    // GOOGLE SIGN IN
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await _firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        // GET USER INFO IN FIRESTORE
        final QuerySnapshot result = await _firestore.collection(FirestoreConstants.pathUserCollection).where(FirestoreConstants.id, isEqualTo: firebaseUser.uid).get();

        final List<DocumentSnapshot> documents = result.docs;

        // IF USER INFO IS NOT EXIST IN FIRESTORE (SAVE INFO IN LOCALE AND FIRESTORE)
        if (documents.isEmpty) {
          // SAVE TO FIRESTORE
          _firestore.collection(FirestoreConstants.pathUserCollection).doc(firebaseUser.uid).set({
            FirestoreConstants.id: firebaseUser.uid,
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          // SAVE TO LOCALE STORAGE

          await _preferences.setString(FirestoreConstants.id, firebaseUser.uid);
          await _preferences.setString(FirestoreConstants.nickname, firebaseUser.displayName ?? "");
          await _preferences.setString(FirestoreConstants.photoUrl, firebaseUser.photoURL ?? "");
          
        } else {
          // IF USER INFO IS EXIST IN FIRESTORE (SAVE INFO ONLY LOCALE)
          DocumentSnapshot documentSnapshot = documents[0];

          UserChatModel currentUser = UserChatModel.fromDocument(documentSnapshot.data() as Map<String, dynamic>);

          await _preferences.setString(FirestoreConstants.id, currentUser.id);
          await _preferences.setString(FirestoreConstants.nickname, currentUser.nickname);
          await _preferences.setString(FirestoreConstants.photoUrl, currentUser.photoUrl);
          await _preferences.setString(FirestoreConstants.aboutMe, currentUser.aboutMe);
          await _preferences.setString(FirestoreConstants.phoneNumber, currentUser.phoneNumber);
          await _preferences.setString(FirestoreConstants.dialCode, currentUser.dialCode);
        }

        notify(Status.authenticated);
        return true;
      } else {
        notify(Status.authenticateError);
        return false;
      }
    } else {
      notify(Status.authenticateCanceled);
      return false;
    }
  }

  // SIGN OUT USER FROM APP
  Future<void> handleSignOut() async {
    notify(Status.uninitialized);

    await _firebaseAuth.signOut();

    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
  }

  // SET STATE
  void notify(Status status) {
    _status = status;
    notifyListeners();
  }
}

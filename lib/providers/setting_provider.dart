import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider {
  final FirebaseFirestore _firestore;
  final SharedPreferences _preferences;
  final FirebaseStorage _firebaseStorage;

  SettingProvider({
    required FirebaseFirestore firestore,
    required SharedPreferences preferences,
    required FirebaseStorage firebaseStorage,
  })  : _firestore = firestore,
        _preferences = preferences,
        _firebaseStorage = firebaseStorage;

  String? getPref(String key) {
    return _preferences.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = _firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, dynamic> dataNeedUpdate) {
    return _firestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }
}

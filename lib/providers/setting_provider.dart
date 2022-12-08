import 'dart:io';

import 'package:chat_app/data/models/user_chat_model.dart';
import 'package:chat_app/utils/const.dart';
import 'package:chat_app/utils/my_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider extends ChangeNotifier {
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

  // ===============================================================

  UserChatModel user = UserChatModel(id: '', photoUrl: '', nickname: '', aboutMe: '', phoneNumber: '', dialCode: '');
  bool isLoading = false;
  File? avatarImageFile;

  String? getPref(String key) {
    return _preferences.getString(key);
  }

  Future<bool> setPref(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  UploadTask uploadFileinFireStorage(File image, String fileName) {
    Reference reference = _firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(
    String collectionPath,
    String path,
    Map<String, dynamic> dataNeedUpdate,
  ) {
    return _firestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  readLocal() {
    user = user.copyWith(
      id: getPref(FirestoreConstants.id) ?? '',
      aboutMe: getPref(FirestoreConstants.aboutMe) ?? '',
      nickname: getPref(FirestoreConstants.nickname) ?? '',
      phoneNumber: getPref(FirestoreConstants.phoneNumber) ?? '',
      photoUrl: getPref(FirestoreConstants.photoUrl) ?? '',
      dialCode: getPref(FirestoreConstants.dialCode) ?? '',
    );
  }

  Future<void> getImage(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery).catchError((err) {
      CustomSnackbar.showSnackbar(context, err.toString(), SnackbarType.error);
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      avatarImageFile = image;
      notify(true);
      uploadFile(context);
    }
  }

  Future<void> uploadFile(BuildContext context) async {
    UploadTask uploadTask = uploadFileinFireStorage(avatarImageFile!, user.id);

    try {
      // UPLOAD FILE
      TaskSnapshot snapshot = await uploadTask;
      // GET URL OF DOWNLOAD FILE
      user.photoUrl = await snapshot.ref.getDownloadURL();

      // UPDATE PHOTOURL IN FIRESTORE
      updateDataFirestore(FirestoreConstants.pathUserCollection, user.id, {FirestoreConstants.photoUrl: user.photoUrl}).then((data) async {
        await setPref(
          FirestoreConstants.photoUrl,
          user.photoUrl,
        );
        notify(false);
      }).catchError((err) {
        notify(false);
        CustomSnackbar.showSnackbar(context, err.toString(), SnackbarType.error);
      });
    } on FirebaseException catch (err) {
      notify(false);
      CustomSnackbar.showSnackbar(context, err.message ?? err.toString(), SnackbarType.error);
    }
  }

  Future<void> updateUser(BuildContext context, UserChatModel newUser) async {
    notify(true);

    updateDataFirestore(FirestoreConstants.pathUserCollection, user.id, newUser.toJson()).then((data) async {
      await setPref(FirestoreConstants.nickname, newUser.nickname);
      await setPref(FirestoreConstants.aboutMe, newUser.aboutMe);
      await setPref(FirestoreConstants.phoneNumber, newUser.phoneNumber);
      await setPref(FirestoreConstants.dialCode, newUser.dialCode);

      notify(false);

      CustomSnackbar.showSnackbar(context, 'Update success', SnackbarType.success);
    }).catchError((err) {

      notify(false);

      CustomSnackbar.showSnackbar(context, err.toString(), SnackbarType.error);

    });
  }

  void notify(bool status) {
    debugPrint(">>>>>>>>>>>>>>> STATUS: $status <<<<<<<<<<<<<<<");
    isLoading = status;
    notifyListeners();
  }
  
}

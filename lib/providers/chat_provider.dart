import 'dart:io';

import 'package:chat_app/data/models/message_chat_model.dart';
import 'package:chat_app/utils/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences _pref;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  ChatProvider({
    required SharedPreferences preferences,
    required FirebaseStorage storage,
    required FirebaseFirestore firestore,
  })  : _pref = preferences,
        _storage = storage,
        _firestore = firestore;

  UploadTask uploadFile(File image, String fileName) {
    Reference ref = _storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdata) {
    return _firestore.collection(collectionPath).doc(docPath).update(dataNeedUpdata);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return _firestore.collection(FirestoreConstants.pathMessageCollection).doc(groupChatId).collection(groupChatId).orderBy(FirestoreConstants.timestamp, descending: true).limit(limit).snapshots();
  }

  void sendMessage(String content, int type, String groupChatId, String currentUserId, String peerId) {
    DocumentReference documentReference =
        _firestore.collection(FirestoreConstants.pathMessageCollection).doc(groupChatId).collection(groupChatId).doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChatModel messageChatModel = MessageChatModel(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChatModel.toJson(),
      );
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}

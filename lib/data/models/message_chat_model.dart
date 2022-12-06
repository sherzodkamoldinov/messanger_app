import 'package:chat_app/utils/const.dart';

class MessageChatModel {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;

  MessageChatModel({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type,
    };
  }

  factory MessageChatModel.fromDocument(Map<String, dynamic> doc) {
    return MessageChatModel(
      idFrom: (doc[FirestoreConstants.idFrom] as String?) ?? "",
      idTo: (doc[FirestoreConstants.idTo] as String?) ?? "",
      timestamp: (doc[FirestoreConstants.timestamp] as String?) ?? "",
      content: (doc[FirestoreConstants.content] as String?) ?? "",
      type: (doc[FirestoreConstants.type] as int?) ?? 0,
    );
  }
}

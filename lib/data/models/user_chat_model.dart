import 'package:chat_app/utils/const.dart';

class UserChatModel {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  String phoneNumber;
  String dialCode;

  UserChatModel({
    required this.id,
    required this.photoUrl,
    required this.nickname,
    required this.aboutMe,
    required this.phoneNumber,
    required this.dialCode,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.phoneNumber: phoneNumber,
      FirestoreConstants.dialCode: dialCode,
    };
  }

  factory UserChatModel.fromDocument(Map<String, dynamic> data) {
    return UserChatModel(
      id: (data[FirestoreConstants.id] as String?) ?? "",
      photoUrl: (data[FirestoreConstants.photoUrl] as String?) ?? "",
      nickname: (data[FirestoreConstants.nickname] as String?) ?? "",
      aboutMe: (data[FirestoreConstants.aboutMe] as String?) ?? "",
      phoneNumber: (data[FirestoreConstants.phoneNumber] as String?) ?? "",
      dialCode: (data[FirestoreConstants.dialCode] as String?) ?? "",
    );
  }

  UserChatModel copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? aboutMe,
    String? phoneNumber,
    String? dialCode,
  }) {
    return UserChatModel(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      nickname: nickname ?? this.nickname,
      aboutMe: aboutMe ?? this.aboutMe,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dialCode: dialCode ?? this.dialCode,
    );
  }
}

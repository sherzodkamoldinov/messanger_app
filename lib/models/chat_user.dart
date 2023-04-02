class ChatUserModel {
  ChatUserModel({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });
  final String image;
  final String about;
  final String name;
  final String createdAt;
  final bool isOnline;
  final String id;
  final String lastActive;
  final String email;
  final String pushToken;

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      image: json['image'] as String? ?? "",
      about: json['about'] as String? ?? "",
      name: json['name'] as String? ?? "",
      createdAt: json['created_at'] as String? ?? "",
      isOnline: json['is_online'] as bool? ?? false,
      id: json['id'] as String? ?? "",
      lastActive: json['last_active'] as String? ?? "",
      email: json['email'] as String? ?? "",
      pushToken: json['push_token'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'about': about,
        'name': name,
        'created_at': createdAt,
        'is_online': isOnline,
        'id': id,
        'last_active': lastActive,
        'email': email,
        'push_token': pushToken,
      };
}

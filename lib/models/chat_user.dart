class ChatUserModel {
  ChatUserModel({
    this.image = '',
    this.about = '',
    this.name = '',
    this.createdAt = '',
    this.isOnline = false,
    this.id = '',
    this.lastActive = '',
    this.email = '',
    this.pushToken = '',
  });
  String image;
  String about;
  String name;
  String createdAt;
  bool isOnline;
  String id;
  String lastActive;
  String email;
  String pushToken;

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

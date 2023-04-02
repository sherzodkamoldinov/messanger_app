import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messanger_app/models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({Key? key, required this.user, }) : super(key: key);
  final ChatUserModel user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.purpleAccent,
      child: GestureDetector(
        onTap: () {},
        child: ListTile(
          leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing: const Text(
            '12:00 PM',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

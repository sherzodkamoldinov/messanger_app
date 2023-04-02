import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messanger_app/models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({
    Key? key,
    required this.user,
  }) : super(key: key);
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
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.height * 0.055,
              height: MediaQuery.of(context).size.height * 0.055,
              imageUrl: widget.user.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(CupertinoIcons.person),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // trailing: const Text(
          //   '12:00 PM',
          //   style: TextStyle(color: Colors.black54),
          // ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messanger_app/api/apis.dart';
import 'package:messanger_app/models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.user}) : super(key: key);
  final ChatUserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.white,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              )),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(width: double.infinity, height: 20),

              // user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.height * 0.2,
                  height: MediaQuery.of(context).size.height * 0.2,
                  fit: BoxFit.fill,
                  imageUrl: widget.user.image,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(CupertinoIcons.person),
                ),
              ),

              const SizedBox(height: 20),
              Text(widget.user.email, style: const TextStyle(color: Colors.black54, fontSize: 16)),

              const SizedBox(height: 10),
              // user name
              TextFormField(
                initialValue: widget.user.name,
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'eg. Your Name',
                    label: const Text('Name')),
              ),

              const SizedBox(height: 20),
              // about user
              TextFormField(
                initialValue: widget.user.about,
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.info,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'eg. Feeling Happy',
                    label: const Text('About')),
              ),

              const SizedBox(height: 20),

              // update profile info
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.tips_and_updates_outlined,
                    size: 28,
                  ),
                  label: const Text('UPDATE', style: TextStyle(fontSize: 16),),
                ),
              )
            ],
          ),
        ));
  }
}

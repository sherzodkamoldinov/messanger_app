import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messanger_app/api/apis.dart';
import 'package:messanger_app/helper/dialogs.dart';
import 'package:messanger_app/models/chat_user.dart';
import 'package:messanger_app/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.user}) : super(key: key);
  final ChatUserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await APIs.auth.signOut().then(
                  (value) async {
                    await GoogleSignIn().signOut().then(
                      (value) {
                        // for hiding progress dialog
                        Navigator.pop(context);

                        // for hiding home screen
                        Navigator.pop(context);

                        // replacing home screen with login screen
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                    );
                  },
                );
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
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(width: double.infinity, height: 20),

                  // user profile picture
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // user image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: _image != null
                            ? Image.file(
                                File(_image!),
                                width: MediaQuery.of(context).size.height * 0.2,
                                height: MediaQuery.of(context).size.height * 0.2,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                width: MediaQuery.of(context).size.height * 0.2,
                                height: MediaQuery.of(context).size.height * 0.2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(CupertinoIcons.person),
                              ),
                      ),
                      // user image edit
                      Positioned(
                        bottom: -7,
                        right: -7,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(widget.user.email, style: const TextStyle(color: Colors.black54, fontSize: 16)),

                  const SizedBox(height: 10),
                  // user name
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
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
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(context, 'Profile Update Successfully!');
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.tips_and_updates_outlined,
                        size: 28,
                      ),
                      label: const Text(
                        'UPDATE',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            const Text(
              'Pick Profile Picture',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      debugPrint(image.path);
                      _image = image.path;
                      setState(() {});
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, shape: const CircleBorder(), fixedSize: Size(MediaQuery.of(context).size.width * .3, MediaQuery.of(context).size.height * .15)),
                  child: Image.asset(
                    'assets/icons/add_image.png',
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(width: 25),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, shape: const CircleBorder(), fixedSize: Size(MediaQuery.of(context).size.width * .3, MediaQuery.of(context).size.height * .15)),
                  child: Image.asset(
                    'assets/icons/camera.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

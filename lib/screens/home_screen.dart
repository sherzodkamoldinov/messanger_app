import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messanger_app/api/apis.dart';
import 'package:messanger_app/models/chat_user.dart';
import 'package:messanger_app/screens/profile_screen.dart';
import 'package:messanger_app/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUserModel> data = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text('Messenger App'),
        actions: [
          // search user button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          // more features button
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  ProfileScreen(user: data[0],)));
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
          },
          child: const Icon(
            Icons.add_comment_rounded,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

            // if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              final snapshotData = snapshot.data?.docs;
              data = snapshotData?.map((e) => ChatUserModel.fromJson(e.data())).toList() ?? [];

              if (data.isEmpty) {
                return const Text(
                  'No Connection Found!',
                  style: TextStyle(fontSize: 20),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return ChatUserCard(
                      user: data[index],
                    );
                  },
                );
              }
          }
        },
      ),
    );
  }
}

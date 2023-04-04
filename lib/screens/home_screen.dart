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
  final List<ChatUserModel> _searchData = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                    ),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                    onChanged: (val) {
                      _searchData.clear();
                      for (var i in data) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchData.add(i);
                        }
                      }
                      setState(() {});
                    },
                  )
                : const Text('Messenger App'),
            actions: [
              // search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search),
              ),
              // more features button
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            user: APIs.me,
                          )));
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
            stream: APIs.getAllUsers(),
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
                    return const Center(
                      child: Text(
                        'No Connection Found!',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: _isSearching ? _searchData.length : snapshot.data!.docs.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: _isSearching ? _searchData[index] : data[index],
                        );
                      },
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}

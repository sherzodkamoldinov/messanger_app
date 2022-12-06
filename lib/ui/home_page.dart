import 'dart:async';
import 'dart:io';

import 'package:chat_app/data/models/popup_choices.dart';
import 'package:chat_app/data/models/user_chat_model.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/home_provider.dart';
import 'package:chat_app/ui/login.page.dart';
import 'package:chat_app/ui/settings_page.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:chat_app/utils/const.dart';
import 'package:chat_app/utils/debouncer.dart';
import 'package:chat_app/utils/my_utils.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late String currentUserId;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  TextEditingController searchController = TextEditingController();
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Settings', icon: Icons.settings),
    PopupChoices(title: 'Sign Out', icon: Icons.exit_to_app),
  ];

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    listScrollController.addListener(() {
      scrollListener();
    });
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black87,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        iconTheme: const IconThemeData(color: ColorConstants.primaryColor),
        title: const Text(
          AppConstants.appTitle,
          style: TextStyle(
            color: ColorConstants.primaryColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Switch(
            value: isWhite,
            onChanged: (value) {
              setState(() {
                isWhite = value;
                debugPrint("ISWHITE: $isWhite");
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.grey,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.green,
          ),
        ),
        actions: [
          buildPopupMenu(),
        ],
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                buildSearchBar(),
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                  stream: homeProvider.getStreamFirestore(FirestoreConstants.pathUserCollection, _limit, _textSearch),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if ((snapshot.data?.docs.length ?? 0) > 0) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: snapshot.data?.docs.length,
                          controller: listScrollController,
                          itemBuilder: (context, index) {
                            return buildItem(context, snapshot.data?.docs[index]);
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'No user found...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ),
                      );
                    }
                  },
                ))
              ],
            ),
            Positioned(
              child: isLoading ? const LoadingView() : const SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: ColorConstants.greyColor2),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: ColorConstants.greyColor,
            size: 20,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTec,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  btnClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  btnClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(hintText: "Search here...", hintStyle: TextStyle(fontSize: 13, color: ColorConstants.greyColor)),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder(
            stream: btnClearController.stream,
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? GestureDetector(
                      onTap: () {
                        searchBarTec.clear();
                        btnClearController.add(false);
                        setState(
                          () {
                            _textSearch = "";
                          },
                        );
                      },
                      child: const Icon(
                        Icons.clear_rounded,
                        color: ColorConstants.greyColor,
                        size: 20,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChatModel userChat = UserChatModel.fromDocument(document.data() as Map<String, dynamic>);
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return Container(
          margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          child: TextButton(
            onPressed: () {
              if (MyUtils.isKeyboardShowing()) {
                MyUtils.closeKeyboard(context);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    peerId: userChat.id,
                    peerNickname: userChat.nickname,
                    peerAvatar: userChat.photoUrl,
                  ),
                ),
              );
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(.2)),
                shape: MaterialStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                )),
            child: Row(
              children: [
                Material(
                  borderRadius: BorderRadius.circular(25),
                  clipBehavior: Clip.hardEdge,
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 50,
                              color: ColorConstants.greyColor,
                            );
                          },
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 50,
                          color: ColorConstants.greyColor,
                        ),
                ),
                Flexible(
                    child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                        child: Text(
                          userChat.nickname,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          userChat.aboutMe,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      )
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.zero,
          children: [
            Container(
              color: ColorConstants.themeColor,
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Icon(
                      Icons.exit_to_app,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Exit app',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Are you sure to exit app?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(
                      Icons.cancel,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const Text(
                    'Cancel',
                    style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(
                      Icons.check_circle,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const Text(
                    'Yes',
                    style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          ],
        );
      },
    )) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Widget buildPopupMenu() {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      onSelected: onItemMenuPress,
      itemBuilder: (context) {
        return choices.map(
          (PopupChoices choice) {
            return PopupMenuItem(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: const TextStyle(color: ColorConstants.primaryColor),
                  )
                ],
              ),
            );
          },
        ).toList();
      },
    );
  }

  void onItemMenuPress(PopupChoices choices) {
    if (choices.title == "Sign Out") {
      debugPrint('SIGN OUT');
      handleSignOut();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}

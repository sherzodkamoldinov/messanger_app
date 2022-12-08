import 'package:chat_app/data/models/user_chat_model.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/providers/setting_provider.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:chat_app/widgets/custom_appbar.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: CustomAppBar(
        title: 'Settings',
        backgroundColor: !isWhite ? Colors.black : null,
        titleColor: !isWhite ? Colors.white : null,
      ),
      body: const SettingsPageState(),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({super.key});

  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {
  late UserChatModel user;
  TextEditingController? controllerNickName;
  TextEditingController? controllerAboutMe;

  late TextEditingController _phoneController;

  late SettingProvider _settingProvider;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    _settingProvider = context.read<SettingProvider>();

    _settingProvider.readLocal();

    user = _settingProvider.user;

    controllerNickName = TextEditingController(text: user.nickname);
    controllerAboutMe = TextEditingController(text: user.aboutMe);
    _phoneController = TextEditingController(text: user.phoneNumber);
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    _settingProvider.updateUser(context, user);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                onPressed: () {
                  _settingProvider.getImage(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: context.watch<SettingProvider>().avatarImageFile == null
                      ? user.photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.network(
                                user.photoUrl,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.account_circle,
                                    size: 90,
                                    color: ColorConstants.greyColor,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                        value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.account_circle,
                              size: 90,
                              color: ColorConstants.greyColor,
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: Image.file(
                            context.watch<SettingProvider>().avatarImageFile!,
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          ),
                        ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 5, top: 10),
                    child: const Text(
                      'Name',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.primaryColor),
                          ),
                          hintText: "Write your name...",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: ColorConstants.primaryColor),
                        ),
                        controller: controllerNickName,
                        onChanged: (value) {
                          user.nickname = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                  ),

                  // ABOUT ME
                  Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 5, top: 10),
                    child: const Text(
                      'About me',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.greyColor2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: ColorConstants.primaryColor),
                          ),
                          hintText: "Write something about yourself...",
                          contentPadding: EdgeInsets.all(5),
                          hintStyle: TextStyle(color: ColorConstants.primaryColor),
                        ),
                        controller: controllerAboutMe,
                        onChanged: (value) {
                          user.aboutMe = value;
                        },
                        focusNode: focusNodeAboutMe,
                      ),
                    ),
                  ),

                  // PHONE NUMBER
                  Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 5, top: 10),
                    child: const Text(
                      'Phone number',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(color: Colors.grey),
                        controller: _phoneController,
                        onChanged: (newPhone) {
                          user.phoneNumber = newPhone.trim();
                        },
                        decoration: InputDecoration(
                            prefixIcon: CountryCodePicker(
                              flagWidth: 24,
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                              onChanged: (CountryCode? country) {
                                if (country != null) {
                                  setState(() {
                                    user.dialCode = country.dialCode!;
                                  });
                                }
                              },
                              initialSelection: user.dialCode.isNotEmpty ? user.dialCode : '+998',
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              favorite: const ['UZ', 'US', 'RU', 'KZ'],
                            ),
                            hintText: 'Write your phone number',
                            contentPadding: const EdgeInsets.all(5),
                            hintStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ColorConstants.greyColor2)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ColorConstants.primaryColor))),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 50, bottom: 50),
                child: TextButton(
                  onPressed: handleUpdateData,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.primaryColor), padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(30, 10, 30, 10))),
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          child: context.watch<SettingProvider>().isLoading ? const LoadingView() : const SizedBox.shrink(),
        )
      ],
    );
  }
}

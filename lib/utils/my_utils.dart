import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyUtils {
  static bool isKeyboardShowing() {
    if (WidgetsBinding.instance != null) {
      return WidgetsBinding.instance.window.viewInsets.bottom > 0;
    } else {
      return false;
    }
  }

  static closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}

class CustomSnackbar {
  static showSnackbar(
    BuildContext context,
    String text,
    SnackbarType type,
  ) {
    return ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              height: 90,
              decoration: BoxDecoration(
                  color: type == SnackbarType.error
                      ? const Color(0xFFC72C41)
                      : type == SnackbarType.success
                          ? const Color(0xFF0C7040)
                          : const Color(0xFFEF8D32),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            type == SnackbarType.error
                                ? 'Oops!'
                                : type == SnackbarType.success
                                    ? 'Well done!'
                                    : 'Warning!',
                            style: const TextStyle(fontSize: 18, color: Colors.white)),
                        const SizedBox(height: 7),
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
                child: SvgPicture.asset(
                  'assets/svg/bubbles.svg',
                  width: 48,
                  height: 40,
                  color: type == SnackbarType.error
                      ? const Color(0xFF801336)
                      : type == SnackbarType.success
                          ? const Color(0xFF004E32)
                          : const Color(0xFFCC561E),
                ),
              ),
            ),
            Positioned(
              top: -18,
              left: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/back.svg',
                    height: 40,
                    color: type == SnackbarType.error
                        ? null
                        : type == SnackbarType.success
                            ? const Color(0xFF004E32)
                            : const Color(0xFFCC561E),
                  ),
                  Positioned(
                    top: 10,
                    child: SvgPicture.asset(
                      type == SnackbarType.error
                          ? 'assets/svg/types/x.svg'
                          : type == SnackbarType.success
                              ? 'assets/svg/types/success.svg'
                              : 'assets/svg/types/warning.svg',
                      height: 17,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: type == SnackbarType.error
                      ? Colors.red[300]
                      : type == SnackbarType.success
                          ? Colors.green[300]
                          : Colors.orange[300],
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    icon: SvgPicture.asset(
                      'assets/svg/types/x.svg',
                      color: Colors.white,
                      height: 18,
                    ),
                  ),
                ))
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ));
  }
}

enum SnackbarType {
  error,
  success,
  warning,
}

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
    this.actions,
  });
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;
  final List<ActionModel>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        splashRadius: 30,
        icon: Icon(
          Icons.arrow_back_ios,
          color: titleColor ?? Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: backgroundColor ?? Colors.white,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(color: titleColor ?? Colors.black87),
      ),
      actions: actions != null
          ? [
              ...List.generate(actions!.length, (index) {
                ActionModel action = actions![index];
                return IconButton(
                  splashRadius: 30,
                  onPressed: action.onTap,
                  icon: Icon(action.icon, color: action.iconColor ?? titleColor ?? Colors.black87),
                );
              })
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 56);
}

class ActionModel {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  ActionModel({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
}

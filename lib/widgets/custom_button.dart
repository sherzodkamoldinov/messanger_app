import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.width,
    this.backgroundColor,
    this.titleColor,
    this.icon,
    this.iconColor,
  });
  final VoidCallback onTap;
  final String title;
  final double? width;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: width ?? double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: backgroundColor ?? const Color.fromARGB(255, 0, 85, 255), boxShadow: [
          BoxShadow(
            color: backgroundColor?.withOpacity(0.6) ?? const Color.fromARGB(255, 0, 85, 255).withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 2,
          )
        ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Row(
                children: [
                  Icon(icon, color: iconColor ?? Colors.white, size: 26),
                  const SizedBox(width: 20),
                ],
              ),
            Text(
              title,
              style: TextStyle(
                color: titleColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

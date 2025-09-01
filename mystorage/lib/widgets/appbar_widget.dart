import 'package:flutter/material.dart';
import 'package:mystorage/themes/constants.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeadingButton; // Boolean to control the visibility of the leading button
  final VoidCallback? onLeadingPressed; // Optional callback for leading button

  AppbarWidget({
    Key? key,
    required this.title,
    this.showLeadingButton = false, // Set default to false
    this.onLeadingPressed, // Optional action
  }) : super(key: key);

  Utils clrScheme = Utils();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: clrScheme.appBarTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: clrScheme.backgroundColor,

      // Conditionally show the leading button if `showLeadingButton` is true
      leading: showLeadingButton
          ? IconButton(
        onPressed: onLeadingPressed ?? () {
          Navigator.of(context).pop(); // Default action: pop the screen
        },
        icon: const Icon(Icons.arrow_back_rounded),
        color: clrScheme.appBarTextColor,
      )
          : null, // No leading button if false
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mystorage/pages/settings.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function()? onAddFolder;
  final String icon;
  final Color color;
  final String img;
  final String settings;
  final String currentPage; // Add this to track the current page
  final double addFolderIconWidth; // Width for the add folder icon
  final double settingsIconWidth; // Width for the settings icon

  CustomBottomNavBar({
    required this.onAddFolder,
    required this.img,
    required this.settings,
    required this.currentPage,
    required this.icon,
    required this.color,
    this.addFolderIconWidth = 30, // Default width if not provided
    this.settingsIconWidth = 30, // Default width if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color with some opacity
            blurRadius: 8, // Blur radius from Figma
            spreadRadius: 0, // Spread radius from Figma
            offset:const Offset(0, 0), // X and Y offsets from Figma
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomAppBar(
          color: Colors.white, // Set the BottomAppBar color to white
          shape:const CircularNotchedRectangle(), // Creates the curved notch
          notchMargin: 8, // Margin around the notch
          elevation: 100, // Set elevation to 0 to rely on boxShadow
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Add Folder Button
              InkWell(
                onTap: onAddFolder,
                child: Image.asset(img, width: addFolderIconWidth), // Set width for the add folder icon
              ),
              const SizedBox(width: 50),

              // Settings Button with conditional rendering
              currentPage == 'settings'
                  ? CircleAvatar(
                // Display CircleAvatar if on settings page
                backgroundColor: Color(0xffBC4646),
                radius: 25,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white, // Set the color you want
                    BlendMode.srcATop, // Blend mode to apply color
                  ),
                  child: Image.asset(settings, width: settingsIconWidth), // Set width for the settings icon
                ),
              )
                  : InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => Settings(), // Your settings page
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Image.asset(settings, width: settingsIconWidth), // Set width for the settings icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}

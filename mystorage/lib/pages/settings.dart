import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mystorage/buttons/subscription_button.dart';
import 'package:mystorage/pages/home_page.dart';
import 'package:mystorage/pages/subsciption.dart';
import 'package:mystorage/themes/constants.dart';
import 'package:mystorage/widgets/appbar_widget.dart';
import 'package:mystorage/widgets/backup_options.dart';
import 'package:mystorage/widgets/backup_preferences.dart';
import 'package:mystorage/widgets/custom_bottom_bar.dart';

class Settings extends StatelessWidget {
  Settings({super.key});
  Utils clrScheme = Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clrScheme.backgroundColor,
      appBar: AppbarWidget(
        title: "Settings",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Define action for FAB
        },
        backgroundColor:const Color(0xffA9ABAC),
        shape:const CircleBorder(), // Ensure the FAB is circular
        elevation: 0, // Remove shadow
        child: const ClipOval(
          child: SizedBox(
            width: 60, // Diameter of the FAB
            height: 60,
            child: Icon(Icons.camera_alt,color: Colors.white,size: 30,),
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(

        settings:"assets/images/settings_icon.png",
        img: "assets/images/create_folder_icon.png",
        color: Color(0xffBC4646),
        icon: Mdi.folder_plus,
        currentPage: "settings",
        addFolderIconWidth: 43, // Custom width for the add folder icon
        settingsIconWidth: 33, // Custom width for the settings icon

        onAddFolder: () {
          // Action for adding folder
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomePage(), // Your settings page
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            BackUpOptions(),
            const SizedBox(
              height: 10,
            ),
            const BackupPreferences(),
            const SizedBox(
              height: 10,
            ),
            SubscriptionButton(
                action: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => Subscription()));
                },
                title: "Subscription"),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mystorage/pages/home_page.dart';

class FoldersPath extends StatelessWidget {
  final String folderName;
  final VoidCallback onBackPressed;
  final VoidCallback onHomePressed;
  final String currentFolderName;
  final Function(String) onPathSegmentClick;

  FoldersPath({
    super.key,
    required this.folderName,
    required this.onBackPressed,
    required this.onHomePressed,
    required this.currentFolderName,
    required this.onPathSegmentClick,
  });

  @override
  Widget build(BuildContext context) {
    // Split folder path by ' > ' to get folder hierarchy
    List<String> folderParts =
        folderName.isNotEmpty ? folderName.split(' > ') : [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Always show red home icon at the root level
          folderParts.isEmpty
              ? InkWell(
                  onTap:(){
                  //   Navigator.of(context).pushReplacement(
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) => HomePage(), // Your settings page
                  //     transitionDuration: Duration.zero,
                  //     reverseTransitionDuration: Duration.zero,
                  //   ),
                  // );
                    },
                  child: const Image(
                    image: AssetImage("assets/images/red_home.png"),
                    width: 40,
                    height: 40,
                  ),
                )
              : InkWell(
            onTap: (){
              onHomePressed();
              // Navigator.of(context).pushReplacement(
              // PageRouteBuilder(
              //   pageBuilder: (context, animation, secondaryAnimation) => HomePage(), // Your settings page
              //   transitionDuration: Duration.zero,
              //   reverseTransitionDuration: Duration.zero,
              // ),
            // );
              },
            //onTap: onBackPressed,
                  child: const Image(
                    image: AssetImage("assets/images/home_icon.png"),
                    width: 40,
                    height: 40,
                  ),
                ),
          const SizedBox(width: 5),
          // Always show an arrow after the red home icon
          if (folderParts.isNotEmpty ||
              currentFolderName
                  .isNotEmpty) // Show arrow when there is at least one folder or a current folder

            const Image(
              image: AssetImage("assets/images/arrow.png"),
              width: 40,
              height: 20,
            ),
          const SizedBox(width: 5),
          // Create a list of widgets to display folder names and arrows
          ...folderParts.asMap().entries.map((entry) {
            int index = entry.key;
            String part = entry.value;
            bool isCurrentFolder = part == currentFolderName;

            return InkWell(
              onTap: () => onPathSegmentClick(
                  part), // Call the function with the clicked part
              child: Row(
                children: [
                  if (index > 0) // Display arrow for deeper levels
                    const Image(
                      image: AssetImage("assets/images/arrow.png"),
                      width: 40,
                      height: 20,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    part,
                    style: isCurrentFolder
                        ? const TextStyle(
                            color: Color(0xffBC4646),
                            fontWeight: FontWeight.bold)
                        : const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

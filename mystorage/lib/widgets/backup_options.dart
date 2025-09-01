import 'package:flutter/material.dart';
import 'package:mystorage/themes/constants.dart';

class BackUpOptions extends StatelessWidget {
  BackUpOptions({Key? key}) : super(key: key);
  Utils clr = Utils();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Backup",
          style: TextStyle(
            color: clr.appBarTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10), // Space between title and options
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the row
          children: [
            // Expanded widget for each container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8), // Padding around each container
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Fit content
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0), // Padding inside the container
                        child: Image.asset(
                          "assets/images/local_drive_icon.png",
                          fit: BoxFit.contain, // Adjust image to fit the container
                          height: 50, // Set height for images if needed
                        ),
                      ),
                      const SizedBox(height: 8), // Space between image and text
                      const Padding(
                        padding:  EdgeInsets.only(bottom: 10.0), // Padding for text from the bottom
                        child: Text(
                          "Local Storage",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/google_drive_icon.png",
                          fit: BoxFit.contain,
                          height: 50,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding:  EdgeInsets.only(bottom: 10.0), // Padding for text from the bottom
                        child: Text(
                          "Google Storage",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/dropbox_icon.png",
                          fit: BoxFit.contain,
                          height: 50,
                        ),
                      ),
                      const SizedBox(height: 8),
                     const Padding(
                        padding:  EdgeInsets.only(bottom: 10.0), // Padding for text from the bottom
                        child: Text(
                          "Microsoft Storage",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

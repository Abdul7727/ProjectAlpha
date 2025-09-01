import 'package:flutter/material.dart';

class BackupPreferences extends StatefulWidget {
  const BackupPreferences({Key? key}) : super(key: key);

  @override
  _BackupPreferencesState createState() => _BackupPreferencesState();
}

class _BackupPreferencesState extends State<BackupPreferences> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligns the items to start from the left
        children: [
          const Text(
            "Backup Preferences",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16), // Space between the title and the radio buttons
          _buildCustomRadioTile("Backup Now"),
          _buildCustomRadioTile("Daily"),
          _buildCustomRadioTile("Weekly"),
          _buildCustomRadioTile("Monthly"),
          _buildCustomRadioTile("My Preferred Time"),
        ],
      ),
    );
  }

  // Method to build a custom radio tile with icon images
  Widget _buildCustomRadioTile(String value) {
    return ListTile(
      leading: Image.asset(
        _selectedValue == value
            ? 'assets/images/radio_sel.png' // Selected icon
            : 'assets/images/radio_unsel.png', // Unselected icon
        width: 24, // Set size of the icon as needed
        height: 24,
      ),
      title: Text(
        value,
        style: TextStyle(
          color:
              _selectedValue == value ? const Color(0xffBC4646) : Colors.black,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
    );
  }
}

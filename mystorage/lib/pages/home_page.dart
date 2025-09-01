import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mystorage/services/directory_creation.dart'; // Import the updated FolderServices
import 'package:mystorage/widgets/folders_path.dart';
import 'package:mystorage/widgets/serachbar_filter.dart';
import 'package:mystorage/themes/constants.dart';
import 'package:mystorage/model/models.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mystorage/widgets/custom_bottom_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';

import 'full_screen_media.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Utils clrScheme = Utils();
  List<Folder> topLevelFolders = [];
  List<Folder> topLevelFoldersAll = [];
  String currentPath = "MyLocalStorage"; // Updated to reflect the new directory
  List<String> folderPathStack = ["MyLocalStorage"];
  final FolderServices folderServices = FolderServices();
  bool isFirstOpened = false;
  EmojiItem emojiItemSelected = const EmojiItem(emojisName: '', text: '');
  Set<String> selectedFolders = {}; // Track selected folders by their titles
  bool isSelecting = false; // Flag to show checkboxes when long-pressed
  Set<String> selectedFiles = {};
  TextEditingController searchTextEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initializeFolders();
  }

  List<Folder> folders = [];

  Future<void> _initializeFolders() async {
    try {
      await folderServices.initialize(); // Ensure this completes
      folderPathStack = List.from(await getFolderPathStack());

      // Check if the folders list is empty
      if (folders.isEmpty) {
        print("This is the folder list ::  $folders");

        // If there are no folders, create the first dummy folder
        var initialFolder = Folder(
          title: "FolderModel",
          date: DateTime.now(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          parentId: null,
          // It's a top-level folder
          isDummy: true, // Mark it as a dummy folder
          emojiName: '',
          emojiText: ''
        );

        // Check if the folder already exists before adding it
        bool folderExists =
            folders.any((folder) => folder.title == initialFolder.title);

        if (!folderExists) {
          await folderServices
              .addFolder(initialFolder); // Add the initial folder to storage
          folders.add(initialFolder); // Add to the local list as well
        }

        _updateTopLevelFolders(); // Update top-level folders after adding the folder
      } else {
        _updateTopLevelFolders(); // Update top-level folders if there are already folders
      }
    } catch (e) {
      print("Error initializing folders: $e");
    }
  }

  void _showAddFolderDialog() async {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Folder',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.folder, color: Colors.blueGrey),
                      labelText: 'Folder Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField2(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Emoji',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      ...EmojiItems.firstItems.map(
                            (item) => DropdownMenuItem<EmojiItem>(
                              value: item,
                              child: EmojiItems.buildItem(item),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      emojiItemSelected = value!;
                      EmojiItems.onChanged(context, value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String title = titleController.text.trim();
                          if (title.isNotEmpty) {
                            // Create the parent folder
                            var parentFolder = Folder(
                              title: title,
                              date: DateTime.now(),
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                              parentId: folderPathStack.length > 1
                                  ? folderServices
                                      .getCurrentFolderId(folderPathStack.last)
                                  : null,
                              emojiName: emojiItemSelected.emojisName,
                              emojiText: emojiItemSelected.text,
                            );

                            // Create the dummy folder and mark it as dummy

                            var dummyFolder = Folder(
                              title: "${title}_dummy",
                              date: DateTime.now(),
                              timestamp: DateTime.now().millisecondsSinceEpoch,
                              parentId: parentFolder.timestamp.toString(),
                              isDummy: true, // Set isDummy to true
                              emojiName: emojiItemSelected.emojisName,
                              emojiText: emojiItemSelected.text,
                            );
                            try {
                              // Add both parent and dummy folders
                              await folderServices.addFolder(parentFolder);
                              await folderServices.addFolder(dummyFolder);

                              // Update the UI
                              _updateTopLevelFolders();
                              Navigator.pop(context);
                            } catch (e) {
                              print("Error adding folders: $e");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  void _showEditFolderDialog(Folder folderSelected) async {
    // for(EmojiItem emojiItem in EmojiItems.firstItems) {
    //   print("Checking EMoji Issue: ${emojiItem.emojisName}, ${emojiItem.text}, ${folderSelected.emojiName}, ${folderSelected.emojiText}");
    // }
    final TextEditingController titleController = TextEditingController(text: folderSelected.title);
    final String originalFolderName = folderSelected.title;
    emojiItemSelected = EmojiItem(emojisName: folderSelected.emojiName, text: folderSelected.emojiText);

        showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Update Emoji',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      prefixIcon:
                      const Icon(Icons.folder, color: Colors.blueGrey),
                      labelText: 'Folder Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  folderSelected.emojiName.isEmpty ?  DropdownButtonFormField2(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Emoji',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      ...EmojiItems.firstItems.map(
                            (item) => DropdownMenuItem<EmojiItem>(
                              value: item,
                              child: EmojiItems.buildItem(item),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      emojiItemSelected = value!;
                      EmojiItems.onChanged(context, value);
                    },
                  ) : DropdownButtonFormField2(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Emoji',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      ...EmojiItems.firstItems.map(
                            (item) => DropdownMenuItem<EmojiItem>(
                          value: item,
                          child: EmojiItems.buildItem(item),
                        ),
                      ),
                    ],
                    value: EmojiItem(emojisName: folderSelected.emojiName, text: folderSelected.emojiText),
                    onChanged: (value) {
                      emojiItemSelected = value!;
                      EmojiItems.onChanged(context, value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String title = titleController.text;
                          if (title.isNotEmpty) {
                            // Create the parent folder
                            var parentFolder = Folder(
                              title: title,
                              date: folderSelected.date,
                              timestamp: folderSelected.date.millisecondsSinceEpoch,
                              parentId: folderSelected.parentId,
                              emojiName: emojiItemSelected.emojisName,
                              emojiText: emojiItemSelected.text,
                            );

                            // // Create the dummy folder and mark it as dummy
                            //
                            // var dummyFolder = Folder(
                            //   title: "${title}_dummy",
                            //   date: DateTime.now(),
                            //   timestamp: DateTime.now().millisecondsSinceEpoch,
                            //   parentId: parentFolder.timestamp.toString(),
                            //   isDummy: true, // Set isDummy to true
                            //   emojiName: emojiItemSelected.emojisName,
                            //   emojiText: emojiItemSelected.text,
                            // );
                            try {
                              // Add both parent and dummy folders
                              await folderServices.updateFolder(parentFolder, originalFolderName);
                              //await folderServices.updateFolder(dummyFolder);
                              // Update the UI
                              _updateTopLevelFolders();
                              Navigator.pop(context);
                            } catch (e) {
                              print("Error adding folders: $e");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  void _showEditMediaNameDialog(String mediaName, String mediaPath) async {
    // for(EmojiItem emojiItem in EmojiItems.firstItems) {
    //   print("Checking EMoji Issue: ${emojiItem.emojisName}, ${emojiItem.text}, ${folderSelected.emojiName}, ${folderSelected.emojiText}");
    // }
    final TextEditingController titleController = TextEditingController(text: mediaName);

        showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Update Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      prefixIcon:
                      const Icon(Icons.folder, color: Colors.blueGrey),
                      labelText: 'Media Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String title = titleController.text;
                          if (title.isNotEmpty) {
                            if(mediaName.contains(".png")) {
                              _editImageToFolder(File(mediaPath), titleController.text, mediaPath);
                            } else {
                              _editVideoToFolder(File(mediaPath), titleController.text, mediaPath);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onFolderTap(Folder folder) async {
    // Update current folder path with the new folder
    String currentFolderPath = _getCurrentFolderPath();
    String newFolderPath =
        '$currentFolderPath/${folder.title}'; // Include the new folder
    print("This is the current open folder: $newFolderPath");

    // Fetch folder contents (non-recursively check the current folder only)
    List<FileSystemEntity> files = await getFolderContents(newFolderPath);
    setState(() {
      topLevelFolders.add(folder);
      // Add the folder to the folder stack if it's not already there
      if (folderPathStack.last.isNotEmpty) {
        folderPathStack
            .add(folder.title); // Add the current folder to the path stack
        //  _saveCurrentFolder(folder.title);
      }
      // Update the folder content
      _updateTopLevelFolders();
      isFirstOpened = true; // Change this logic if necessary
    });
  }

  Future<List<FileSystemEntity>> getFolderContents(String folderPath) async {
    // Use the provided folderPath instead of _getCurrentFolderPath()
    Directory directory = Directory(folderPath);

    List<FileSystemEntity> fileList = [];

    // Check if the directory exists
    if (await directory.exists()) {
      print("Current folder content: $folderPath");

      // List files in the current directory (non-recursive)
      await for (var entity in directory.list(followLinks: false)) {
        fileList.add(entity);
      }

      // Print the contents of the directory for debugging
      for (var entity in fileList) {
        print("Found: ${entity.path}");
      }
    } else {
      print("Directory does not exist: $folderPath");
    }

    return fileList;
  }

  void _updateTopLevelFolders() async {
    // Fetch top-level folders
    List<Folder> fetchedFolders = await folderServices.getTopLevelFolders(
      folderPathStack.length > 1
          ? folderServices.getCurrentFolderId(folderPathStack.last)
          : null,
    );

    await saveFolderPathStack(folderPathStack);

    // Ensure media files are fetched from the correct path
    for (var folder in fetchedFolders) {
      String folderPath = await _getCurrentFolderPath();

      final dir = Directory(folderPath);

      // Clear existing images/videos
      folder.images = [];
      folder.video = [];

      if (await dir.exists()) {
        var files = dir.listSync();
        for (var file in files) {
          if (file is File) {
            if (file.path.endsWith('.png') || file.path.endsWith('.jpg')) {
              folder.images.add(file.path);
            } else if (file.path.endsWith('.mp4')) {
              folder.video.add(file.path);
            }
          }
        }
      }
    }

    setState(() {
      searchTextEditingController.text = '';
      FocusScope.of(context).unfocus();
      topLevelFoldersAll = fetchedFolders;
      topLevelFolders = fetchedFolders;
    });
    print("topLevelFolders  :${topLevelFolders.length}");
  }

  void _navigateToFolder(String folderTitle) {
    print('Clicked Now');
    setState(() {
      int index = folderPathStack.indexOf(folderTitle);
      if (index != -1) {
        folderPathStack = folderPathStack.sublist(0, index + 1);
        _updateTopLevelFolders();
      }
    });
  }

  Future<void> _showImageSelectionDialog({required bool isVideo}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CameraAwesomeBuilder.awesome(
            onMediaCaptureEvent: (event) {
              switch ((event.status, event.isPicture, event.isVideo)) {
                case (MediaCaptureStatus.capturing, true, false):
                  debugPrint('Capturing picture...');
                  break;
                case (MediaCaptureStatus.success, true, false):
                  event.captureRequest.when(
                    single: (single) {
                      debugPrint('Picture saved: ${single.file?.path}');
                      // Handle the captured image (save to folder, etc.)
                      _saveImageToFolder(File(single.file!.path));
                    },
                  );
                  break;
                case (MediaCaptureStatus.failure, true, false):
                  debugPrint('Failed to capture picture: ${event.exception}');
                  break;
                case (MediaCaptureStatus.capturing, false, true):
                  debugPrint('Capturing video...');
                  break;
                case (MediaCaptureStatus.success, false, true):
                  event.captureRequest.when(
                    single: (single) {
                      debugPrint('Video saved: ${single.file?.path}');
                      // Handle the captured video
                      _saveVideoToFolder(File(single.file!.path));
                    },
                  );
                  break;
                case (MediaCaptureStatus.failure, false, true):
                  debugPrint('Failed to capture video: ${event.exception}');
                  break;
                default:
                  debugPrint('Unknown event: $event');
              }
            },
            saveConfig: SaveConfig.photoAndVideo(
              initialCaptureMode:
                  isVideo ? CaptureMode.video : CaptureMode.photo,
              photoPathBuilder: (sensors) async {
                final Directory extDir = await getTemporaryDirectory();
                final testDir = await Directory(
                  '${extDir.path}/camerawesome',
                ).create(recursive: true);

                if (sensors.length == 1) {
                  final String filePath =
                      '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                  return SingleCaptureRequest(filePath, sensors.first);
                }

                // Handle multiple captures if necessary
                return MultipleCaptureRequest({
                  for (final sensor in sensors)
                    sensor:
                        '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                });
              },
              videoOptions: VideoOptions(
                enableAudio: true,
              ),
              exifPreferences: ExifPreferences(saveGPSLocation: true),
            ),
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.back),
              flashMode: FlashMode.auto,
              aspectRatio: CameraAspectRatios.ratio_4_3,
              zoom: 0.0,
            ),
            enablePhysicalButton: true,
          ),
        ),
      ),
    );
  }

  Future<void> _saveVideoToFolder(File video) async {
    String currentFolderPath = _getCurrentFolderPath();
    String videoName = 'cap_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    String newPath = '$currentFolderPath/$videoName';

    // Check if the file already exists to avoid duplication
    if (!await File(newPath).exists()) {
      File newVideo = await video.copy(newPath);
      print("Video saved at: ${newVideo.path}");
      _updateTopLevelFolders();
    } else {
      print("Video already exists at: $newPath");
    }
  }

  Future<void> _saveImageToFolder(File image) async {
    String currentFolderPath = _getCurrentFolderPath();
    String imageName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.png';
    String newPath = '$currentFolderPath/$imageName';

    // Check if the file already exists to avoid duplication
    if (!await File(newPath).exists()) {
      File newImage = await image.copy(newPath);
      print("Image saved at: ${newImage.path}");
      _updateTopLevelFolders();
    } else {
      print("Image already exists at: $newPath");
    }
  }
  Future<void> _editImageToFolder(File oldFile, String mediaName, String mediaPath) async {
    String currentFolderPath = _getCurrentFolderPath();
    String imageName = '${mediaName.replaceAll(".png", "")}.png';
    String newPath = '$currentFolderPath/$imageName';
    File image = File(mediaPath);
    // Check if the file already exists to avoid duplication
    if (!await File(newPath).exists()) {
      File newImage = await image.copy(newPath);
      print("Image saved at: ${newImage.path}");
      if(await oldFile.exists()) {
        await oldFile.delete();
      }
      _updateTopLevelFolders();
    } else {
      print("Image already exists at: $newPath");
    }
    Navigator.pop(context);
  }
  Future<void> _editVideoToFolder(File oldFile, String mediaName, String mediaPath) async {
    String currentFolderPath = _getCurrentFolderPath();
    String videoName = 'cap_video_${mediaName.replaceAll(".mp4", "")}.mp4';
    String newPath = '$currentFolderPath/$videoName';
    File video = File(mediaPath);
    // Check if the file already exists to avoid duplication
    if (!await File(newPath).exists()) {
      File newImage = await video.copy(newPath);
      print("Video saved at: ${newImage.path}");
      if(await oldFile.exists()) {
        await oldFile.delete();
      }
      _updateTopLevelFolders();
    } else {
      print("Image already exists at: $newPath");
    }
    Navigator.pop(context);
  }

  Future<void> saveFolderPathStack(List<String> folderPathStack) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert List<String> to JSON String and save it
    String folderPathStackJson = jsonEncode(folderPathStack);
    await prefs.setString('folderPathStack', folderPathStackJson);
  }

  Future<List<String>> getFolderPathStack() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve and decode the JSON String
    String? folderPathStackJson = prefs.getString('folderPathStack');
    if (folderPathStackJson != null) {
      return List<String>.from(jsonDecode(folderPathStackJson));
    } else {
      // Return a default list if none is found
      return ["MyLocalStorage"];
    }
  }

  String _getCurrentFolderPath() {
    // Traverse the folderPathStack to get the full path
    String path = folderServices.myLocalStorageDir.path;
    if (folderPathStack.length > 1) {
      for (int i = 1; i < folderPathStack.length; i++) {
        path = '$path/${folderPathStack[i]}';
      }
    }
    return path;
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  void _showPermissionDeniedDialog(String title,String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('$title', style: const TextStyle(
            fontFamily: 'Neue Plak',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white)),
        content: Text('$body',
            style: const TextStyle(
                fontFamily: 'Neue Plak',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () async{
              Navigator.of(context).pop();
              await openAppSettings(); // Open the app settings
            },
            child: Text('Open Settings',
                style:   TextStyle(
                    fontFamily: 'Neue Plak',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: HexColor('#FF13C6'))),
          ),
          TextButton(
            onPressed: ()  {
              Navigator.of(context).pop(); // Close the dialog

            },
            child: Text('Continue',
              style: TextStyle(
                  fontFamily: 'Neue Plak',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: HexColor('#FF13C6')),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clrScheme.backgroundColor,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
            PermissionStatus permissionStatus = await Permission.camera.status;
            if (permissionStatus.isGranted) {
              // Ask user to choose between image or video
              await _showImageSelectionDialog(isVideo: false); // Open camera for image
            }
            else if (permissionStatus.isDenied || permissionStatus.isRestricted) {
              PermissionStatus status = await Permission.camera.request();
              if (status.isGranted) {
                // Ask user to choose between image or video
                await _showImageSelectionDialog(isVideo: false); // Open camera for image
              } else {
                _showPermissionDeniedDialog("Permission Required",
                    'Permission for camera is denied permanently. Please go to settings and enable it manually.');
              }
            } else if (permissionStatus.isPermanentlyDenied) {
              _showPermissionDeniedDialog('Permission Required','Permission for camera is denied permanently. Please go to settings and enable it manually.');
            }
        },
        backgroundColor: const Color(0xffa9abac),
        shape: const CircleBorder(),
        elevation: 0,
        child: const ClipOval(
          child: SizedBox(
            width: 60,
            height: 60,
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onAddFolder: _showAddFolderDialog,
        settings: "assets/images/settings_icon.png",
        color: const Color(0xffBC4646),
        img: "assets/images/create_folder_icon.png",
        icon: Mdi.folder_plus,
        currentPage: "homepage",
        addFolderIconWidth: 43,
        settingsIconWidth: 33,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWithFilter(
                    controller: searchTextEditingController,
                    onSearchChanged: (query) {
                      final filtered = topLevelFoldersAll.where((folder) {
                        return folder.title.toLowerCase().contains(query.toLowerCase());
                      }).toList();
                      setState(() {
                        topLevelFolders = filtered;
                      });
                    },
                    onFilterTap: () {
                      print("Filter tapped!");
                      // TODO: Show a filter dialog or dropdown
                      setState(() {
                        print("Sort Order");
                        topLevelFolders = topLevelFolders.reversed.toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  FoldersPath(
                    onHomePressed: () {
                      folderPathStack = ["MyLocalStorage"];
                      _updateTopLevelFolders();
                    },
                    folderName: folderPathStack.length > 1
                        ? folderPathStack.sublist(1).join(" > ")
                        : "",
                    onBackPressed: () {
                      if (folderPathStack.length > 1) {
                        setState(() {
                          folderPathStack.removeLast();
                          _updateTopLevelFolders();
                        });
                      }
                    },
                    currentFolderName: folderPathStack.last,
                    onPathSegmentClick: _navigateToFolder,
                  ),
                  if (isSelecting)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xffa91405),
                        ),
                        onPressed: () {
                          _showDeleteConfirmationDialog();
                        },
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Clear the selection when tapping outside the folders
                  setState(() {
                    isSelecting = false;
                    selectedFolders.clear();
                    selectedFiles.clear(); // Clear selected files too
                  });
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: topLevelFolders
                          .where((folder) => !folder.isDummy)
                          .length +
                      (topLevelFolders.isNotEmpty
                          ? topLevelFolders.last.images
                                  .where((file) =>
                                      file.endsWith('.png') ||
                                      file.endsWith('.jpg'))
                                  .length +
                              topLevelFolders.last.video
                                  .where((file) => file.endsWith('.mp4'))
                                  .length
                          : 0),
                  itemBuilder: (context, index) {
                    final nonDummyFolders = topLevelFolders
                        .where((folder) => !folder.isDummy)
                        .toList();

                    if (index < nonDummyFolders.length) {
                      // Handling folder item
                      final folder = nonDummyFolders[index];
                      final folderTitle = folder.title;
                      final emojiName = folder.emojiName;
                      final emojiText = folder.emojiText;

                      return GestureDetector(
                        onTap: () {
                          if (isSelecting) {
                            // If selection mode is active, toggle checkbox state for folder
                            setState(() {
                              if (selectedFolders.contains(folderTitle)) {
                                selectedFolders.remove(folderTitle);
                              } else {
                                selectedFolders.add(folderTitle);
                              }
                            });
                          } else {
                            _onFolderTap(folder); // Regular tap to open the folder
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            isSelecting = true; // Enable selection mode
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Use a Stack to position the Checkbox over the image
                              Expanded(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Folder icon
                                    AspectRatio(
                                      aspectRatio: 1.5,
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Image.asset(
                                              "assets/images/created_folder_icon.png",
                                            ),
                                          ),
                                          Positioned(

                                            bottom: 0, // Adust this value to position the emoji_heart
                                            right: 0,  // Adjust this value to position the emoji_heart
                                            child: GestureDetector(
                                              onLongPress: () {
                                                //Emoji Edit or Folder Name Edit
                                                _showEditFolderDialog(folder);
                                              },
                                              child: Image.asset(
                                                emojiName.isEmpty ? 'assets/images/select_emoji.png' : emojiName,
                                                width: 30, // Adjust size as needed
                                                height: 30, // Adjust size as needed
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Checkbox positioned at the top-right corner for folders
                                    if (isSelecting) ...[
                                      Positioned(
                                        bottom: 15,
                                        left: 25,
                                        top: 0,
                                        right: 0,
                                        child: Checkbox(
                                          checkColor: Colors.white,
                                          tristate: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ),
                                          value: selectedFolders
                                              .contains(folderTitle),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedFolders
                                                    .add(folderTitle);
                                              } else {
                                                selectedFolders
                                                    .remove(folderTitle);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Folder name text
                              SizedBox(
                                height: 40,
                                child: Text(
                                  capitalizeFirstLetter(folderTitle),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Handling media files (images and videos)
                      int currentIndex = index - nonDummyFolders.length;
                      final mediaFiles = [
                        ...topLevelFolders.last.images.where((image) =>
                            image.endsWith('.png') || image.endsWith('.jpg')),
                        ...topLevelFolders.last.video
                            .where((video) => video.endsWith('.mp4')),
                      ];

                      if (currentIndex < mediaFiles.length) {
                        String mediaPath = mediaFiles[currentIndex];
                        String mediaName = mediaPath.split('/').last;

                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              isSelecting = true; // Enable selection mode
                            });
                          },
                          onTap: () {
                            //   OpenFile.open(mediaPath);
                            final mediaFiles = [
                              ...topLevelFolders.last.images.where((image) =>
                                  image.endsWith('.png') ||
                                  image.endsWith('.jpg')),
                              ...topLevelFolders.last.video
                                  .where((video) => video.endsWith('.mp4')),
                            ];

                            final mediaIndex = mediaFiles.indexOf(mediaPath);

                            if (mediaIndex != -1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenMediaViewer(
                                    mediaPaths: mediaFiles,
                                    initialIndex: mediaIndex,
                                    onMediaDeleted: (updatedMediaPaths) {
                                      setState(() {
                                        topLevelFolders.last.images =
                                            updatedMediaPaths
                                                .where((path) =>
                                                    path.endsWith('.png') ||
                                                    path.endsWith('.jpg'))
                                                .toList();
                                        topLevelFolders.last.video =
                                            updatedMediaPaths
                                                .where((path) =>
                                                    path.endsWith('.mp4'))
                                                .toList();
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      mediaPath.endsWith('.mp4')
                                          ? FutureBuilder<String?>(
                                              future:
                                                  _generateThumbnail(mediaPath),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.transparent,
                                                    ),
                                                  );
                                                } else if (snapshot.hasError ||
                                                    snapshot.data == null) {
                                                  return const Icon(
                                                      Icons.error);
                                                } else {
                                                  return Image.file(
                                                    File(snapshot.data!),
                                                    width: 50,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  );
                                                }
                                              },
                                            )
                                          : Image.file(
                                              File(mediaPath),
                                              width: 50,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                      if (isSelecting) ...[
                                        Positioned(
                                          bottom: 15,
                                          left: 25,
                                          top: 0,
                                          right: 0,
                                          child: Checkbox(
                                            checkColor: Colors.white,
                                            tristate: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            value: selectedFiles
                                                .contains(mediaPath),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedFiles.add(mediaPath);
                                                } else {
                                                  selectedFiles
                                                      .remove(mediaPath);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    _showEditMediaNameDialog(mediaName, mediaPath);
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    child: Text(
                                      mediaName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSelectedItems() async {
    // Delete selected folders
    for (String folderTitle in selectedFolders) {
      // Find the corresponding Folder object by title
      Folder folder = topLevelFolders.firstWhere(
        (folder) => folder.title == folderTitle,
        // Handle case where folder is not found
      );

      if (folder != null) {
        await _deleteFolder(folder); // Delete the folder
      }
    }

    // Delete selected media files
    for (String file in selectedFiles) {
      await _deleteFile(file); // Delete the file
    }

    // Clear selection after deleting
    setState(() {
      isSelecting = false;
      selectedFolders.clear();
      selectedFiles.clear();
    });

    // Optionally, refresh the UI to reflect the changes
    _updateTopLevelFolders();
  }

  Future<void> _deleteFolder(Folder folder) async {
    // Logic to delete the folder and its contents

    try {
      await folderServices.deleteFolder(folder.timestamp.toString());
      _updateTopLevelFolders(); // Refresh the folder list
      print(" deleting folder: ");
      //  _showCustomSnackBar(successMessage);
    } catch (e) {
      print("Error deleting folder: $e");
      //  _showCustomSnackBar(errorMessage);
    }
  }

// Method to delete a media file (image/video)
  Future<void> _deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error deleting file: $e");
    }

    // Optionally, update the UI to reflect that the file was deleted
    setState(() {
      topLevelFolders.forEach((folder) {
        folder.images.remove(filePath);
        folder.video.remove(filePath);
      });
      topLevelFoldersAll.forEach((folder) {
        folder.images.remove(filePath);
        folder.video.remove(filePath);
      });
    });
  }

  void _showDeleteConfirmationDialog() {
    // Count total selected items (folders + media files)
    int totalSelectedItems = selectedFolders.length + selectedFiles.length;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Are you sure you want to delete?'),
          content:
              Text('You have selected $totalSelectedItems items to delete.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                // Proceed with deletion after confirmation
                Navigator.of(context).pop(); // Close the dialog
                _deleteSelectedItems(); // Perform the deletion
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _generateThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        // maxWidth: 128,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print("Error generating thumbnail: $e");
      return null; // Return null in case of error
    }
  }
}
class EmojiItem {
  const EmojiItem({
    required this.emojisName,
    required this.text,
  });

  final String emojisName;
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is EmojiItem &&
              other.emojisName == emojisName &&
              other.text == text);

  @override
  int get hashCode => emojisName.hashCode ^ text.hashCode;
}

abstract class EmojiItems {
  static const List<EmojiItem> firstItems = [emoji1, emoji2, emoji3, emoji4, emoji5, emoji6, emoji7, emoji8, emoji9, emoji10, emoji11];
  static const emoji1 = EmojiItem(emojisName: 'assets/emojis/emoji_1.png', text: 'Emoji 1');
  static const emoji2 = EmojiItem(emojisName: 'assets/emojis/emoji_2.png', text: 'Emoji 2');
  static const emoji3 = EmojiItem(emojisName: 'assets/emojis/emoji_3.png', text: 'Emoji 3');
  static const emoji4 = EmojiItem(emojisName: 'assets/emojis/emoji_4.png', text: 'Emoji 4');
  static const emoji5 = EmojiItem(emojisName: 'assets/emojis/emoji_5.png', text: 'Emoji 5');
  static const emoji6 = EmojiItem(emojisName: 'assets/emojis/emoji_6.png', text: 'Emoji 6');
  static const emoji7 = EmojiItem(emojisName: 'assets/emojis/emoji_7.png', text: 'Emoji 7');
  static const emoji8 = EmojiItem(emojisName: 'assets/emojis/emoji_8.png', text: 'Emoji 8');
  static const emoji9 = EmojiItem(emojisName: 'assets/emojis/emoji_9.png', text: 'Emoji 9');
  static const emoji10 = EmojiItem(emojisName: 'assets/emojis/emoji_10.png', text: 'Emoji 10');
  static const emoji11 = EmojiItem(emojisName: 'assets/emojis/emoji_11.png', text: 'Emoji 11');

  static Widget buildItem(EmojiItem item) {
    return Row(
      children: [
        Image.asset(item.emojisName, width: 30, height: 30,),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, EmojiItem item) {
    // switch (item) {
    //   case EmojiItems.smile:
    //   //Do something
    //     break;
    //   case EmojiItems.smile2:
    //   //Do something
    //     break;
    //   case EmojiItems.laugh:
    //   //Do something
    //     break;
    //   case EmojiItems.laughTeeth:
    //   //Do something
    //     break;
    // }
  }
}

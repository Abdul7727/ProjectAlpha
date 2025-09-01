import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaPaths;
  final int initialIndex;
  final Function(List<String>) onMediaDeleted;

  const FullScreenMediaViewer({
    Key? key,
    required this.mediaPaths,
    required this.initialIndex,
    required this.onMediaDeleted,
  }) : super(key: key);

  @override
  _FullScreenMediaViewerState createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController _pageController;
  Map<int, VideoPlayerController?> videoControllers = {};
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;

    // Check permission and initialize for the first media if it's a video
    if (widget.mediaPaths[currentIndex].endsWith('.mp4')) {
      _checkPermissionAndInitialize(currentIndex);
    }
  }

  Future<void> _checkPermissionAndInitialize(int index) async {
    if (!widget.mediaPaths[index].endsWith('.mp4')) {
      // Skip permission check for non-video files
      return;
    }

    bool permissionGranted = await _getPermissionStatus();

    if (!permissionGranted) {
      permissionGranted = await _requestPermission(Uri.parse(widget.mediaPaths[index]));
      if (permissionGranted) {
        await _savePermissionStatus(true);
      }
    }

    if (permissionGranted) {
      await _initializeVideoController(index);
    } else {
      _showPermissionDeniedMessage();
    }
  }

  Future<bool> _requestPermission(Uri uri) async {
    if(Platform.isAndroid) {

      const MethodChannel _channel = MethodChannel('com.example.mystorage/uri_permission');
      try {
        await _channel.invokeMethod('takePersistableUriPermission', uri);
      } catch (e) {
        print('Error taking persistable URI permission: $e');
      }
    //   PermissionStatus permissionStatus = await Permission.storage.status;
    //   if (permissionStatus.isGranted) {
    //     return true;
    //   }
    //   else if (permissionStatus.isDenied || permissionStatus.isRestricted) {
    //     PermissionStatus status = await Permission.storage.request();
    //     if (status.isGranted) {
    //       return true;
    //     } else {
    //       _showPermissionDeniedDialog("Permission Required",
    //           'Permission for storage is denied permanently. Please go to settings and enable it manually.');
    //       return false;
    //     }
    //   } else if (permissionStatus.isPermanentlyDenied) {
    //     _showPermissionDeniedDialog('Permission Required','Permission for storage is denied permanently. Please go to settings and enable it manually.');
    //     return false;
    //   }
    }

    return true; // Assume permission granted on iOS
  }
  void _showPermissionDeniedDialog(String title,String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('$title', style: TextStyle(
            fontFamily: 'Neue Plak',
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white)),
        content: Text('$body',
            style: TextStyle(
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

  Future<bool> _getPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('video_permission_granted') ?? false;
  }

  Future<void> _savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('video_permission_granted', granted);
  }

  Future<bool> _isAndroid11OrAbove() async {
    final androidVersion = int.tryParse(await _getAndroidVersion());
    return androidVersion != null && androidVersion >= 30;
  }

  Future<String> _getAndroidVersion() async {
    try {
      return Platform.operatingSystemVersion.split(' ')[1];
    } catch (e) {
      return "0"; // Default to 0 if unable to parse
    }
  }

  Future<bool> _openAppSettings() async {
    final result = await openAppSettings();
    return result;
  }

  Future<void> _initializeVideoController(int index) async {
    if (!widget.mediaPaths[index].endsWith('.mp4')) return;

    if (!videoControllers.containsKey(index)) {
      final videoController =
      VideoPlayerController.file(File(widget.mediaPaths[index]));
      videoControllers[index] = videoController;
      await videoController.initialize();
      setState(() {}); // Refresh UI
    }

    // Ensure video is played if it's the current index
    if (index == currentIndex) {
      videoControllers[index]?.play();
    }
  }

  void _showPermissionDeniedMessage() {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Permission denied. Cannot play the video.'),
    //     backgroundColor: Colors.red,
    //   ),
    // );
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });

    // Pause all other videos
    for (var controller in videoControllers.values) {
      controller?.pause();
    }

    // Initialize and play video if current media is a video
    if (widget.mediaPaths[currentIndex].endsWith('.mp4')) {
      _checkPermissionAndInitialize(currentIndex);
    }
  }

  void _showImageDetails() async {
    final mediaPath = widget.mediaPaths[currentIndex];
    final file = File(mediaPath);
    final fileSize = await file.length();
    final fileName = file.uri.pathSegments.last;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'File Name: $fileName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'File Size: ${(fileSize / 1024).toStringAsFixed(2)} KB',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Path: $mediaPath',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
      backgroundColor: Colors.black,
      isScrollControlled: true,
    );
  }

  void _confirmDelete() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to delete this media?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: const Text('Yes'),
              isDestructiveAction: true, // Highlights the destructive action
              onPressed: () async {
                final mediaPath = widget.mediaPaths[currentIndex];
                final file = File(mediaPath);
                if (await file.exists()) {
                  await file.delete(); // Delete the file
                  setState(() {
                    widget.mediaPaths
                        .removeAt(currentIndex); // Remove from the list
                    widget
                        .onMediaDeleted(widget.mediaPaths); // Notify the parent
                    if (currentIndex >= widget.mediaPaths.length) {
                      currentIndex =
                          widget.mediaPaths.length - 1; // Adjust index
                    }
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  if (widget.mediaPaths.isEmpty) {
                    Navigator.pop(context); // Close the viewer if no media left
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showImageDetails,
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.mediaPaths.length,
            itemBuilder: (context, index) {
              final mediaPath = widget.mediaPaths[index];
              if (mediaPath.endsWith('.mp4')) {
                final controller = videoControllers[index];
                if (controller != null && controller.value.isInitialized) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } else {
                return Center(
                  child: Image.file(
                    File(mediaPath),
                    fit: BoxFit.contain,
                  ),
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      final mediaPath = widget.mediaPaths[currentIndex];
                      final xFile = XFile(mediaPath);
                      Share.shareXFiles([xFile]);
                    },
                  ),
                  const Text("Share", style: TextStyle(color: Colors.white)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _confirmDelete,
                  ),
                  const Text("Delete", style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

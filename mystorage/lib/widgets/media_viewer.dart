import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MediaViewer extends StatefulWidget {
  final String mediaPath;

  const MediaViewer({Key? key, required this.mediaPath}) : super(key: key);

  @override
  _MediaViewerState createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late VideoPlayerController _videoController;
  bool isImage = false;
  bool isVideo = false;

  @override
  void initState() {
    super.initState();

    isImage = widget.mediaPath.endsWith('.png') || widget.mediaPath.endsWith('.jpg');
    isVideo = widget.mediaPath.endsWith('.mp4');

    if (isVideo) {
      _videoController = VideoPlayerController.file(File(widget.mediaPath))
        ..initialize().then((_) {
          setState(() {
            _videoController.play(); // Automatically play the video
          });
        });
    }
  }

  @override
  void dispose() {
    if (isVideo) {
      _videoController.dispose();
    }
    super.dispose();
  }

  void _shareMedia() {
    final xFile = XFile(widget.mediaPath);
    Share.shareXFiles([xFile], text: "Are you sure you want to share");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      floatingActionButton:IconButton(onPressed: (){_shareMedia();},icon:const Icon(Icons.share),),
      body: InkWell(
        // onTap: _shareMedia,
        child: Center(
          child: isImage
              ? Image.file(
            File(widget.mediaPath),
            fit: BoxFit.cover,
          )
              : isVideo && _videoController.value.isInitialized
              ? AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          )
              : const CircularProgressIndicator(),
        ),
      ),

      // Removed the FloatingActionButton section
    );
  }
}

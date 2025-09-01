import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/models.dart';

class FolderServices {
  late final Directory myLocalStorageDir; // Directory for local storage
  List<Folder> folders = []; // List to store folder data
  bool _permissionsGranted = false; // Track permission status

  /// Initializes the folder service, setting up the storage directory and loading existing folders.
  Future<void> initialize() async {
    try {
      await _requestPermissions(); // Request permissions once
      await _initExternalStorage();
      await loadFolders(); // Load folders on initialization
    } catch (e) {
      print("Initialization error: $e");
      throw e; // Re-throw or handle as needed
    }
  }

  /// Requests necessary permissions.
  Future<void> _requestPermissions() async {
    if (_permissionsGranted) return;

    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 33) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            throw Exception("Manage External Storage permission not granted");
          }
        }
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception("Storage permission not granted");
          }
        }
      }
    }

    _permissionsGranted = true; // Update the permissions state
  }

  /// Initializes the external storage and sets up the local storage directory.
    Future<void> _initExternalStorage() async {
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception("Unable to access external storage");
      }

      myLocalStorageDir = Directory('${externalDir.path}/MyLocalStorage');

      // Create "MyLocalStorage" if it doesn't exist
      if (!await myLocalStorageDir.exists()) {
        await myLocalStorageDir.create(recursive: true);
        print("Created MyLocalStorage at: ${myLocalStorageDir.path}");
      } else {
        print("MyLocalStorage already exists at: ${myLocalStorageDir.path}");
      }
    }

  /// Fetches the Android version.
  Future<int> _getAndroidVersion() async {
    return int.parse((await Process.run('getprop', ['ro.build.version.sdk'])).stdout.trim());
  }

  /// Loads folder data from a JSON file into the folders list.
  Future<void> loadFolders() async {
    File file = File('${myLocalStorageDir.path}/folders.json');
    if (file.existsSync()) {
      String contents = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(contents);
      folders = jsonData.map((item) => Folder.fromJson(item)).toList();
    } else {
      print("folders.json does not exist. Starting with an empty list.");
      folders = []; // Start with an empty list if the file doesn't exist
    }
  }

  /// Saves the current list of folders to a JSON file.
  Future<void> saveFolders() async {
    File file = File('${myLocalStorageDir.path}/folders.json');
    String jsonData = jsonEncode(folders.map((folder) => folder.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  /// Adds a new folder to the list and saves it.
  Future<void> addFolder(Folder folder) async {
    folder.images = []; // Initialize images as an empty list
   folders.add(folder);
    await saveFolders(); // Save after adding
    await _createDirectory(folder); // Create corresponding directory
  }

  /// Updates an existing folder and its directory name if changed.
  Future<void> updateFolder(Folder updatedFolder, String originalFolderName) async {
    int index = folders.indexWhere((folder) => folder.timestamp == updatedFolder.timestamp);
    if (index != -1) {
      folders[index] = updatedFolder;
      await saveFolders(); // Save after updating
      await _renameDirectory(updatedFolder, originalFolderName); // Rename directory if necessary
    }
  }

  /// Deletes a folder from the list and its corresponding directory.
  Future<void> deleteFolder(String folderId) async {
    Folder? folder = getFolderById(folderId);
    if (folder != null) {
      folders.remove(folder);
      await saveFolders(); // Save after deleting
      await _deleteDirectory(folder); // Delete corresponding directory
    }
  }

  /// Retrieves top-level folders based on the parent ID.
  List<Folder> getTopLevelFolders(String? parentId) {
    return folders.where((folder) => folder.parentId == parentId).toList();
  }

  /// Finds a folder by its ID.
  Folder? getFolderById(String folderId) {
    try {
      return folders.firstWhere((folder) => folder.timestamp.toString() == folderId);
    } catch (e) {
      return null; // Explicitly return null if not found
    }
  }

  /// Retrieves the current folder ID based on the folder title.
  String getCurrentFolderId(String folderTitle) {
    try {
      return folders.firstWhere((folder) => folder.title == folderTitle).timestamp.toString();
    } catch (e) {
      return ''; // Handle case where folder is not found
    }
  }

  /// Creates a directory corresponding to the Folder model.
  Future<void> _createDirectory(Folder folder) async {
    String path = _getFolderPath(folder, '');
    Directory dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      print("Created directory at: $path");
      // Print the path where images will be saved
      print("Images will be saved in: $path");
    }
  }

  /// Renames a directory if the folder title changes.
  Future<void> _renameDirectory(Folder folder, String originalFolderName) async {
    String oldPath = _getFolderPath(folder, originalFolderName, useOldName: true);
    String newPath = _getFolderPath(folder, '');

    Directory oldDir = Directory(oldPath);
    Directory newDir = Directory(newPath);

    if (await oldDir.exists()) {
      await oldDir.rename(newPath);
      print("Renamed directory from $oldPath to $newPath");
    }
  }

  /// Deletes a directory corresponding to the Folder model.
  Future<void> _deleteDirectory(Folder folder) async {
    String path = _getFolderPath(folder, '');
    Directory dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print("Deleted directory at: $path");
    }
  }

  /// Helper method to get the path of a folder, using the parent folder structure.
  String _getFolderPath(Folder folder, String originalFolderName, {bool useOldName = false}) {
    if (folder.parentId == null) {
      return '${myLocalStorageDir.path}/${useOldName ? originalFolderName : folder.title}';
    } else {
      Folder? parentFolder = getFolderById(folder.parentId!);
      if (parentFolder == null) {
        return '${myLocalStorageDir.path}/${useOldName ? originalFolderName : folder.title}';
      }
      return '${_getFolderPath(parentFolder, originalFolderName)}/${useOldName ? originalFolderName : folder.title}';
    }
  }


}



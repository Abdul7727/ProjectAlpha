class Folder {
  final String title;
  final DateTime date;
  final int timestamp;
  List<String> images;
  List<String> imageNames;
  List<String> video;
  List<String> videoNames;
  List<Folder> subFolders;
  final String? parentId;
  String? iconPath;
  bool hasImageIcon;
  bool hasVideoIcon;
  bool hasDocImageIcon;
  bool isEmpty;
  bool isDummy; // Add isDummy property
  final String emojiName;
  final String emojiText;

  Folder({
    required this.title,
    required this.date,
    required this.timestamp,
    this.images = const [],
    this.imageNames = const [],
    this.video = const [],
    this.videoNames = const [],
    this.subFolders = const [],
    this.parentId,
    this.iconPath,
    this.hasImageIcon = false,
    this.hasVideoIcon = false,
    this.hasDocImageIcon = false,
    this.isEmpty = true,
    this.isDummy = false, // Default to false to avoid null value
    required this.emojiName, // Default to false to avoid null value
    required this.emojiText, // Default to false to avoid null value
  });

  // From JSON
  factory Folder.fromJson(Map<String, dynamic> json) {
    var subFoldersFromJson = json['subFolders'] as List<dynamic>? ?? [];
    List<Folder> subFoldersList = subFoldersFromJson.map((item) => Folder.fromJson(item)).toList();

    return Folder(
      title: json['title'],
      date: DateTime.parse(json['date']),
      timestamp: json['timestamp'],
      images: List<String>.from(json['images'] ?? []),
      imageNames: List<String>.from(json['imageNames'] ?? []),
      video: List<String>.from(json['video'] ?? []),
      videoNames: List<String>.from(json['videoNames'] ?? []),
      subFolders: subFoldersList,
      parentId: json['parentId'],
      iconPath: json['iconPath'],
      hasImageIcon: json['hasImageIcon'] ?? false,
      hasVideoIcon: json['hasVideoIcon'] ?? false,
      hasDocImageIcon: json['hasDocImageIcon'] ?? false,
      isEmpty: json['isEmpty'] ?? true,
      isDummy: json['isDummy'] ?? false,
      emojiName: json['emojiName'],// Ensure isDummy is set, default to false if null
      emojiText: json['emojiText'],// Ensure isDummy is set, default to false if null
    );
  }

  // To JSON
  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
    'timestamp': timestamp,
    'images': images,
    'imageNames': imageNames,
    'video': video,
    'videoNames': videoNames,
    'subFolders': subFolders.map((folder) => folder.toJson()).toList(),
    'parentId': parentId,
    'iconPath': iconPath,
    'hasImageIcon': hasImageIcon,
    'hasVideoIcon': hasVideoIcon,
    'hasDocImageIcon': hasDocImageIcon,
    'isEmpty': isEmpty,
    'isDummy': isDummy,
    'emojiName': emojiName,// Include isDummy in JSON
    'emojiText': emojiText,// Include isDummy in JSON
  };
}


import 'package:flutter/material.dart';
import 'package:mystorage/pages/home_page.dart';

void main() async{

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foto-Nizer',
      home: HomePage()
      // home:NavBar()
    );
  }
}
/*
1.multi delete option
2.means kisi image or video or folder icon pe long press karo ga tou tick wala system aye ga then multi select kar ke kahe delete icon aa jae ga
3.its showing like IMG_17310... so max 2 lines kar do so jo first line mai nazar nahi aye ga wo 2nd line mai chala jae ga and agar 2nd line mai bhi pura name nazar nahi aye tou end pe beshak ... dots aa jae
 */
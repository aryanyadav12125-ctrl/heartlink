import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDRkqtbH27Uk6blN_lEVugt931g8F67y5Y",
      appId: "1:350458505598:android:heartlink",
      messagingSenderId: "350458505598",
      projectId: "heartlink-9c8f7",
      databaseURL: "https://heartlink-9c8f7-default-rtdb.firebaseio.com",
      storageBucket: "heartlink-9c8f7.firebasestorage.app",
    ),
  );
  runApp(const HeartLinkApp());
}

class HeartLinkApp extends StatelessWidget {
  const HeartLinkApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF0607A)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        backgroundColor: Color(0xFF0C0610),
        body: Center(
          child: Text(
            '💕 HeartLink',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
        ),
      ),
    );
  }
}

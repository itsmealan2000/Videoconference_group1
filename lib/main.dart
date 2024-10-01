import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:videoconference/auth/auth_page.dart';
import 'package:videoconference/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:videoconference/Theme/theme.dart';
import 'package:videoconference/Theme/themeprovidor.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Run the app with theme provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialTheme: lightTheme), 
      child: const MyApp(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Video Conference App',
      theme: themeProvider.getTheme, 
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}

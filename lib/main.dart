import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 FIREBASE INIT
  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 PORTRAIT MODE
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 🔥 STATUS BAR
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      Brightness.light,
    ),
  );

  runApp(const TutorApp());
}

class TutorApp extends StatelessWidget {

  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Marc Digital Campus',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.theme,

      home: const SplashScreen(),
    );
  }
}
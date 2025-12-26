import 'package:digislips/app/routes/app_pages.dart';
import 'package:digislips/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('uid');

  runApp(MyApp(isLoggedIn: uid != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DigiSlips',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.SPLASH, // Splash is first screen on app start
      getPages: AppPages.routes,
      // other properties like theme, locale, etc.
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
  await Permission.location.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Controller',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
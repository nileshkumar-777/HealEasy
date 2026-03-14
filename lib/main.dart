import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healeasy/loading.dart';
import 'package:healeasy/login.dart';
import 'package:healeasy/screens/visit_list_screen.dart';
import 'package:healeasy/screens/create_visit_screen.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive (local database)
  await Hive.initFlutter();

  // Open box for storing visits
  await Hive.openBox('visits');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sales Logger",
      theme: ThemeData(primarySwatch: Colors.red),

      // App Routes
      routes: {
        "/visits": (context) => const VisitLogsScreen(),
        "/createVisit": (context) => const CreateVisitLogScreen(),
      },

      home: _isLoading ? const HopeLoadingScreen() : const MainScreen(),
    );
  }
}

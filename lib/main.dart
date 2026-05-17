// import 'package:flutter/material.dart';
// import 'screens/control.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'screens/login.dart';

// void main() async {
// WidgetsFlutterBinding.ensureInitialized();
// await Supabase.initialize(
//   url: 'https://uvnmmqzifbjmnoniqxsx.supabase.co',
//   anonKey: 'sb_publishable_U4eQaKrmETmn9Fn1jBcbww_yuJG9zi5',
// );
//   runApp(const MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final session = Supabase.instance.client.auth.currentSession;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: session == null ? const LoginScreen() : const MapScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/control.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("🔥 FLUTTER ERROR: ${details.exception}");
    debugPrint("🔥 STACK: ${details.stack}");
  };

  await Supabase.initialize(
    url: 'https://uvnmmqzifbjmnoniqxsx.supabase.co',
    anonKey: 'sb_publishable_U4eQaKrmETmn9Fn1jBcbww_yuJG9zi5',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MapScreen(),
      theme: ThemeData(
        brightness: Brightness.light,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade700,
          secondary: Colors.blueAccent,
        ),

        primaryColor: Colors.blue.shade700,
      ),
    );
  }
}

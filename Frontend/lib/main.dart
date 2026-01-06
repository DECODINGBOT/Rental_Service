import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/main_shell.dart';
import 'package:sharing_items/screens/login_screen.dart';

import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';
import 'package:sharing_items/src/service/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final user = context.read<AuthService>().currentUser();
    final user = context.watch<AuthService>().currentUser();
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NanumSquareRound'),
      home: user == null ? LoginPage() : MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

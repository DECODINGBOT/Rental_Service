import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sharing_items/main_shell.dart';
import 'package:sharing_items/screens/login_screen.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';
import 'package:sharing_items/src/service/product_provider.dart';
import 'package:sharing_items/src/service/product_service.dart';
import 'package:sharing_items/src/service/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProxyProvider<AuthService, ProductProvider>(
            create: (_) => ProductProvider(ProductService(http.Client())), /// 임시
            update: (_, auth, productProvider){
              productProvider!.setService(ProductService(auth.client));
              return productProvider;
            },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return MaterialApp(
      theme: ThemeData(fontFamily: 'NanumSquareRound'),
      home: auth.isLoggedIn ? const MainShell() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

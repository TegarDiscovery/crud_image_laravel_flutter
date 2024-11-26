import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';
// import 'screens/create_product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProductListScreen(),
        // '/create': (context) => const ProductFormScreen(),
      },
    );
  }
}

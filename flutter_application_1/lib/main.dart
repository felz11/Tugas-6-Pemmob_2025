import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/produk_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Open directly to ProdukPage
      home: const ProdukPage(),
    );
  }
}

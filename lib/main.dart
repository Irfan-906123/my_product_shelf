import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favourites_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Favourites()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Product Shelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BDB)),
        scaffoldBackgroundColor: Colors.white,
      ),
      // Temporary screen. We replace it with MainShell in Step 5.
      home: const Scaffold(
        body: Center(child: Text('My Shelf')),
      ),
    );
  }
}

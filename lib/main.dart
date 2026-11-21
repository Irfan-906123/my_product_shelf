import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favourites_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/main_shell.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  // Needed because we use plugins (shared_preferences) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved name and favourites before the first frame, so the app
  // opens with the stored data already in place.
  final storage = StorageService();
  final favourites = Favourites(storage);
  final profile = ProfileProvider(storage);
  await Future.wait([favourites.load(), profile.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => favourites),
        ChangeNotifierProvider(create: (_) => profile),
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
      home: const MainShell(),
    );
  }
}

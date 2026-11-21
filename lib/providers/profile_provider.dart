import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

// Holds the saved display name, shared by Home ("Hello, ...") and Profile.
class ProfileProvider extends ChangeNotifier {
  final StorageService _storage;

  ProfileProvider(this._storage);

  String _name = '';

  String get name => _name;

  // Read the name from local storage (called once when the app starts).
  Future<void> load() async {
    try {
      _name = await _storage.loadName();
      notifyListeners();
    } catch (e) {
      debugPrint('ProfileProvider: could not load name: $e');
    }
  }

  // Write to storage first, so "Profile saved" is only shown if it worked.
  Future<void> saveName(String name) async {
    await _storage.saveName(name);
    _name = name;
    notifyListeners();
  }
}

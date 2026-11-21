import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _primary = Color(0xFF3B5BDB);

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Owned by this screen, so we dispose it.
  late final TextEditingController _nameController;

  // Local UI state -> setState. The photo preview resets after a restart.
  String? _photoPath;
  bool _isPicking = false;
  bool _isSaving = false;
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    // read (not watch): we only need the current value once, to fill the field.
    _nameController = TextEditingController(
      text: context.read<ProfileProvider>().name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_isPicking) return; // the picker is already open
    _isPicking = true;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
      if (!mounted) return;
      // null means the user cancelled -> keep the existing photo.
      if (picked == null) return;
      setState(() {
        _photoPath = picked.path;
      });
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the gallery.')),
      );
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // close the keyboard
    // read: an action callback only calls a method, it does not listen.
    final profile = context.read<ProfileProvider>();

    setState(() {
      _isSaving = true;
      _showSaved = false;
    });

    try {
      await profile.saveName(_nameController.text.trim());
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _showSaved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the name. Try again.')),
      );
    }
  }

  // "Aslam Ali" -> "AA", "Irfan" -> "I", "" -> "".
  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    // watch: the avatar initials follow the saved name.
    final savedName = context.watch<ProfileProvider>().name;

    return SafeArea(
      // Scrollable, so the open keyboard does not cause an overflow.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My profile',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(child: _buildAvatar(savedName)),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickPhoto,
                  child: const Text(
                    'Change profile photo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Display name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                maxLength: 30,
                onChanged: (_) {
                  // The name was edited again -> hide the old "saved" message.
                  if (_showSaved) {
                    setState(() {
                      _showSaved = false;
                    });
                  }
                },
                onFieldSubmitted: (_) => _saveProfile(),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) return 'Enter a name';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Your name',
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF3F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isSaving ? 'Saving...' : 'Save profile'),
              ),
              if (_showSaved) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Profile saved',
                    style: TextStyle(
                      color: Color(0xFF2B7A4B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Name is saved on this device.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stack + Positioned: camera button on top of the avatar.
  Widget _buildAvatar(String name) {
    final initials = _initials(name);

    return Stack(
      children: [
        Container(
          width: 112,
          height: 112,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFFE3E8F2),
            shape: BoxShape.circle,
          ),
          child: _photoPath != null
              ? Image.file(
                  File(_photoPath!),
                  fit: BoxFit.cover,
                  // Unreadable file -> fall back to the placeholder.
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(initials),
                )
              : _buildPlaceholder(initials),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: _primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _pickPhoto,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Initials if there is a name, otherwise a person icon.
  Widget _buildPlaceholder(String initials) {
    return Center(
      child: initials.isEmpty
          ? const Icon(Icons.person, size: 56, color: _primary)
          : Text(
              initials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
    );
  }
}

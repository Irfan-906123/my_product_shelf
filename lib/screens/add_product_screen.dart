import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('AddProductScreen: initState');
  }

  @override
  void dispose() {
    debugPrint('AddProductScreen: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AddProductScreen: build');

    return Scaffold(
      // The AppBar adds the back arrow for us.
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Add product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        // Scrollable, so the keyboard can never hide the button later.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Demo request" chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Demo request',
                  style: TextStyle(
                    color: Color(0xFF3B5BDB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // The form fields and the Send button come in the next step.
            ],
          ),
        ),
      ),
    );
  }
}

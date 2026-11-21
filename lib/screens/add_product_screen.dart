import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // The key lets us reach the Form and run all validators with one call.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // A controller holds the text the user types in a field.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final ApiService _api = ApiService();

  // Form submission state is local UI state -> setState.
  bool _isSending = false;
  int? _createdId; // set after a successful POST
  String? _error; // set after a failed POST

  @override
  void initState() {
    super.initState();
    debugPrint('AddProductScreen: initState');
  }

  @override
  void dispose() {
    debugPrint('AddProductScreen: dispose');
    // We created the controllers, so we must dispose them.
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // A validator returns an error text, or null when the value is fine.
  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    if (title.isEmpty) return 'Enter a product title';
    if (title.length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? _validatePrice(String? value) {
    // tryParse gives null when the text is not a number.
    final price = double.tryParse((value ?? '').trim());
    // isFinite rejects "Infinity" and "NaN", which tryParse accepts.
    if (price == null || !price.isFinite) return 'Enter a valid price';
    if (price <= 0) return 'Price must be greater than zero';
    return null;
  }

  Future<void> _submit() async {
    // A second tap while a request is running is ignored.
    if (_isSending) return;

    // validate() runs every validator and shows errors under the fields.
    // It returns false if any field is invalid.
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // close the keyboard

    // Start loading and clear the old result.
    setState(() {
      _isSending = true;
      _createdId = null;
      _error = null;
    });

    try {
      final id = await _api.addProduct(
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );
      if (!mounted) return; // screen closed while waiting? stop.
      setState(() {
        _createdId = id;
        _isSending = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // The text fields are not cleared, so the user can try again.
      setState(() {
        _error = e.message;
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isSending = false;
      });
    }
  }

  // Green box for success, red box for failure.
  Widget _buildResultBox({
    required Color background,
    required Color textColor,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  // Same grey rounded style for both fields.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
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
          // Form groups the fields so we can validate them all together.
          child: Form(
            key: _formKey,
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
                const Text(
                  'Product title',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  // "next" moves the cursor to the price field.
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  decoration: _inputDecoration('Travel mug'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Price (USD)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  // Number keyboard with a decimal point.
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  // "done" on the keyboard sends the form too.
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validatePrice,
                  decoration: _inputDecoration('19.99'),
                ),
                const SizedBox(height: 24),
                // SizedBox with infinite width makes the button full width.
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // null disables the button while the request is running.
                    onPressed: _isSending ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isSending ? 'Sending...' : 'Send request'),
                  ),
                ),
                if (_createdId != null) ...[
                  const SizedBox(height: 16),
                  _buildResultBox(
                    background: const Color(0xFFEAF5EE),
                    textColor: const Color(0xFF2B7A4B),
                    title: 'Demo request successful',
                    message: 'Product ID: $_createdId',
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _buildResultBox(
                    background: const Color(0xFFFDECEC),
                    textColor: const Color(0xFFB3261E),
                    title: 'Request failed',
                    message:
                        '$_error\nYour input is kept. '
                        'Tap Send request to try again.',
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'This demo does not permanently add a product to the '
                  'catalogue.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pinController = TextEditingController();
  String _errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Enter PIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'PIN',
                border: const OutlineInputBorder(),
                errorText: _errorText.isNotEmpty ? _errorText : null,
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              onChanged: (value) {
                if (value.length == 4) {
                  _login(value);
                } else {
                  setState(() => _errorText = '');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(String pin) async {
    final success = await ref.read(authProvider.notifier).login(pin);
    if (!success) {
      setState(() {
        _errorText = 'Incorrect PIN';
        _pinController.clear();
      });
    }
  }
}

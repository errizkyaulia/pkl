// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Import the 'dart:io' library for SocketException
import 'package:http/http.dart' as http;
import 'dashboard_page.dart';
import 'config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Add a boolean to track whether the login process is in progress
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true; // Set loading to true when login starts
      _errorMessage = ''; // Clear any previous error message
    });

    try {
      final response = await http.post(
        Uri.parse(AppConfig.apiUrl),
        body: {
          'username_email': usernameController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Login successful
          if (data['user_type'] == 'user' || data['user_type'] == 'admin') {
            // Navigate to dashboard
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        } else {
          // Login failed
          setState(() {
            _errorMessage = data['error_message'] ?? 'Unknown error';
          });
        }
      } else {
        // Handle server error
        setState(() {
          _errorMessage = 'Server returned error: ${response.statusCode}';
        });
        // print('Server returned error: ${response.statusCode}');
      }
    } on SocketException {
      // Handle network errors (e.g., host lookup failure)
      setState(() {
        _errorMessage = 'Failed to connect';
      });
      // print('Failed to connect: ${e.message}');
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when login completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 8.0),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _login(context),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: LoginPage(),
  ));
}
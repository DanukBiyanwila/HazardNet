import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/constants.dart';

import 'package:frontend/pages/hidden_calculator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkHelpTrigger);
    _passwordController.addListener(_checkHelpTrigger);
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(onResult: (result) {
          if (result.recognizedWords.toLowerCase().contains('help')) {
            _openHiddenCalculator();
          }
        });
      }
    } catch (e) {
      debugPrint('STT Error: $e');
    }
  }

  void _checkHelpTrigger() {
    if (_emailController.text.toLowerCase() == 'help' || 
        _passwordController.text.toLowerCase() == 'help') {
      _openHiddenCalculator();
    }
  }

  void _openHiddenCalculator() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HiddenCalculator()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${AppConstants.baseUrl.trim()}/api/user/login');
    print('Attempting login at: $url');
    
    final Map<String, String> loginData = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];
        
        // Try to find user ID using multiple common keys and nested objects
        dynamic rawUserId = responseData['id'] ?? responseData['userId'] ?? responseData['user_id'];
        
        // If not found at top level, check inside a 'user' object if it exists
        if (rawUserId == null && responseData['user'] != null) {
          rawUserId = responseData['user']['id'] ?? responseData['user']['userId'] ?? responseData['user']['user_id'];
        }
        
        // If still null, default to 1 as a last resort (consider if this is desired)
        final int userId = rawUserId != null ? int.parse(rawUserId.toString()) : 1;
        
        print('Logged in user ID: $userId'); // Debug print

        // Save token and userId to secure storage
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_id', value: userId.toString());
        
        // Also save to shared preferences for backward compatibility if needed, 
        // but prefer secure storage for sensitive data.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else if (response.statusCode == 403) {
        _showErrorDialog('Invalid email or password');
      } else {
        _showErrorDialog('Login Failed: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error connecting to server: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  size: 100,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to HazardNet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _goToRegister,
                  child: const Text('New user? Register now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

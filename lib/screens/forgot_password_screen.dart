import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final Client client =
      Client()
        ..setEndpoint('https://cloud.appwrite.io/v1')
        ..setProject('6812f68d003e629ec1fc');

  final Account account = Account(
    Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6812f68d003e629ec1fc'),
  );

  final TextEditingController emailController = TextEditingController();

  Future<void> sendPasswordResetEmail() async {
    try {
      await account.createRecovery(
        email: emailController.text,
        url:
            'https://your-app.com/reset-password', // ✅ Replace with your actual reset password page
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Password reset link sent to your email.')),
      );
    } catch (e) {
      print('❌ Forgot Password Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to send reset email. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Enter your email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendPasswordResetEmail,
              child: Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}

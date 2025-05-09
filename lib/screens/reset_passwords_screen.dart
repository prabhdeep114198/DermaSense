import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String userId;
  final String secret;

  const ResetPasswordScreen({
    super.key,
    required this.userId,
    required this.secret,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final Client client =
      Client()
        ..setEndpoint('https://cloud.appwrite.io/v1')
        ..setProject('6812f68d003e629ec1fc');

  final Account account = Account(
    Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6812f68d003e629ec1fc'),
  );

  final TextEditingController newPasswordController = TextEditingController();

  Future<void> resetPassword() async {
    try {
      await account.updateRecovery(
        userId: widget.userId,
        secret: widget.secret,
        password: newPasswordController.text,
        passwordAgain: newPasswordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Password reset successful. You can now log in.'),
        ),
      );
    } catch (e) {
      print('Reset Password Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}

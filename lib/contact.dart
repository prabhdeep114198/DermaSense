import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _result = "";

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _result = "Sending...";
    });

    final uri = Uri.parse("https://api.web3forms.com/submit");
    final response = await http.post(
      uri,
      body: {
        "access_key":
            "9505151e-b184-4fca-bbaf-a715273d7d37", // Replace with your Web3Forms access key
        "name": _nameController.text,
        "email": _emailController.text,
        "message": _messageController.text,
      },
    );

    final data = jsonDecode(response.body);

    if (data["success"]) {
      setState(() {
        _result = "Form Submitted Successfully!";
      });

      // Delay for user to see the success message before clearing
      Future.delayed(const Duration(seconds: 1), () {
        _resetForm();
      });
    } else {
      setState(() {
        _result = "Error: ${data['message']}";
      });
    }
  }

  // Clears the form & navigates with a transition
  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ContactPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator:
                        (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            value!.isEmpty ? "Enter a valid email" : null,
                  ),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: "Message"),
                    maxLines: 5,
                    validator:
                        (value) => value!.isEmpty ? "Enter your message" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(color: Colors.green, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

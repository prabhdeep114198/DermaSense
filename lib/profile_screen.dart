import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';

import '../mainpage.dart';
import '../services/appwrite_service.dart';
import 'contact.dart'; // Import ContactPage

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppwriteService _appwriteService = AppwriteService();
  models.User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch logged-in user data
  Future<void> _fetchUserData() async {
    try {
      models.User user = await _appwriteService.getUser();
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      print("❌ Error fetching user data: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    await _appwriteService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111), // Dark theme background
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal, // Theme color
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
              : _user != null
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔹 Profile Image or Initials
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        _user!.name.isNotEmpty
                            ? _user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 User Details Card
                    Card(
                      color: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "User Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            const Divider(color: Colors.white30),
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.teal,
                              ),
                              title: Text(
                                _user!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.email,
                                color: Colors.teal,
                              ),
                              title: Text(
                                _user!.email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🔹 Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 Contact Us Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, // Contact button color
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.contact_mail,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Contact Us",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const Center(
                child: Text(
                  "Failed to load user data.",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
    );
  }
}

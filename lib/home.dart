import 'package:flutter/material.dart';

import '../widgets/custom_nav_bar.dart'; // Custom Bottom NavBar
import 'chatbot_screen.dart';
import 'profile_screen.dart'; // Import the Profile Screen
import 'report_screen.dart'; // DiseasePrediction screen
import 'skin_recommendation_page.dart'; // Correct page name

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeContent(), // Home page with profile header
      ChatbotScreen(),
      DiseasePrediction(), // Disease Prediction screen
      SkinRecommendationPage(), // Correct page name (Skin Recommendation)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔝 Profile Avatar Header with GestureDetector
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Welcome to Skin Disease Assistant',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          const Text(
            'An AI-powered application designed to help you detect potential skin diseases using image analysis.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          const Text(
            'Features:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),

          const FeatureItem(
            icon: Icons.camera_alt_outlined,
            title: 'AI-Powered Skin Analysis',
            description:
                'Upload an image of your skin condition and receive AI-based analysis.',
          ),
          const FeatureItem(
            icon: Icons.medical_services_outlined,
            title: 'Skin Disease Prediction',
            description:
                'Get alternative predictions and in-depth information about skin diseases.',
          ),
          const FeatureItem(
            icon: Icons.chat_bubble_outline,
            title: 'Chatbot Assistance',
            description:
                'Interact with our AI chatbot for guidance and medical insights.',
          ),
          const FeatureItem(
            icon: Icons.favorite_border,
            title: 'Skin Care Recommendation',
            description:
                'Receive personalized skincare routines and product suggestions.',
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Navigate to chatbot screen
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DermaSense',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to ProfileScreen (when profile is tapped)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/profile.png'),
                radius: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 1,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Feature item widget
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
    );
  }
}

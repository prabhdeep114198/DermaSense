import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF111111),
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.white60,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Home'),
        BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Chatbot'),
        BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: 'Skin Disease Prediction',
        ),
        BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: 'Skincare', // ✅ Renamed from "Profile"
        ),
      ],
      selectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
    );
  }
}

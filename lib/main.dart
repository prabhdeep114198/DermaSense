import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import 'chatbot_screen.dart';
import 'home.dart'; // Home Page (after login)
import 'mainpage.dart'; // Welcome Screen
import 'profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DermaSenseApp());
}

class DermaSenseApp extends StatelessWidget {
  const DermaSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(), // Handles authentication & redirects
      routes: {
        '/main': (context) => const MainPage(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomePage(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}

// Authentication Gateway: Redirects Users Based on Login Status
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AppwriteService _appwriteService = AppwriteService();
  bool _isAuthenticated = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      _isAuthenticated = await _appwriteService.checkSession();
    } catch (e) {
      debugPrint("Error checking login status: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }
    return _isAuthenticated ? const HomePage() : const MainPage();
  }
}

//  Appwrite Authentication Service
class AppwriteService {
  final Client client =
      Client()
        ..setEndpoint('https://cloud.appwrite.io/v1')
        ..setProject(
          '66cae4db000a272452f1',
        ); // Replace with your Appwrite Project ID

  final Account account;

  AppwriteService()
    : account = Account(
        Client()
          ..setEndpoint('https://cloud.appwrite.io/v1')
          ..setProject('66cae4db000a272452f1'),
      );

  Future<bool> checkSession() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }
}

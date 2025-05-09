import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final List<String> _sessionList = [];
  String? _currentSessionId;
  bool _loading = false;
  bool _sidebarVisible = false;

  final String _backendUrl = "http://192.168.29.35:5000/chat";

  final Client _client = Client();
  late Databases _database;

  final String _projectId = '6812f68d003e629ec1fc';
  final String _databaseId = '681ba2cb0018ac659ab4';
  final String _collectionId = '681ba2e90033571e8909';

  @override
  void initState() {
    super.initState();
    _client
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject(_projectId);
    _database = Databases(_client);
    _startNewSession();
    _fetchSessionList();
  }

  Future<void> _startNewSession() async {
    final newSessionId = ID.unique().toString();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      await _database.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: newSessionId,
        data: {
          'sessionId': newSessionId,
          'messages': jsonEncode([]),
          'timestamp': timestamp,
        },
      );
      setState(() {
        _currentSessionId = newSessionId;
        _messages.clear();
      });
      await _fetchSessionList();
    } catch (e) {
      debugPrint("Session creation error: $e");
    }
  }

  Future<void> _fetchSessionList() async {
    try {
      final response = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
        queries: [Query.orderDesc("timestamp")],
      );
      setState(() {
        _sessionList.clear();
        _sessionList.addAll(
          response.documents.map((doc) => doc.data['sessionId'] as String),
        );
      });
    } catch (e) {
      debugPrint("Error fetching session list: $e");
    }
  }

  Future<void> _loadSession(String sessionId) async {
    try {
      final document = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: sessionId,
      );

      final rawJson = document.data['messages'] as String;
      final messages = List<Map<String, String>>.from(jsonDecode(rawJson));

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
        _currentSessionId = sessionId;
        _sidebarVisible = false;
      });
    } catch (e) {
      debugPrint("Error loading session: $e");
    }
  }

  Future<void> _sendMessage() async {
    final String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    if (_currentSessionId == null) {
      await _startNewSession();
    }

    setState(() {
      _messages.add({"user": userMessage});
      _loading = true;
      _messageController.clear();
    });

    final userEntry = {"role": "user", "content": userMessage};
    await _updateSessionMessages(userEntry);

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": userMessage}),
      );

      String botReply = "I'm not sure.";
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        botReply = responseBody["answer"] ?? botReply;
      }

      setState(() {
        _messages.add({"bot": botReply});
        _loading = false;
      });

      await _updateSessionMessages({"role": "bot", "content": botReply});
    } catch (e) {
      final err = "Network error: $e";
      setState(() {
        _messages.add({"bot": err});
        _loading = false;
      });
      await _updateSessionMessages({"role": "bot", "content": err});
    }
  }

  Future<void> _updateSessionMessages(Map<String, String> newMessage) async {
    if (_currentSessionId == null) return;

    try {
      final document = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _currentSessionId!,
      );

      List<dynamic> existingMessages = [];
      if (document.data['messages'] != null &&
          document.data['messages'] is String) {
        existingMessages = jsonDecode(document.data['messages']);
      }

      existingMessages.add(newMessage);

      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: _currentSessionId!,
        data: {
          "messages": jsonEncode(existingMessages), // ✅ Correct
        },
      );
    } catch (e) {
      debugPrint("Message update error: $e");
    }
  }

  Widget _buildMessageBubble(Map<String, String> message, bool isUser) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      color: isUser ? Colors.grey.shade900 : Colors.grey.shade800,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser ? Colors.blueAccent : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.values.first,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("AI Chatbot"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => setState(() => _sidebarVisible = !_sidebarVisible),
          ),
        ],
      ),
      body: Row(
        children: [
          if (_sidebarVisible)
            Container(
              width: 250,
              color: Colors.grey.shade800,
              child: ListView(
                children: [
                  ListTile(
                    title: const Text(
                      "+ New Chat",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      await _startNewSession();
                    },
                  ),
                  ..._sessionList.map(
                    (sessionId) => ListTile(
                      title: Text(
                        sessionId.substring(0, 10),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => _loadSession(sessionId),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final bool isUser = message.containsKey("user");
                      return _buildMessageBubble(message, isUser);
                    },
                  ),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.grey.shade800,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

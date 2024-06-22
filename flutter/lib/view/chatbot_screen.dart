import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': message});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.6:5005/webhooks/rest/webhook'), // Your Rasa server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sender': 'user', 'message': message}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        for (var responseMessage in responseData) {
          setState(() {
            _messages.add({
              'sender': 'bot',
              'message': responseMessage['text'] ?? '',
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': 'Error: Could not connect to the server',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message': 'Error: ${e.toString()}',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0F46),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['sender'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'user'
                            ? Color.fromARGB(248, 255, 255, 255)
                            : Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message'] ?? '',
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white), // Add border color
                      ),
                      fillColor: Color.fromARGB(248, 255, 255, 255), // Change text field color
                      filled: true, // Fill the text field with color
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                  color: Color.fromARGB(255, 255, 255, 255), // Change icon color
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

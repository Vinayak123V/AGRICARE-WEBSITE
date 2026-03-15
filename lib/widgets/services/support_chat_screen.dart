// lib/widgets/support_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String appId;

  const SupportChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.appId,
  });

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Reference to the chat messages collection for this user
  late final CollectionReference _chatCollection;

  @override
  void initState() {
    super.initState();
    // Path: artifacts/appId/chats/userId/messages
    _chatCollection = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(widget.appId)
        .collection('chats')
        .doc(widget.userId)
        .collection('messages');

    // Auto-scroll when new message arrives (optional but good for UX)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Clear text field immediately
    _messageController.clear();

    try {
      await _chatCollection.add({
        'text': text,
        'senderId': widget.userId,
        'senderName': widget.userName,
        'timestamp': FieldValue.serverTimestamp(),
        'isSupport': false, // Message from the user (farmer)
      });

      // Add a mock support response for realism (optional)
      await Future.delayed(const Duration(seconds: 1));
      _sendMockSupportResponse(text);

      // Scroll to bottom after sending
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent +
            100, // Add buffer for new message
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  void _sendMockSupportResponse(String userMessage) {
    String response;
    if (userMessage.toLowerCase().contains('booking')) {
      response =
          "Thank you for inquiring about your booking! Please provide your booking ID, and a representative will check the status shortly.";
    } else if (userMessage.toLowerCase().contains('help')) {
      response =
          "Hello, I'm the AgriCare support bot. How can I assist you with our services, AI tools, or any technical issue today?";
    } else {
      response =
          "We have received your message and will connect you with a live agent within 5 minutes. Thank you for your patience!";
    }

    _chatCollection.add({
      'text': response,
      'senderId': 'support',
      'senderName': 'AgriCare Support',
      'timestamp': FieldValue.serverTimestamp(),
      'isSupport': true, // Message from support
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        backgroundColor: const Color(0xFF047857),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatCollection
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading chat.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Prompt the user to start the conversation
                  return const Center(
                    child: Text(
                      'Start a conversation with AgriCare Support!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isMe = data['isSupport'] == false;

                    return _buildMessageBubble(
                      data['text'] ?? '',
                      isMe,
                      data['senderName'] ?? 'Unknown',
                    );
                  },
                );
              },
            ),
          ),
          _buildInputComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String senderName) {
    // Determine alignment and colors
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? const Color(0xFF059669) : Colors.grey.shade200;
    final textColor = isMe ? Colors.white : Colors.black87;
    final senderColor = isMe ? Colors.white70 : Colors.grey.shade600;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              isMe ? 'You' : senderName,
              style: TextStyle(fontSize: 12, color: senderColor),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12.0),
              topRight: const Radius.circular(12.0),
              bottomLeft: isMe
                  ? const Radius.circular(12.0)
                  : const Radius.circular(0.0),
              bottomRight: isMe
                  ? const Radius.circular(0.0)
                  : const Radius.circular(12.0),
            ),
            elevation: 2.0,
            color: color,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF047857), size: 30),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

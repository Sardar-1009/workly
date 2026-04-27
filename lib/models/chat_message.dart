import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String text;
  final DateTime timestamp;
  final String senderId; // Replaces isMe, can compare with current user ID
  final bool isSystemMessage; // e.g. "Resume Sent" or "Interview Scheduled"

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.timestamp,
    required this.senderId,
    this.isSystemMessage = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderId: data['senderId'] ?? '',
      isSystemMessage: data['isSystemMessage'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderId': senderId,
      'isSystemMessage': isSystemMessage,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of conversations for the user
  Stream<List<ChatConversation>> getUserConversations(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ChatConversation.fromFirestore(doc))
          .toList();
      // Sort locally to avoid requiring a composite index in Firebase
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  // Stream of messages for a single conversation
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: conversationId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
      // Sort locally to avoid requiring a composite index in Firebase
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  // Send a message
  Future<void> sendMessage(
    String conversationId,
    String text,
    String senderId, {
    bool isSystemMessage = false,
  }) async {
    final messageRef = _firestore
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: messageRef.id,
      chatId: conversationId,
      text: text,
      timestamp: DateTime.now(),
      senderId: senderId,
      isSystemMessage: isSystemMessage,
    );

    // Run in transaction to update last message info too
    await _firestore.runTransaction((transaction) async {
      final convoRef = _firestore.collection('chats').doc(conversationId);
      
      transaction.set(messageRef, message.toFirestore());
      
      // Update parent conversation
      transaction.update(convoRef, {
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        // Increment unread count for employer
        'unreadCountEmployer': FieldValue.increment(1),
      });
    });
  }

  // Mark conversation as read for the current user
  Future<void> markAsRead(String conversationId) async {
    await _firestore.collection('chats').doc(conversationId).update({
      'unreadCountUser': 0,
    });
  }
}

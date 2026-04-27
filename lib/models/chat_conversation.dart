import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final String userId;
  final String employerId;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime lastMessageTime;

  // UI-specific transient properties (may be fetched separately or cached locally)
  final String employerName;
  final String companyName;
  final String employerAvatarUrl;
  final int unreadCountUser;
  final int unreadCountEmployer;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.employerId,
    required this.createdAt,
    required this.lastMessage,
    required this.lastMessageTime,
    this.employerName = 'Employer',
    this.companyName = 'Company',
    this.employerAvatarUrl = 'https://i.pravatar.cc/150?img=11',
    this.unreadCountUser = 0,
    this.unreadCountEmployer = 0,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      userId: data['userId'] ?? '',
      employerId: data['employerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'] ?? data['lastMessageText'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      
      // Attempt to load extra fields if they exist, otherwise default
      employerName: data['employerName'] ?? 'Employer',
      companyName: data['companyName'] ?? 'Company Name',
      employerAvatarUrl: data['employerAvatarUrl'] ?? 'https://i.pravatar.cc/150?img=11',
      unreadCountUser: data['unreadCountUser'] ?? 0,
      unreadCountEmployer: data['unreadCountEmployer'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'employerId': employerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final String userId;
  final String employerId;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime lastMessageTime;

  // Employer / company data stored directly in the chat document by the web dashboard
  final String employerName;
  final String companyName;
  final String companyLogo; // can be a base64 data URL or a network URL, empty = use icon

  // Legacy avatar URL (kept for backwards compat, prefer companyLogo)
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
    this.companyName = '',
    this.companyLogo = '',
    this.employerAvatarUrl = '',
    this.unreadCountUser = 0,
    this.unreadCountEmployer = 0,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // companyLogo written by web dashboard
    final companyLogo = (data['companyLogo'] as String? ?? '').trim();

    // fall back to legacy employerAvatarUrl
    final avatarUrl = (data['employerAvatarUrl'] as String? ?? '').trim();

    return ChatConversation(
      id: doc.id,
      userId: data['userId'] ?? '',
      employerId: data['employerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'] ?? data['lastMessageText'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      employerName: data['employerName'] ?? 'Employer',
      companyName: data['companyName'] ?? '',
      companyLogo: companyLogo,
      employerAvatarUrl: avatarUrl,
      unreadCountUser: data['unreadCountUser'] ?? 0,
      unreadCountEmployer: data['unreadCountEmployer'] ?? 0,
    );
  }

  /// The best available logo: prefer companyLogo, then employerAvatarUrl
  String get effectiveLogo =>
      companyLogo.isNotEmpty ? companyLogo : employerAvatarUrl;

  /// The display name to show in the UI
  String get displayName =>
      companyName.isNotEmpty ? companyName : employerName;

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

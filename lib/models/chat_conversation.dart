class ChatConversation {
  final String id;
  final String employerName;
  final String companyName;
  final String employerAvatarUrl;
  final String lastMessageText;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatConversation({
    required this.id,
    required this.employerName,
    required this.companyName,
    required this.employerAvatarUrl,
    required this.lastMessageText,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });
}

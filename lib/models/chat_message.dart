class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isMe; // true if sent by the user, false if by employer
  final bool isSystemMessage; // e.g. "Resume Sent" or "Interview Scheduled"

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.isSystemMessage = false,
  });
}

enum MessageRole { user, assistant }

class AiMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  const AiMessage({
    required this.text,
    required this.role,
    required this.timestamp,
  });
}

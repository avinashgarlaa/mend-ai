class Reflection {
  final String id;
  final String sessionId;
  final String userId;
  final String content;
  final int timestamp;

  Reflection({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

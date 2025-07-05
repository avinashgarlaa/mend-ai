// lib/models/session_model.dart

class Message {
  final String speakerId;
  final String text;
  final int timestamp;

  Message({
    required this.speakerId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      speakerId: json['speakerId'],
      text: json['text'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'speakerId': speakerId, 'text': text, 'timestamp': timestamp};
  }
}

class Score {
  final int empathy;
  final int listening;
  final int clarity;
  final int respect;
  final int responsiveness;
  final int openMindedness;

  Score({
    this.empathy = 0,
    this.listening = 0,
    this.clarity = 0,
    this.respect = 0,
    this.responsiveness = 0,
    this.openMindedness = 0,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      empathy: json['empathy'] ?? 0,
      listening: json['listening'] ?? 0,
      clarity: json['clarity'] ?? 0,
      respect: json['respect'] ?? 0,
      responsiveness: json['responsiveness'] ?? 0,
      openMindedness: json['openMindedness'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empathy': empathy,
      'listening': listening,
      'clarity': clarity,
      'respect': respect,
      'responsiveness': responsiveness,
      'openMindedness': openMindedness,
    };
  }
}

class Session {
  final String id;
  final String partnerA;
  final String partnerB;
  final List<Message> messages;
  final Score scoreA;
  final Score scoreB;
  final int createdAt;
  final bool resolved;

  Session({
    required this.id,
    required this.partnerA,
    required this.partnerB,
    required this.messages,
    required this.scoreA,
    required this.scoreB,
    required this.createdAt,
    required this.resolved,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      partnerA: json['partnerA'],
      partnerB: json['partnerB'],
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => Message.fromJson(m))
              .toList() ??
          [],
      scoreA: Score.fromJson(json['scoreA'] ?? {}),
      scoreB: Score.fromJson(json['scoreB'] ?? {}),
      createdAt: json['createdAt'] ?? 0,
      resolved: json['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerA': partnerA,
      'partnerB': partnerB,
      'messages': messages.map((m) => m.toJson()).toList(),
      'scoreA': scoreA.toJson(),
      'scoreB': scoreB.toJson(),
      'createdAt': createdAt,
      'resolved': resolved,
    };
  }
}

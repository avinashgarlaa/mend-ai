class Session {
  final String id;
  final String partnerA;
  final String partnerB;
  final int createdAt;
  final bool resolved;

  Session({
    required this.id,
    required this.partnerA,
    required this.partnerB,
    required this.createdAt,
    required this.resolved,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? json['_id'],
      partnerA: json['partnerA'] ?? '',
      partnerB: json['partnerB'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      resolved: json['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerA': partnerA,
      'partnerB': partnerB,
      'createdAt': createdAt,
      'resolved': resolved,
    };
  }
}

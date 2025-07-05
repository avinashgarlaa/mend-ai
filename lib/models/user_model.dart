class User {
  final String id;
  final String name;
  final String gender;
  final List<String> goals;
  final List<String> challenges;
  final String partnerId;
  final String colorCode;

  final String? currentSessionId;

  User({
    required this.id,
    required this.name,
    required this.gender,
    required this.goals,
    required this.challenges,
    required this.partnerId,
    required this.colorCode,

    this.currentSessionId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    gender: json['gender'],
    goals: List<String>.from(json['goals'] ?? []),
    challenges: List<String>.from(json['challenges'] ?? []),
    partnerId: json['partnerId'] ?? '',
    colorCode: json['colorCode'] ?? '',
  );

  // Include this in copyWith
  User copyWith({
    String? id,
    String? name,
    String? gender,
    String? partnerId,
    String? colorCode,
    List<String>? goals,
    List<String>? challenges,
    String? currentSessionId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      partnerId: partnerId ?? this.partnerId,
      colorCode: colorCode ?? this.colorCode,
      goals: goals ?? this.goals,
      challenges: challenges ?? this.challenges,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String gender;
  final List<String> goals;
  final String otherGoal;
  final List<String> challenges;
  final String otherChallenge;
  final String partnerId;
  final String invitedBy;
  final String colorCode;
  final String?
  currentSessionId; // Optional field (not in backend but for local state)

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.goals,
    required this.otherGoal,
    required this.challenges,
    required this.otherChallenge,
    required this.partnerId,
    required this.invitedBy,
    required this.colorCode,
    this.currentSessionId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    gender: json['gender'] ?? '',
    goals: List<String>.from(json['goals'] ?? []),
    otherGoal: json['otherGoal'] ?? '',
    challenges: List<String>.from(json['challenges'] ?? []),
    otherChallenge: json['otherChallenge'] ?? '',
    partnerId: json['partnerId'] ?? '',
    invitedBy: json['invitedBy'] ?? '',
    colorCode: json['colorCode'] ?? '',
    currentSessionId: json['currentSessionId'], // optional
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "gender": gender,
    "goals": goals,
    "otherGoal": otherGoal,
    "challenges": challenges,
    "otherChallenge": otherChallenge,
    "partnerId": partnerId,
    "invitedBy": invitedBy,
    "colorCode": colorCode,
  };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    List<String>? goals,
    String? otherGoal,
    List<String>? challenges,
    String? otherChallenge,
    String? partnerId,
    String? invitedBy,
    String? colorCode,
    String? currentSessionId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      goals: goals ?? this.goals,
      otherGoal: otherGoal ?? this.otherGoal,
      challenges: challenges ?? this.challenges,
      otherChallenge: otherChallenge ?? this.otherChallenge,
      partnerId: partnerId ?? this.partnerId,
      invitedBy: invitedBy ?? this.invitedBy,
      colorCode: colorCode ?? this.colorCode,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

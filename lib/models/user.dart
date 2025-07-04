class User {
  final String id;
  final String name;
  final String email;
  final String partnerId;
  final String colorCode;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.partnerId,
    required this.colorCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      partnerId: json['partnerId'] ?? '',
      colorCode: json['colorCode'] ?? 'blue',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'partnerId': partnerId,
      'colorCode': colorCode,
    };
  }
}

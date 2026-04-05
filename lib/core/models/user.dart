class User {
  final int id;
  final String username;
  final String role;
  final List<String> capabilities;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.capabilities,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      capabilities: List<String>.from(json['capabilities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'capabilities': capabilities,
    };
  }

  bool hasCapability(String capability) => capabilities.contains(capability);
  bool get isAdmin => role == 'admin';
}

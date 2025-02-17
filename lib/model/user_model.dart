class UserModel{
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActivated;

  UserModel({required this.id, required this.name, required this.email, required this.role, required this.isActivated});

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? "",
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      isActivated: map['isActivated'] ?? true
    );
  }
}
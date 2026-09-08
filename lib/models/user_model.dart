class UserModel {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String email;
  final String marja; // "sistani" | "khamenei" | "other: custom text"
  final String language; // "en" | "ur" | "hi" | "gu"
  final String theme; // "light" | "dark" | "system"
  final String role; // "user" | "scholar" | "admin"
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.marja,
    required this.language,
    required this.theme,
    this.role = 'user',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'gender': gender,
      'email': email,
      'marja': marja,
      'language': language,
      'theme': theme,
      'role': role,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: map['gender'] as String? ?? 'unspecified',
      email: map['email'] as String? ?? '',
      marja: map['marja'] as String? ?? 'sistani',
      language: map['language'] as String? ?? 'en',
      theme: map['theme'] as String? ?? 'system',
      role: map['role'] as String? ?? 'user',
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    int? age,
    String? gender,
    String? email,
    String? marja,
    String? language,
    String? theme,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      marja: marja ?? this.marja,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

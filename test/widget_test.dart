import 'package:flutter_test/flutter_test.dart';
import 'package:muntazir/models/user_model.dart';

void main() {
  test('UserModel serialization and deserialization test', () {
    final user = UserModel(
      uid: 'test_uid_123',
      name: 'Ali Raza',
      age: 28,
      gender: 'brother',
      email: 'aliraza@example.com',
      marja: 'sistani',
      language: 'en',
      theme: 'dark',
      role: 'user',
    );

    final map = user.toMap();
    expect(map['name'], 'Ali Raza');
    expect(map['age'], 28);
    expect(map['marja'], 'sistani');

    final parsedUser = UserModel.fromMap(map, 'test_uid_123');
    expect(parsedUser.name, 'Ali Raza');
    expect(parsedUser.email, 'aliraza@example.com');
    expect(parsedUser.role, 'user');
  });
}

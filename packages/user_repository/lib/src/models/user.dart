import '../entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  String usernameUuid;
  String role;
  String patientData;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    this.usernameUuid = 'Jpefaq6m58',
    this.role = 'simple user',
    this.patientData = ''
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    usernameUuid: 'Jpefaq6m58',
    role: 'simple user',
    patientData: '',
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      usernameUuid: usernameUuid,
      role: role,
      patientData: patientData,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      usernameUuid: entity.usernameUuid,
      role: entity.role,
      patientData: entity.patientData,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $name, $email, $usernameUuid, $role, $patientData';
  }
}

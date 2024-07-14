class MyUserEntity {
  String userId;
  String email;
  String name;
  String usernameUuid;
  String role;
  String patientData;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.usernameUuid,
    required this.role,
    required this.patientData,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'usernameUuid': usernameUuid,
      'role': role,
      'patientData': patientData,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      usernameUuid: doc['usernameUuid'] ?? 'Jpefaq6m58',
      role: doc['role'] ?? 'simple user',
      patientData: doc['patientData'] ?? '0',
    );
  }
}

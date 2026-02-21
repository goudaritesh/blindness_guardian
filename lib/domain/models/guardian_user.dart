class GuardianUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String deviceId;

  GuardianUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.deviceId,
  });

  factory GuardianUser.fromMap(Map<String, dynamic> data, String documentId) {
    return GuardianUser(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      deviceId: data['device_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'device_id': deviceId,
    };
  }
}

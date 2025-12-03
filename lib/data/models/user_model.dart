class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token; // Token bisa null jika user data diambil dari profile

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  // Mengubah JSON dari Laravel menjadi Object Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'], // Sesuaikan dengan struktur respon Laravel Anda
      name: json['user']['name'],
      email: json['user']['email'],
      token: json['token'], // Token biasanya ada di root JSON response login
    );
  }

  // Mengubah Object Dart menjadi JSON (untuk disimpan di HP nanti)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'token': token};
  }
}

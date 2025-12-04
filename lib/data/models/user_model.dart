class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? role; // Tambahan: biar bisa simpan role admin/user
  final String? photoUrl; // Tambahan: foto profil

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.role,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Cek apakah ada wrapper 'data'? Jika ya, masuk ke dalamnya.
    var data = json;
    if (json.containsKey('data')) {
      data = json['data'];
    }

    // 2. Ambil objek 'user' dari dalam 'data'
    // Jika tidak ada key 'user', asumsikan 'data' itu sendiri adalah user
    var userAttributes = data.containsKey('user') ? data['user'] : data;

    return UserModel(
      id: userAttributes['id'] ?? 0,
      name: userAttributes['name'] ?? 'Guest',
      email: userAttributes['email'] ?? '',
      role: userAttributes['role'] ?? 'user',
      photoUrl: userAttributes['photo_url'], // Bisa null
      // Token biasanya bernama 'access_token' di dalam 'data'
      token: data['access_token'] ?? data['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
      'photo_url': photoUrl,
    };
  }
}

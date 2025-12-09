import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:panganku_mobile/core/constants/api_constants.dart';

// Helper untuk memperbaiki URL gambar dari backend
String? fixImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }

  // 1. Jika URL dari backend adalah URL lengkap (mengandung http)
  if (url.startsWith('http')) {
    // Jika itu adalah URL localhost, kita ganti host-nya dengan yang benar
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      final path = Uri.parse(url).path; // Ambil path-nya saja, misal: /storage/profile-photos/....png
      return '${ApiConstants.storageBaseUrl}$path';
    }
    // Jika bukan URL localhost (misal: foto dari Google), biarkan saja
    return url;
  }

  // 2. Jika URL dari backend hanya path relatif (misal: profile-photos/....png)
  // Kita tambahkan host dan folder storage di depannya
  return '${ApiConstants.storageBaseUrl}/storage/$url';
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? photoUrl;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.photoUrl,
    this.token,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? token}) {
    return UserModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Guest',
      email: map['email'] ?? '',
      role: map['role'] ?? 'buyer',
      photoUrl: fixImageUrl(map['photo_url']),
      // Prioritaskan token dari argumen, lalu fallback ke token di dalam map
      token: token ?? map['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photo_url': photoUrl,
      'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    // Gunakan ValueGetter agar bisa membedakan antara null yang disengaja dan tidak ada perubahan
    ValueGetter<String?>? photoUrl,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
      token: token ?? this.token,
    );
  }
}

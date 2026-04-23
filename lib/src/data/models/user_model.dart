import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? bio;
  final bool isOnline;
  final int? lastSeen;
  final int? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
  });

  factory AppUser.empty() => const AppUser(id: '', email: '');

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? bio,
    bool? isOnline,
    int? lastSeen,
    int? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  List<Object?> get props => [id, email, name, photoUrl, bio, isOnline, lastSeen, createdAt];
}

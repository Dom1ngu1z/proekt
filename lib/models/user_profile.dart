class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      displayName: map['display_name']?.toString() ?? 'Пользователь',
      username: map['username']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'display_name': displayName,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }
}


// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class passwords {
  final String username;
  final String platform;
  final String password;

  passwords(
      this.username ,
      this.platform,
      this.password,
      );

  passwords copyWith({
    String? username,
    String? platform,
    String? password,
  }) {
    return passwords(
      username ?? this.username,
      platform ?? this.platform,
      password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'platform': platform,
      'password': password,
    };
  }

  factory passwords.fromMap(Map<String, dynamic> map) {
    return passwords(
      map['username'] as String,
      map['platform'] as String,
      map['password'] as String,
    );
  }


  String toJson() => json.encode(toMap());

  factory passwords.fromJson(String source) => passwords.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'passwords(username: $username, platform: $platform, password: $password)';

  @override
  bool operator ==(covariant passwords other) {
    if (identical(this, other)) return true;

    return
      other.username == username &&
          other.platform == platform &&
          other.password == password;
  }

  @override
  int get hashCode => username.hashCode ^ platform.hashCode ^ password.hashCode;
}

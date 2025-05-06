class StorageKeys {
  static final userDetails = 'userDetails';
}

class UserDetails {
  UserDetails({required this.email, required this.password});

  final String email;
  final String password;

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(email: json['email'] as String, password: json['password'] as String);

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

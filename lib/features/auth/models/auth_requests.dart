class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'rememberMe': rememberMe,
  };
}

class RegisterRequest {
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'gender': gender,
    'dateOfBirth': dateOfBirth,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
  };
}

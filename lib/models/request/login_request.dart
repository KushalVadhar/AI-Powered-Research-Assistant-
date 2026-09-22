/// Login request DTO.
/// WHY REQUEST MODELS EXIST:
/// Request models define the exact shape of data sent to the API.
/// They're separate from domain models because:
///   1. The API might need FEWER fields than the domain model
///      (login only needs email + password, not the full UserModel)
///   2. The API might need fields NAMED differently
///      (API wants 'email', domain model might store it differently)
///   3. Validation rules are different
///      (a login request MUST have both email and password;
///       a UserModel might have email but password is never stored)
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

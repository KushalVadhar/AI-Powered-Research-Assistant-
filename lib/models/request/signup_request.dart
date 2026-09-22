/// Signup request DTO.
/// DESIGN DECISION — No confirmPassword field:
/// Password confirmation is a UI-only concern. The screen validates
/// that both fields match BEFORE creating this request. The API
/// only needs the password once. Don't leak UI concerns into DTOs.
class SignupRequest {
  const SignupRequest({
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
    };
  }
}

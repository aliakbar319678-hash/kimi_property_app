class ApiConstants {
  // Use localhost to tunnel through adb reverse
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // We will add more endpoints here later
}

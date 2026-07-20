import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'auth_state.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';

// ── Welcome ──────────────────────────────────
class WelcomeNotifier extends StateNotifier<WelcomeState> {
  WelcomeNotifier() : super(const WelcomeState());
}

final welcomeProvider = StateNotifierProvider<WelcomeNotifier, WelcomeState>(
  (ref) => WelcomeNotifier(),
);

// ── Register ─────────────────────────────────
class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  void updateFullName(String v) =>
      state = state.copyWith(fullName: v, fullNameError: null);
  void updateEmail(String v) =>
      state = state.copyWith(email: v, emailError: null);
  void updatePhone(String v) =>
      state = state.copyWith(phone: v, phoneError: null);
  void updatePassword(String v) =>
      state = state.copyWith(password: v, passwordError: null);
  void toggleTerms() =>
      state = state.copyWith(agreeToTerms: !state.agreeToTerms);
  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleMode() => state = state.copyWith(
        isLogin: !state.isLogin,
        fullName: '',
        email: '',
        phone: '',
        password: '',
        errorMessage: null,
        fullNameError: null,
        emailError: null,
        phoneError: null,
        passwordError: null,
      );
  void setLoginMode(bool isLogin) => state = state.copyWith(
        isLogin: isLogin,
        fullName: '',
        email: '',
        phone: '',
        password: '',
        errorMessage: null,
        fullNameError: null,
        emailError: null,
        phoneError: null,
        passwordError: null,
      );
  void updateSelectedRole(String v) =>
      state = state.copyWith(selectedRole: v);

  Future<bool> submit() async {
    state = state.copyWith(
      fullNameError: null,
      emailError: null,
      phoneError: null,
      passwordError: null,
      errorMessage: null,
      isLoading: true,
    );

    bool hasErrors = false;
    String? fullNameErr;
    String? emailErr;
    String? phoneErr;
    String? passwordErr;

    if (state.isLogin) {
      if (state.email.trim().isEmpty) {
        emailErr = 'Email is required';
        hasErrors = true;
      }
      if (state.password.trim().isEmpty) {
        passwordErr = 'Password is required';
        hasErrors = true;
      }
    } else {
      if (state.fullName.trim().isEmpty) {
        fullNameErr = 'Full Name is required';
        hasErrors = true;
      }
      if (state.email.trim().isEmpty) {
        emailErr = 'Email is required';
        hasErrors = true;
      } else if (!state.email.contains('@') || !state.email.contains('.')) {
        emailErr = 'Enter a valid email address';
        hasErrors = true;
      }
      if (state.phone.trim().isEmpty) {
        phoneErr = 'Phone Number is required';
        hasErrors = true;
      }
      if (state.password.trim().isEmpty) {
        passwordErr = 'Password is required';
        hasErrors = true;
      } else if (state.password.length < 8) {
        passwordErr = 'Password must be at least 8 characters';
        hasErrors = true;
      }
    }

    if (hasErrors) {
      state = state.copyWith(
        fullNameError: fullNameErr,
        emailError: emailErr,
        phoneError: phoneErr,
        passwordError: passwordErr,
        isLoading: false,
      );
      return false;
    }

    try {
      if (state.isLogin) {
        // ── LOGIN ────────────────────────────────────────────────────────────
        // POST /api/v1/auth/login
        // Response: { success: true, data: { accessToken, refreshToken, user: { id, email, roles, kycStatus, onboardingStep }, requiresOnboarding } }
        final response = await ApiClient().dio.post(
          ApiConstants.login,
          data: {
            'email': state.email.trim(),
            'password': state.password,
          },
        );

        final data = response.data['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String?;

        // Persist tokens in secure storage
        await ApiClient().saveToken(accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await ApiClient().saveRefreshToken(refreshToken);
        }

        // Determine role for navigation
        final userMap = data['user'] as Map<String, dynamic>? ?? {};
        final List<dynamic> roles = userMap['roles'] as List<dynamic>? ?? [];
        final String primaryRole =
            roles.isNotEmpty ? roles.first.toString() : 'tenant';

        state = state.copyWith(selectedRole: primaryRole, isLoading: false);
        return true;
      } else {
        // ── REGISTER ─────────────────────────────────────────────────────────
        // POST /api/v1/auth/register
        // Body: { email, password, phone, role, display_name }
        // Response: { success: true, data: { id, email, kyc_status } }
        await ApiClient().dio.post(
          ApiConstants.register,
          data: {
            'email': state.email.trim(),
            'password': state.password,
            'phone': state.phone.trim(),
            'role': state.selectedRole,
            'display_name': state.fullName.trim(),
          },
        );

        // Auto-login after registration to get tokens
        final loginResponse = await ApiClient().dio.post(
          ApiConstants.login,
          data: {
            'email': state.email.trim(),
            'password': state.password,
          },
        );

        final loginData = loginResponse.data['data'] as Map<String, dynamic>;
        final accessToken = loginData['accessToken'] as String;
        final refreshToken = loginData['refreshToken'] as String?;

        await ApiClient().saveToken(accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await ApiClient().saveRefreshToken(refreshToken);
        }

        state = state.copyWith(isLoading: false);
        return true;
      }
    } catch (e) {
      String msg = e.toString();
      if (e is DioException) {
        msg = _parseDioError(e);
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }
}

final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(),
);

// ── OTP ──────────────────────────────────────
class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(const OtpState());

  void updateDigit(int index, String value) {
    final updated = [...state.otpDigits];
    updated[index] = value;
    state = state.copyWith(otpDigits: updated);
  }

  Future<void> verify() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final code = state.otpDigits.join();
      if (code.length < 4) {
        throw 'Please enter all 4 digits';
      }

      // POST /api/v1/auth/verify-otp
      // Body: { code: "1234" }
      // Response: { success: true, data: { ... } }
      final response = await ApiClient().dio.post(
        ApiConstants.verifyOtp,
        data: {'code': code},
      );

      if (response.statusCode == 200 || response.data['success'] == true) {
        state = state.copyWith(isLoading: false, isVerified: true);
      } else {
        throw response.data['message'] ?? 'Verification failed';
      }
    } catch (e) {
      String msg = 'An error occurred';
      if (e is DioException) {
        msg = _parseDioError(e);
      } else if (e is String) {
        msg = e;
      } else {
        msg = e.toString();
      }
      state = state.copyWith(
          isLoading: false, isVerified: false, errorMessage: msg);
    }
  }

  Future<void> resend() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // POST /api/v1/auth/resend-otp
      final response = await ApiClient().dio.post(ApiConstants.resendOtp);
      if (response.statusCode == 200 || response.data['success'] == true) {
        state = state.copyWith(isLoading: false, otpDigits: ['', '', '', '']);
      } else {
        throw response.data['message'] ?? 'Failed to resend code';
      }
    } catch (e) {
      String msg = 'An error occurred';
      if (e is DioException) {
        msg = _parseDioError(e);
      } else {
        msg = e.toString();
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }
}

// ── Helpers ───────────────────────────────────
String _parseDioError(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    return (data['error'] ?? data['message'] ?? e.message ?? e.toString())
        .toString();
  } else if (data is String && data.isNotEmpty) {
    return data;
  }
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Connection timed out. Please check your network.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Cannot connect to server. Make sure the backend is running.';
  }
  return e.message ?? e.toString();
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(),
);

import 'dart:async';
import 'package:flutter/foundation.dart';
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
  void updateUsername(String v) =>
      state = state.copyWith(username: v, usernameError: null);
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
        username: '',
        email: '',
        phone: '',
        password: '',
        errorMessage: null,
        fullNameError: null,
        usernameError: null,
        emailError: null,
        phoneError: null,
        passwordError: null,
      );
  void setLoginMode(bool isLogin) => state = state.copyWith(
        isLogin: isLogin,
        fullName: '',
        username: '',
        email: '',
        phone: '',
        password: '',
        errorMessage: null,
        fullNameError: null,
        usernameError: null,
        emailError: null,
        phoneError: null,
        passwordError: null,
      );
  void updateSelectedRole(String v) {
    final lower = v.toLowerCase();
    String mapped = 'tenant';
    if (lower.contains('landlord')) {
      mapped = 'landlord';
    } else if (lower.contains('vendor')) {
      mapped = 'vendor';
    }
    state = state.copyWith(selectedRole: mapped);
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Live / mock Google auth state handler
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Google Authentication failed');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    try {
      final response = await ApiClient().dio.get(ApiConstants.me);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      // Ignore or log error
    }
    return null;
  }

  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await ApiClient().dio.put(
        ApiConstants.updateProfile,
        data: profileData,
      );
      return response.statusCode == 200 || response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

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

    final trimmedEmail = state.email.trim().toLowerCase();
    final trimmedPhone = state.phone.trim();
    final trimmedFullName = state.fullName.trim();

    if (state.isLogin) {
      if (trimmedEmail.isEmpty) {
        emailErr = 'Email is required';
        hasErrors = true;
      }
      if (state.password.trim().isEmpty) {
        passwordErr = 'Password is required';
        hasErrors = true;
      }
    } else {
      if (trimmedFullName.isEmpty) {
        fullNameErr = 'Full Name is required';
        hasErrors = true;
      }
      if (trimmedEmail.isEmpty) {
        emailErr = 'Email is required';
        hasErrors = true;
      } else if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        emailErr = 'Enter a valid email address';
        hasErrors = true;
      }
      if (trimmedPhone.isEmpty) {
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
        final response = await ApiClient().dio.post(
          ApiConstants.login,
          data: {
            'email': trimmedEmail,
            'password': state.password,
          },
        );

        final data = response.data['data'] as Map<String, dynamic>;
        final accessToken = data['token'] as String;
        final refreshToken = data['refreshToken'] as String?;

        await ApiClient().saveToken(accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await ApiClient().saveRefreshToken(refreshToken);
        }

        final userMap = data['user'] as Map<String, dynamic>? ?? {};
        final List<dynamic> roles = userMap['roles'] as List<dynamic>? ?? [];
        final String primaryRole =
            roles.isNotEmpty ? roles.first.toString().toLowerCase() : 'tenant';

        state = state.copyWith(selectedRole: primaryRole, isLoading: false);
        return true;
      } else {
        // ── REGISTER ─────────────────────────────────────────────────────────
        final String mappedRole = ['tenant', 'landlord', 'vendor', 'admin', 'property_manager']
                .contains(state.selectedRole.toLowerCase())
            ? state.selectedRole.toLowerCase()
            : 'tenant';

        final regPayload = <String, dynamic>{
          'email': trimmedEmail,
          'password': state.password,
          'role': mappedRole,
          'regionCode': 'US-NYC',
        };

        if (trimmedPhone.isNotEmpty) {
          regPayload['phone'] = trimmedPhone;
        }
        if (trimmedFullName.isNotEmpty) {
          regPayload['display_name'] = trimmedFullName;
          final parts = trimmedFullName.split(' ');
          regPayload['first_name'] = parts.first;
          if (parts.length > 1) {
            regPayload['last_name'] = parts.sublist(1).join(' ');
          }
        }
        if (state.username.trim().isNotEmpty && mappedRole == 'tenant') {
          regPayload['username'] = state.username.trim();
        }

        await ApiClient().dio.post(
          ApiConstants.register,
          data: regPayload,
        );

        // Try auto-login after successful registration
        try {
          final loginPayload = <String, dynamic>{
            'email': trimmedEmail,
            'password': state.password,
          };

          final loginResponse = await ApiClient().dio.post(
            ApiConstants.login,
            data: loginPayload,
          );

          final loginData = loginResponse.data['data'] as Map<String, dynamic>;
          final accessToken = loginData['token'] as String;
          final refreshToken = loginData['refreshToken'] as String?;

          await ApiClient().saveToken(accessToken);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await ApiClient().saveRefreshToken(refreshToken);
          }
        } catch (_) {
          // If auto-login fails due to backend SQL bug, switch mode to Sign In cleanly
          state = state.copyWith(
            isLogin: true,
            isLoading: false,
            errorMessage: 'Account registered successfully! Please sign in.',
          );
          return true;
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
  Timer? _timer;

  OtpNotifier() : super(const OtpState());

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateDigit(int index, String value) {
    final updated = [...state.otpDigits];
    updated[index] = value;
    state = state.copyWith(otpDigits: updated);
  }

  void startResendTimer() {
    _timer?.cancel();
    state = state.copyWith(resendCountdown: 180);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown <= 1) {
        timer.cancel();
        state = state.copyWith(resendCountdown: 0);
      } else {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> verify() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final code = state.otpDigits.join();
      if (code.length < 4) {
        throw 'Please enter all 4 digits';
      }

      // Bypass for testing
      if (code == '1234') {
        state = state.copyWith(isLoading: false, isVerified: true);
        return;
      }

      final response = await ApiClient().dio.post(
        ApiConstants.verifyOtp,
        data: {
          'email': state.email.trim().toLowerCase(),
          'otp': code,
          'code': code,
        },
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
      final response = await ApiClient().dio.post(
        '/auth/forgot-password',
        data: {'email': state.email.trim().toLowerCase()},
      );
      if (response.statusCode == 200 || response.data['success'] == true) {
        state = state.copyWith(isLoading: false, otpDigits: ['', '', '', '']);
        startResendTimer();
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
  debugPrint('=== DIO ERROR ===');
  debugPrint('StatusCode: ${e.response?.statusCode}');
  debugPrint('Response Data: ${e.response?.data}');
  debugPrint('=================');

  final data = e.response?.data;
  if (data is Map) {
    if (data['details'] is List && (data['details'] as List).isNotEmpty) {
      final details = (data['details'] as List)
          .map((d) {
            if (d is Map) {
              final msg = d['message']?.toString();
              if (msg != null && msg.isNotEmpty) {
                return msg.replaceAll('"', '');
              }
            }
            return d?.toString();
          })
          .whereType<String>()
          .toList();
      if (details.isNotEmpty) {
        return details.join('\n');
      }
    }
    if (data['message'] != null && data['message'].toString().isNotEmpty) {
      return data['message'].toString();
    }
    if (data['error'] != null &&
        data['error'].toString().isNotEmpty &&
        data['error'] != 'Validation failed') {
      final err = data['error'].toString();
      if (err == 'Internal server error') {
        return 'Registration/Login failed. This email or phone number may already be registered, or an unexpected server error occurred.';
      }
      return err;
    }
  } else if (data is String && data.isNotEmpty) {
    if (data == 'Internal server error') {
      return 'Registration/Login failed. This email or phone number may already be registered, or an unexpected server error occurred.';
    }
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


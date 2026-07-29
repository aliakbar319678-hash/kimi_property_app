import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class WelcomeState with _$WelcomeState {
  const factory WelcomeState() = _WelcomeState;
}

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String fullName,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String password,
    @Default(false) bool agreeToTerms,
    @Default(false) bool obscurePassword,
    @Default(false) bool isLoading,
    @Default(false) bool isLogin,
    @Default('tenant') String selectedRole,
    String? errorMessage,
    String? fullNameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
  }) = _RegisterState;
}

@freezed
abstract class OtpState with _$OtpState {
  const factory OtpState({
    @Default(['', '', '', '']) List<String> otpDigits,
    @Default('') String email,
    @Default(false) bool isLoading,
    @Default(false) bool isVerified,
    @Default(0) int resendCountdown,
    String? errorMessage,
  }) = _OtpState;
}


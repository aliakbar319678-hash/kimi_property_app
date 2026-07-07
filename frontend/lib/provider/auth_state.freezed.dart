// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WelcomeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WelcomeState()';
}


}

/// @nodoc
class $WelcomeStateCopyWith<$Res>  {
$WelcomeStateCopyWith(WelcomeState _, $Res Function(WelcomeState) __);
}


/// Adds pattern-matching-related methods to [WelcomeState].
extension WelcomeStatePatterns on WelcomeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WelcomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WelcomeState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WelcomeState value)  $default,){
final _that = this;
switch (_that) {
case _WelcomeState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WelcomeState value)?  $default,){
final _that = this;
switch (_that) {
case _WelcomeState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function()?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WelcomeState() when $default != null:
return $default();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function()  $default,) {final _that = this;
switch (_that) {
case _WelcomeState():
return $default();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function()?  $default,) {final _that = this;
switch (_that) {
case _WelcomeState() when $default != null:
return $default();case _:
  return null;

}
}

}

/// @nodoc


class _WelcomeState implements WelcomeState {
  const _WelcomeState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WelcomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WelcomeState()';
}


}




/// @nodoc
mixin _$RegisterState {

 String get fullName; String get email; String get phone; String get password; bool get agreeToTerms; bool get obscurePassword; bool get isLoading; bool get isLogin; String get selectedRole; String? get errorMessage; String? get fullNameError; String? get emailError; String? get phoneError; String? get passwordError;
/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterStateCopyWith<RegisterState> get copyWith => _$RegisterStateCopyWithImpl<RegisterState>(this as RegisterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterState&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.agreeToTerms, agreeToTerms) || other.agreeToTerms == agreeToTerms)&&(identical(other.obscurePassword, obscurePassword) || other.obscurePassword == obscurePassword)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLogin, isLogin) || other.isLogin == isLogin)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.fullNameError, fullNameError) || other.fullNameError == fullNameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.phoneError, phoneError) || other.phoneError == phoneError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,email,phone,password,agreeToTerms,obscurePassword,isLoading,isLogin,selectedRole,errorMessage,fullNameError,emailError,phoneError,passwordError);

@override
String toString() {
  return 'RegisterState(fullName: $fullName, email: $email, phone: $phone, password: $password, agreeToTerms: $agreeToTerms, obscurePassword: $obscurePassword, isLoading: $isLoading, isLogin: $isLogin, selectedRole: $selectedRole, errorMessage: $errorMessage, fullNameError: $fullNameError, emailError: $emailError, phoneError: $phoneError, passwordError: $passwordError)';
}


}

/// @nodoc
abstract mixin class $RegisterStateCopyWith<$Res>  {
  factory $RegisterStateCopyWith(RegisterState value, $Res Function(RegisterState) _then) = _$RegisterStateCopyWithImpl;
@useResult
$Res call({
 String fullName, String email, String phone, String password, bool agreeToTerms, bool obscurePassword, bool isLoading, bool isLogin, String selectedRole, String? errorMessage, String? fullNameError, String? emailError, String? phoneError, String? passwordError
});




}
/// @nodoc
class _$RegisterStateCopyWithImpl<$Res>
    implements $RegisterStateCopyWith<$Res> {
  _$RegisterStateCopyWithImpl(this._self, this._then);

  final RegisterState _self;
  final $Res Function(RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? email = null,Object? phone = null,Object? password = null,Object? agreeToTerms = null,Object? obscurePassword = null,Object? isLoading = null,Object? isLogin = null,Object? selectedRole = null,Object? errorMessage = freezed,Object? fullNameError = freezed,Object? emailError = freezed,Object? phoneError = freezed,Object? passwordError = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,agreeToTerms: null == agreeToTerms ? _self.agreeToTerms : agreeToTerms // ignore: cast_nullable_to_non_nullable
as bool,obscurePassword: null == obscurePassword ? _self.obscurePassword : obscurePassword // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLogin: null == isLogin ? _self.isLogin : isLogin // ignore: cast_nullable_to_non_nullable
as bool,selectedRole: null == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,fullNameError: freezed == fullNameError ? _self.fullNameError : fullNameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,phoneError: freezed == phoneError ? _self.phoneError : phoneError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterState].
extension RegisterStatePatterns on RegisterState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String email,  String phone,  String password,  bool agreeToTerms,  bool obscurePassword,  bool isLoading,  bool isLogin,  String selectedRole,  String? errorMessage,  String? fullNameError,  String? emailError,  String? phoneError,  String? passwordError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.fullName,_that.email,_that.phone,_that.password,_that.agreeToTerms,_that.obscurePassword,_that.isLoading,_that.isLogin,_that.selectedRole,_that.errorMessage,_that.fullNameError,_that.emailError,_that.phoneError,_that.passwordError);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String email,  String phone,  String password,  bool agreeToTerms,  bool obscurePassword,  bool isLoading,  bool isLogin,  String selectedRole,  String? errorMessage,  String? fullNameError,  String? emailError,  String? phoneError,  String? passwordError)  $default,) {final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that.fullName,_that.email,_that.phone,_that.password,_that.agreeToTerms,_that.obscurePassword,_that.isLoading,_that.isLogin,_that.selectedRole,_that.errorMessage,_that.fullNameError,_that.emailError,_that.phoneError,_that.passwordError);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String email,  String phone,  String password,  bool agreeToTerms,  bool obscurePassword,  bool isLoading,  bool isLogin,  String selectedRole,  String? errorMessage,  String? fullNameError,  String? emailError,  String? phoneError,  String? passwordError)?  $default,) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.fullName,_that.email,_that.phone,_that.password,_that.agreeToTerms,_that.obscurePassword,_that.isLoading,_that.isLogin,_that.selectedRole,_that.errorMessage,_that.fullNameError,_that.emailError,_that.phoneError,_that.passwordError);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterState implements RegisterState {
  const _RegisterState({this.fullName = '', this.email = '', this.phone = '', this.password = '', this.agreeToTerms = false, this.obscurePassword = false, this.isLoading = false, this.isLogin = false, this.selectedRole = 'tenant', this.errorMessage, this.fullNameError, this.emailError, this.phoneError, this.passwordError});
  

@override@JsonKey() final  String fullName;
@override@JsonKey() final  String email;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool agreeToTerms;
@override@JsonKey() final  bool obscurePassword;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLogin;
@override@JsonKey() final  String selectedRole;
@override final  String? errorMessage;
@override final  String? fullNameError;
@override final  String? emailError;
@override final  String? phoneError;
@override final  String? passwordError;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterStateCopyWith<_RegisterState> get copyWith => __$RegisterStateCopyWithImpl<_RegisterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterState&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.agreeToTerms, agreeToTerms) || other.agreeToTerms == agreeToTerms)&&(identical(other.obscurePassword, obscurePassword) || other.obscurePassword == obscurePassword)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLogin, isLogin) || other.isLogin == isLogin)&&(identical(other.selectedRole, selectedRole) || other.selectedRole == selectedRole)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.fullNameError, fullNameError) || other.fullNameError == fullNameError)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.phoneError, phoneError) || other.phoneError == phoneError)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,email,phone,password,agreeToTerms,obscurePassword,isLoading,isLogin,selectedRole,errorMessage,fullNameError,emailError,phoneError,passwordError);

@override
String toString() {
  return 'RegisterState(fullName: $fullName, email: $email, phone: $phone, password: $password, agreeToTerms: $agreeToTerms, obscurePassword: $obscurePassword, isLoading: $isLoading, isLogin: $isLogin, selectedRole: $selectedRole, errorMessage: $errorMessage, fullNameError: $fullNameError, emailError: $emailError, phoneError: $phoneError, passwordError: $passwordError)';
}


}

/// @nodoc
abstract mixin class _$RegisterStateCopyWith<$Res> implements $RegisterStateCopyWith<$Res> {
  factory _$RegisterStateCopyWith(_RegisterState value, $Res Function(_RegisterState) _then) = __$RegisterStateCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String email, String phone, String password, bool agreeToTerms, bool obscurePassword, bool isLoading, bool isLogin, String selectedRole, String? errorMessage, String? fullNameError, String? emailError, String? phoneError, String? passwordError
});




}
/// @nodoc
class __$RegisterStateCopyWithImpl<$Res>
    implements _$RegisterStateCopyWith<$Res> {
  __$RegisterStateCopyWithImpl(this._self, this._then);

  final _RegisterState _self;
  final $Res Function(_RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? email = null,Object? phone = null,Object? password = null,Object? agreeToTerms = null,Object? obscurePassword = null,Object? isLoading = null,Object? isLogin = null,Object? selectedRole = null,Object? errorMessage = freezed,Object? fullNameError = freezed,Object? emailError = freezed,Object? phoneError = freezed,Object? passwordError = freezed,}) {
  return _then(_RegisterState(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,agreeToTerms: null == agreeToTerms ? _self.agreeToTerms : agreeToTerms // ignore: cast_nullable_to_non_nullable
as bool,obscurePassword: null == obscurePassword ? _self.obscurePassword : obscurePassword // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLogin: null == isLogin ? _self.isLogin : isLogin // ignore: cast_nullable_to_non_nullable
as bool,selectedRole: null == selectedRole ? _self.selectedRole : selectedRole // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,fullNameError: freezed == fullNameError ? _self.fullNameError : fullNameError // ignore: cast_nullable_to_non_nullable
as String?,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as String?,phoneError: freezed == phoneError ? _self.phoneError : phoneError // ignore: cast_nullable_to_non_nullable
as String?,passwordError: freezed == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$OtpState {

 List<String> get otpDigits; bool get isLoading; bool get isVerified; String? get errorMessage;
/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpStateCopyWith<OtpState> get copyWith => _$OtpStateCopyWithImpl<OtpState>(this as OtpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpState&&const DeepCollectionEquality().equals(other.otpDigits, otpDigits)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(otpDigits),isLoading,isVerified,errorMessage);

@override
String toString() {
  return 'OtpState(otpDigits: $otpDigits, isLoading: $isLoading, isVerified: $isVerified, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $OtpStateCopyWith<$Res>  {
  factory $OtpStateCopyWith(OtpState value, $Res Function(OtpState) _then) = _$OtpStateCopyWithImpl;
@useResult
$Res call({
 List<String> otpDigits, bool isLoading, bool isVerified, String? errorMessage
});




}
/// @nodoc
class _$OtpStateCopyWithImpl<$Res>
    implements $OtpStateCopyWith<$Res> {
  _$OtpStateCopyWithImpl(this._self, this._then);

  final OtpState _self;
  final $Res Function(OtpState) _then;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? otpDigits = null,Object? isLoading = null,Object? isVerified = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
otpDigits: null == otpDigits ? _self.otpDigits : otpDigits // ignore: cast_nullable_to_non_nullable
as List<String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpState].
extension OtpStatePatterns on OtpState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpState value)  $default,){
final _that = this;
switch (_that) {
case _OtpState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpState value)?  $default,){
final _that = this;
switch (_that) {
case _OtpState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> otpDigits,  bool isLoading,  bool isVerified,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpState() when $default != null:
return $default(_that.otpDigits,_that.isLoading,_that.isVerified,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> otpDigits,  bool isLoading,  bool isVerified,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _OtpState():
return $default(_that.otpDigits,_that.isLoading,_that.isVerified,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> otpDigits,  bool isLoading,  bool isVerified,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _OtpState() when $default != null:
return $default(_that.otpDigits,_that.isLoading,_that.isVerified,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _OtpState implements OtpState {
  const _OtpState({final  List<String> otpDigits = const ['', '', '', ''], this.isLoading = false, this.isVerified = false, this.errorMessage}): _otpDigits = otpDigits;
  

 final  List<String> _otpDigits;
@override@JsonKey() List<String> get otpDigits {
  if (_otpDigits is EqualUnmodifiableListView) return _otpDigits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_otpDigits);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isVerified;
@override final  String? errorMessage;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpStateCopyWith<_OtpState> get copyWith => __$OtpStateCopyWithImpl<_OtpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpState&&const DeepCollectionEquality().equals(other._otpDigits, _otpDigits)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_otpDigits),isLoading,isVerified,errorMessage);

@override
String toString() {
  return 'OtpState(otpDigits: $otpDigits, isLoading: $isLoading, isVerified: $isVerified, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$OtpStateCopyWith<$Res> implements $OtpStateCopyWith<$Res> {
  factory _$OtpStateCopyWith(_OtpState value, $Res Function(_OtpState) _then) = __$OtpStateCopyWithImpl;
@override @useResult
$Res call({
 List<String> otpDigits, bool isLoading, bool isVerified, String? errorMessage
});




}
/// @nodoc
class __$OtpStateCopyWithImpl<$Res>
    implements _$OtpStateCopyWith<$Res> {
  __$OtpStateCopyWithImpl(this._self, this._then);

  final _OtpState _self;
  final $Res Function(_OtpState) _then;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? otpDigits = null,Object? isLoading = null,Object? isVerified = null,Object? errorMessage = freezed,}) {
  return _then(_OtpState(
otpDigits: null == otpDigits ? _self._otpDigits : otpDigits // ignore: cast_nullable_to_non_nullable
as List<String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

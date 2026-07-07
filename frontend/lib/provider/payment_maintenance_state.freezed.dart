// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_maintenance_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PayRentState {

 PaymentMethod get selectedMethod; bool get isLoading;
/// Create a copy of PayRentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayRentStateCopyWith<PayRentState> get copyWith => _$PayRentStateCopyWithImpl<PayRentState>(this as PayRentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayRentState&&(identical(other.selectedMethod, selectedMethod) || other.selectedMethod == selectedMethod)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMethod,isLoading);

@override
String toString() {
  return 'PayRentState(selectedMethod: $selectedMethod, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $PayRentStateCopyWith<$Res>  {
  factory $PayRentStateCopyWith(PayRentState value, $Res Function(PayRentState) _then) = _$PayRentStateCopyWithImpl;
@useResult
$Res call({
 PaymentMethod selectedMethod, bool isLoading
});




}
/// @nodoc
class _$PayRentStateCopyWithImpl<$Res>
    implements $PayRentStateCopyWith<$Res> {
  _$PayRentStateCopyWithImpl(this._self, this._then);

  final PayRentState _self;
  final $Res Function(PayRentState) _then;

/// Create a copy of PayRentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMethod = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
selectedMethod: null == selectedMethod ? _self.selectedMethod : selectedMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PayRentState].
extension PayRentStatePatterns on PayRentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayRentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayRentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayRentState value)  $default,){
final _that = this;
switch (_that) {
case _PayRentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayRentState value)?  $default,){
final _that = this;
switch (_that) {
case _PayRentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentMethod selectedMethod,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayRentState() when $default != null:
return $default(_that.selectedMethod,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentMethod selectedMethod,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _PayRentState():
return $default(_that.selectedMethod,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentMethod selectedMethod,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _PayRentState() when $default != null:
return $default(_that.selectedMethod,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _PayRentState implements PayRentState {
  const _PayRentState({this.selectedMethod = PaymentMethod.bankACH, this.isLoading = false});
  

@override@JsonKey() final  PaymentMethod selectedMethod;
@override@JsonKey() final  bool isLoading;

/// Create a copy of PayRentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayRentStateCopyWith<_PayRentState> get copyWith => __$PayRentStateCopyWithImpl<_PayRentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayRentState&&(identical(other.selectedMethod, selectedMethod) || other.selectedMethod == selectedMethod)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMethod,isLoading);

@override
String toString() {
  return 'PayRentState(selectedMethod: $selectedMethod, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$PayRentStateCopyWith<$Res> implements $PayRentStateCopyWith<$Res> {
  factory _$PayRentStateCopyWith(_PayRentState value, $Res Function(_PayRentState) _then) = __$PayRentStateCopyWithImpl;
@override @useResult
$Res call({
 PaymentMethod selectedMethod, bool isLoading
});




}
/// @nodoc
class __$PayRentStateCopyWithImpl<$Res>
    implements _$PayRentStateCopyWith<$Res> {
  __$PayRentStateCopyWithImpl(this._self, this._then);

  final _PayRentState _self;
  final $Res Function(_PayRentState) _then;

/// Create a copy of PayRentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMethod = null,Object? isLoading = null,}) {
  return _then(_PayRentState(
selectedMethod: null == selectedMethod ? _self.selectedMethod : selectedMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LeaseSummaryState {

 bool get isDownloading;
/// Create a copy of LeaseSummaryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaseSummaryStateCopyWith<LeaseSummaryState> get copyWith => _$LeaseSummaryStateCopyWithImpl<LeaseSummaryState>(this as LeaseSummaryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaseSummaryState&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading));
}


@override
int get hashCode => Object.hash(runtimeType,isDownloading);

@override
String toString() {
  return 'LeaseSummaryState(isDownloading: $isDownloading)';
}


}

/// @nodoc
abstract mixin class $LeaseSummaryStateCopyWith<$Res>  {
  factory $LeaseSummaryStateCopyWith(LeaseSummaryState value, $Res Function(LeaseSummaryState) _then) = _$LeaseSummaryStateCopyWithImpl;
@useResult
$Res call({
 bool isDownloading
});




}
/// @nodoc
class _$LeaseSummaryStateCopyWithImpl<$Res>
    implements $LeaseSummaryStateCopyWith<$Res> {
  _$LeaseSummaryStateCopyWithImpl(this._self, this._then);

  final LeaseSummaryState _self;
  final $Res Function(LeaseSummaryState) _then;

/// Create a copy of LeaseSummaryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDownloading = null,}) {
  return _then(_self.copyWith(
isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaseSummaryState].
extension LeaseSummaryStatePatterns on LeaseSummaryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaseSummaryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaseSummaryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaseSummaryState value)  $default,){
final _that = this;
switch (_that) {
case _LeaseSummaryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaseSummaryState value)?  $default,){
final _that = this;
switch (_that) {
case _LeaseSummaryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isDownloading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaseSummaryState() when $default != null:
return $default(_that.isDownloading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isDownloading)  $default,) {final _that = this;
switch (_that) {
case _LeaseSummaryState():
return $default(_that.isDownloading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isDownloading)?  $default,) {final _that = this;
switch (_that) {
case _LeaseSummaryState() when $default != null:
return $default(_that.isDownloading);case _:
  return null;

}
}

}

/// @nodoc


class _LeaseSummaryState implements LeaseSummaryState {
  const _LeaseSummaryState({this.isDownloading = false});
  

@override@JsonKey() final  bool isDownloading;

/// Create a copy of LeaseSummaryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaseSummaryStateCopyWith<_LeaseSummaryState> get copyWith => __$LeaseSummaryStateCopyWithImpl<_LeaseSummaryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaseSummaryState&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading));
}


@override
int get hashCode => Object.hash(runtimeType,isDownloading);

@override
String toString() {
  return 'LeaseSummaryState(isDownloading: $isDownloading)';
}


}

/// @nodoc
abstract mixin class _$LeaseSummaryStateCopyWith<$Res> implements $LeaseSummaryStateCopyWith<$Res> {
  factory _$LeaseSummaryStateCopyWith(_LeaseSummaryState value, $Res Function(_LeaseSummaryState) _then) = __$LeaseSummaryStateCopyWithImpl;
@override @useResult
$Res call({
 bool isDownloading
});




}
/// @nodoc
class __$LeaseSummaryStateCopyWithImpl<$Res>
    implements _$LeaseSummaryStateCopyWith<$Res> {
  __$LeaseSummaryStateCopyWithImpl(this._self, this._then);

  final _LeaseSummaryState _self;
  final $Res Function(_LeaseSummaryState) _then;

/// Create a copy of LeaseSummaryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDownloading = null,}) {
  return _then(_LeaseSummaryState(
isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PaymentHistoryState {

 bool get isLoading;
/// Create a copy of PaymentHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentHistoryStateCopyWith<PaymentHistoryState> get copyWith => _$PaymentHistoryStateCopyWithImpl<PaymentHistoryState>(this as PaymentHistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentHistoryState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading);

@override
String toString() {
  return 'PaymentHistoryState(isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $PaymentHistoryStateCopyWith<$Res>  {
  factory $PaymentHistoryStateCopyWith(PaymentHistoryState value, $Res Function(PaymentHistoryState) _then) = _$PaymentHistoryStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading
});




}
/// @nodoc
class _$PaymentHistoryStateCopyWithImpl<$Res>
    implements $PaymentHistoryStateCopyWith<$Res> {
  _$PaymentHistoryStateCopyWithImpl(this._self, this._then);

  final PaymentHistoryState _self;
  final $Res Function(PaymentHistoryState) _then;

/// Create a copy of PaymentHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentHistoryState].
extension PaymentHistoryStatePatterns on PaymentHistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentHistoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentHistoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentHistoryState value)  $default,){
final _that = this;
switch (_that) {
case _PaymentHistoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentHistoryState value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentHistoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentHistoryState() when $default != null:
return $default(_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _PaymentHistoryState():
return $default(_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _PaymentHistoryState() when $default != null:
return $default(_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentHistoryState implements PaymentHistoryState {
  const _PaymentHistoryState({this.isLoading = false});
  

@override@JsonKey() final  bool isLoading;

/// Create a copy of PaymentHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentHistoryStateCopyWith<_PaymentHistoryState> get copyWith => __$PaymentHistoryStateCopyWithImpl<_PaymentHistoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentHistoryState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading);

@override
String toString() {
  return 'PaymentHistoryState(isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$PaymentHistoryStateCopyWith<$Res> implements $PaymentHistoryStateCopyWith<$Res> {
  factory _$PaymentHistoryStateCopyWith(_PaymentHistoryState value, $Res Function(_PaymentHistoryState) _then) = __$PaymentHistoryStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading
});




}
/// @nodoc
class __$PaymentHistoryStateCopyWithImpl<$Res>
    implements _$PaymentHistoryStateCopyWith<$Res> {
  __$PaymentHistoryStateCopyWithImpl(this._self, this._then);

  final _PaymentHistoryState _self;
  final $Res Function(_PaymentHistoryState) _then;

/// Create a copy of PaymentHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,}) {
  return _then(_PaymentHistoryState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$MaintenanceRequestState {

 String? get issueType; String get description; bool get isEmergency; bool get hasPhoto; bool get isLoading;
/// Create a copy of MaintenanceRequestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceRequestStateCopyWith<MaintenanceRequestState> get copyWith => _$MaintenanceRequestStateCopyWithImpl<MaintenanceRequestState>(this as MaintenanceRequestState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceRequestState&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.description, description) || other.description == description)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.hasPhoto, hasPhoto) || other.hasPhoto == hasPhoto)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,issueType,description,isEmergency,hasPhoto,isLoading);

@override
String toString() {
  return 'MaintenanceRequestState(issueType: $issueType, description: $description, isEmergency: $isEmergency, hasPhoto: $hasPhoto, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $MaintenanceRequestStateCopyWith<$Res>  {
  factory $MaintenanceRequestStateCopyWith(MaintenanceRequestState value, $Res Function(MaintenanceRequestState) _then) = _$MaintenanceRequestStateCopyWithImpl;
@useResult
$Res call({
 String? issueType, String description, bool isEmergency, bool hasPhoto, bool isLoading
});




}
/// @nodoc
class _$MaintenanceRequestStateCopyWithImpl<$Res>
    implements $MaintenanceRequestStateCopyWith<$Res> {
  _$MaintenanceRequestStateCopyWithImpl(this._self, this._then);

  final MaintenanceRequestState _self;
  final $Res Function(MaintenanceRequestState) _then;

/// Create a copy of MaintenanceRequestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? issueType = freezed,Object? description = null,Object? isEmergency = null,Object? hasPhoto = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
issueType: freezed == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,hasPhoto: null == hasPhoto ? _self.hasPhoto : hasPhoto // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceRequestState].
extension MaintenanceRequestStatePatterns on MaintenanceRequestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceRequestState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceRequestState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceRequestState value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRequestState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceRequestState value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRequestState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? issueType,  String description,  bool isEmergency,  bool hasPhoto,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceRequestState() when $default != null:
return $default(_that.issueType,_that.description,_that.isEmergency,_that.hasPhoto,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? issueType,  String description,  bool isEmergency,  bool hasPhoto,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRequestState():
return $default(_that.issueType,_that.description,_that.isEmergency,_that.hasPhoto,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? issueType,  String description,  bool isEmergency,  bool hasPhoto,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRequestState() when $default != null:
return $default(_that.issueType,_that.description,_that.isEmergency,_that.hasPhoto,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _MaintenanceRequestState implements MaintenanceRequestState {
  const _MaintenanceRequestState({this.issueType, this.description = '', this.isEmergency = false, this.hasPhoto = false, this.isLoading = false});
  

@override final  String? issueType;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isEmergency;
@override@JsonKey() final  bool hasPhoto;
@override@JsonKey() final  bool isLoading;

/// Create a copy of MaintenanceRequestState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceRequestStateCopyWith<_MaintenanceRequestState> get copyWith => __$MaintenanceRequestStateCopyWithImpl<_MaintenanceRequestState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceRequestState&&(identical(other.issueType, issueType) || other.issueType == issueType)&&(identical(other.description, description) || other.description == description)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.hasPhoto, hasPhoto) || other.hasPhoto == hasPhoto)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,issueType,description,isEmergency,hasPhoto,isLoading);

@override
String toString() {
  return 'MaintenanceRequestState(issueType: $issueType, description: $description, isEmergency: $isEmergency, hasPhoto: $hasPhoto, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceRequestStateCopyWith<$Res> implements $MaintenanceRequestStateCopyWith<$Res> {
  factory _$MaintenanceRequestStateCopyWith(_MaintenanceRequestState value, $Res Function(_MaintenanceRequestState) _then) = __$MaintenanceRequestStateCopyWithImpl;
@override @useResult
$Res call({
 String? issueType, String description, bool isEmergency, bool hasPhoto, bool isLoading
});




}
/// @nodoc
class __$MaintenanceRequestStateCopyWithImpl<$Res>
    implements _$MaintenanceRequestStateCopyWith<$Res> {
  __$MaintenanceRequestStateCopyWithImpl(this._self, this._then);

  final _MaintenanceRequestState _self;
  final $Res Function(_MaintenanceRequestState) _then;

/// Create a copy of MaintenanceRequestState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issueType = freezed,Object? description = null,Object? isEmergency = null,Object? hasPhoto = null,Object? isLoading = null,}) {
  return _then(_MaintenanceRequestState(
issueType: freezed == issueType ? _self.issueType : issueType // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,hasPhoto: null == hasPhoto ? _self.hasPhoto : hasPhoto // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RequestTrackingState {

 bool get isLoading;
/// Create a copy of RequestTrackingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestTrackingStateCopyWith<RequestTrackingState> get copyWith => _$RequestTrackingStateCopyWithImpl<RequestTrackingState>(this as RequestTrackingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestTrackingState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading);

@override
String toString() {
  return 'RequestTrackingState(isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $RequestTrackingStateCopyWith<$Res>  {
  factory $RequestTrackingStateCopyWith(RequestTrackingState value, $Res Function(RequestTrackingState) _then) = _$RequestTrackingStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading
});




}
/// @nodoc
class _$RequestTrackingStateCopyWithImpl<$Res>
    implements $RequestTrackingStateCopyWith<$Res> {
  _$RequestTrackingStateCopyWithImpl(this._self, this._then);

  final RequestTrackingState _self;
  final $Res Function(RequestTrackingState) _then;

/// Create a copy of RequestTrackingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestTrackingState].
extension RequestTrackingStatePatterns on RequestTrackingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestTrackingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestTrackingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestTrackingState value)  $default,){
final _that = this;
switch (_that) {
case _RequestTrackingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestTrackingState value)?  $default,){
final _that = this;
switch (_that) {
case _RequestTrackingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestTrackingState() when $default != null:
return $default(_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _RequestTrackingState():
return $default(_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _RequestTrackingState() when $default != null:
return $default(_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _RequestTrackingState implements RequestTrackingState {
  const _RequestTrackingState({this.isLoading = false});
  

@override@JsonKey() final  bool isLoading;

/// Create a copy of RequestTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestTrackingStateCopyWith<_RequestTrackingState> get copyWith => __$RequestTrackingStateCopyWithImpl<_RequestTrackingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestTrackingState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading);

@override
String toString() {
  return 'RequestTrackingState(isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$RequestTrackingStateCopyWith<$Res> implements $RequestTrackingStateCopyWith<$Res> {
  factory _$RequestTrackingStateCopyWith(_RequestTrackingState value, $Res Function(_RequestTrackingState) _then) = __$RequestTrackingStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading
});




}
/// @nodoc
class __$RequestTrackingStateCopyWithImpl<$Res>
    implements _$RequestTrackingStateCopyWith<$Res> {
  __$RequestTrackingStateCopyWithImpl(this._self, this._then);

  final _RequestTrackingState _self;
  final $Res Function(_RequestTrackingState) _then;

/// Create a copy of RequestTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,}) {
  return _then(_RequestTrackingState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

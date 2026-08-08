// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VendorProfile {

 String get businessName; String get taxId; String get serviceCategory; String get phone; String get email; String get address; String get city; String get state; String get zip; String get tradeLicenseStatus; String get proofOfInsuranceStatus; String get w9FormStatus; bool get isOnboarded;
/// Create a copy of VendorProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorProfileCopyWith<VendorProfile> get copyWith => _$VendorProfileCopyWithImpl<VendorProfile>(this as VendorProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorProfile&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.serviceCategory, serviceCategory) || other.serviceCategory == serviceCategory)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.tradeLicenseStatus, tradeLicenseStatus) || other.tradeLicenseStatus == tradeLicenseStatus)&&(identical(other.proofOfInsuranceStatus, proofOfInsuranceStatus) || other.proofOfInsuranceStatus == proofOfInsuranceStatus)&&(identical(other.w9FormStatus, w9FormStatus) || other.w9FormStatus == w9FormStatus)&&(identical(other.isOnboarded, isOnboarded) || other.isOnboarded == isOnboarded));
}


@override
int get hashCode => Object.hash(runtimeType,businessName,taxId,serviceCategory,phone,email,address,city,state,zip,tradeLicenseStatus,proofOfInsuranceStatus,w9FormStatus,isOnboarded);

@override
String toString() {
  return 'VendorProfile(businessName: $businessName, taxId: $taxId, serviceCategory: $serviceCategory, phone: $phone, email: $email, address: $address, city: $city, state: $state, zip: $zip, tradeLicenseStatus: $tradeLicenseStatus, proofOfInsuranceStatus: $proofOfInsuranceStatus, w9FormStatus: $w9FormStatus, isOnboarded: $isOnboarded)';
}


}

/// @nodoc
abstract mixin class $VendorProfileCopyWith<$Res>  {
  factory $VendorProfileCopyWith(VendorProfile value, $Res Function(VendorProfile) _then) = _$VendorProfileCopyWithImpl;
@useResult
$Res call({
 String businessName, String taxId, String serviceCategory, String phone, String email, String address, String city, String state, String zip, String tradeLicenseStatus, String proofOfInsuranceStatus, String w9FormStatus, bool isOnboarded
});




}
/// @nodoc
class _$VendorProfileCopyWithImpl<$Res>
    implements $VendorProfileCopyWith<$Res> {
  _$VendorProfileCopyWithImpl(this._self, this._then);

  final VendorProfile _self;
  final $Res Function(VendorProfile) _then;

/// Create a copy of VendorProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? taxId = null,Object? serviceCategory = null,Object? phone = null,Object? email = null,Object? address = null,Object? city = null,Object? state = null,Object? zip = null,Object? tradeLicenseStatus = null,Object? proofOfInsuranceStatus = null,Object? w9FormStatus = null,Object? isOnboarded = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,taxId: null == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String,serviceCategory: null == serviceCategory ? _self.serviceCategory : serviceCategory // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,zip: null == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String,tradeLicenseStatus: null == tradeLicenseStatus ? _self.tradeLicenseStatus : tradeLicenseStatus // ignore: cast_nullable_to_non_nullable
as String,proofOfInsuranceStatus: null == proofOfInsuranceStatus ? _self.proofOfInsuranceStatus : proofOfInsuranceStatus // ignore: cast_nullable_to_non_nullable
as String,w9FormStatus: null == w9FormStatus ? _self.w9FormStatus : w9FormStatus // ignore: cast_nullable_to_non_nullable
as String,isOnboarded: null == isOnboarded ? _self.isOnboarded : isOnboarded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorProfile].
extension VendorProfilePatterns on VendorProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorProfile value)  $default,){
final _that = this;
switch (_that) {
case _VendorProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorProfile value)?  $default,){
final _that = this;
switch (_that) {
case _VendorProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String businessName,  String taxId,  String serviceCategory,  String phone,  String email,  String address,  String city,  String state,  String zip,  String tradeLicenseStatus,  String proofOfInsuranceStatus,  String w9FormStatus,  bool isOnboarded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorProfile() when $default != null:
return $default(_that.businessName,_that.taxId,_that.serviceCategory,_that.phone,_that.email,_that.address,_that.city,_that.state,_that.zip,_that.tradeLicenseStatus,_that.proofOfInsuranceStatus,_that.w9FormStatus,_that.isOnboarded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String businessName,  String taxId,  String serviceCategory,  String phone,  String email,  String address,  String city,  String state,  String zip,  String tradeLicenseStatus,  String proofOfInsuranceStatus,  String w9FormStatus,  bool isOnboarded)  $default,) {final _that = this;
switch (_that) {
case _VendorProfile():
return $default(_that.businessName,_that.taxId,_that.serviceCategory,_that.phone,_that.email,_that.address,_that.city,_that.state,_that.zip,_that.tradeLicenseStatus,_that.proofOfInsuranceStatus,_that.w9FormStatus,_that.isOnboarded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String businessName,  String taxId,  String serviceCategory,  String phone,  String email,  String address,  String city,  String state,  String zip,  String tradeLicenseStatus,  String proofOfInsuranceStatus,  String w9FormStatus,  bool isOnboarded)?  $default,) {final _that = this;
switch (_that) {
case _VendorProfile() when $default != null:
return $default(_that.businessName,_that.taxId,_that.serviceCategory,_that.phone,_that.email,_that.address,_that.city,_that.state,_that.zip,_that.tradeLicenseStatus,_that.proofOfInsuranceStatus,_that.w9FormStatus,_that.isOnboarded);case _:
  return null;

}
}

}

/// @nodoc


class _VendorProfile implements VendorProfile {
  const _VendorProfile({this.businessName = '', this.taxId = '', this.serviceCategory = 'Plumbing', this.phone = '', this.email = '', this.address = '', this.city = '', this.state = '', this.zip = '', this.tradeLicenseStatus = 'Upload', this.proofOfInsuranceStatus = 'Upload', this.w9FormStatus = 'Upload', this.isOnboarded = false});
  

@override@JsonKey() final  String businessName;
@override@JsonKey() final  String taxId;
@override@JsonKey() final  String serviceCategory;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey() final  String address;
@override@JsonKey() final  String city;
@override@JsonKey() final  String state;
@override@JsonKey() final  String zip;
@override@JsonKey() final  String tradeLicenseStatus;
@override@JsonKey() final  String proofOfInsuranceStatus;
@override@JsonKey() final  String w9FormStatus;
@override@JsonKey() final  bool isOnboarded;

/// Create a copy of VendorProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorProfileCopyWith<_VendorProfile> get copyWith => __$VendorProfileCopyWithImpl<_VendorProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorProfile&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&(identical(other.serviceCategory, serviceCategory) || other.serviceCategory == serviceCategory)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.tradeLicenseStatus, tradeLicenseStatus) || other.tradeLicenseStatus == tradeLicenseStatus)&&(identical(other.proofOfInsuranceStatus, proofOfInsuranceStatus) || other.proofOfInsuranceStatus == proofOfInsuranceStatus)&&(identical(other.w9FormStatus, w9FormStatus) || other.w9FormStatus == w9FormStatus)&&(identical(other.isOnboarded, isOnboarded) || other.isOnboarded == isOnboarded));
}


@override
int get hashCode => Object.hash(runtimeType,businessName,taxId,serviceCategory,phone,email,address,city,state,zip,tradeLicenseStatus,proofOfInsuranceStatus,w9FormStatus,isOnboarded);

@override
String toString() {
  return 'VendorProfile(businessName: $businessName, taxId: $taxId, serviceCategory: $serviceCategory, phone: $phone, email: $email, address: $address, city: $city, state: $state, zip: $zip, tradeLicenseStatus: $tradeLicenseStatus, proofOfInsuranceStatus: $proofOfInsuranceStatus, w9FormStatus: $w9FormStatus, isOnboarded: $isOnboarded)';
}


}

/// @nodoc
abstract mixin class _$VendorProfileCopyWith<$Res> implements $VendorProfileCopyWith<$Res> {
  factory _$VendorProfileCopyWith(_VendorProfile value, $Res Function(_VendorProfile) _then) = __$VendorProfileCopyWithImpl;
@override @useResult
$Res call({
 String businessName, String taxId, String serviceCategory, String phone, String email, String address, String city, String state, String zip, String tradeLicenseStatus, String proofOfInsuranceStatus, String w9FormStatus, bool isOnboarded
});




}
/// @nodoc
class __$VendorProfileCopyWithImpl<$Res>
    implements _$VendorProfileCopyWith<$Res> {
  __$VendorProfileCopyWithImpl(this._self, this._then);

  final _VendorProfile _self;
  final $Res Function(_VendorProfile) _then;

/// Create a copy of VendorProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? taxId = null,Object? serviceCategory = null,Object? phone = null,Object? email = null,Object? address = null,Object? city = null,Object? state = null,Object? zip = null,Object? tradeLicenseStatus = null,Object? proofOfInsuranceStatus = null,Object? w9FormStatus = null,Object? isOnboarded = null,}) {
  return _then(_VendorProfile(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,taxId: null == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String,serviceCategory: null == serviceCategory ? _self.serviceCategory : serviceCategory // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,zip: null == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String,tradeLicenseStatus: null == tradeLicenseStatus ? _self.tradeLicenseStatus : tradeLicenseStatus // ignore: cast_nullable_to_non_nullable
as String,proofOfInsuranceStatus: null == proofOfInsuranceStatus ? _self.proofOfInsuranceStatus : proofOfInsuranceStatus // ignore: cast_nullable_to_non_nullable
as String,w9FormStatus: null == w9FormStatus ? _self.w9FormStatus : w9FormStatus // ignore: cast_nullable_to_non_nullable
as String,isOnboarded: null == isOnboarded ? _self.isOnboarded : isOnboarded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$VendorWorkOrder {

 String get id; String get title; String get description; String get propertyName; String get unitName; String get tenantName; String get priority;// 'Low', 'Medium', 'High', 'Emergency'
 String get status;// 'Assigned', 'In-Progress', 'Completed'
 String get category;// 'Plumbing', 'Electrical', 'HVAC', 'General'
 String get date; String get timeSlot; String get accessInstructions; String get address; double get latitude; double get longitude; double get bidAmount; int get durationOnSite;// in seconds
 String? get checkInTime;
/// Create a copy of VendorWorkOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorWorkOrderCopyWith<VendorWorkOrder> get copyWith => _$VendorWorkOrderCopyWithImpl<VendorWorkOrder>(this as VendorWorkOrder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorWorkOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.accessInstructions, accessInstructions) || other.accessInstructions == accessInstructions)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.bidAmount, bidAmount) || other.bidAmount == bidAmount)&&(identical(other.durationOnSite, durationOnSite) || other.durationOnSite == durationOnSite)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,propertyName,unitName,tenantName,priority,status,category,date,timeSlot,accessInstructions,address,latitude,longitude,bidAmount,durationOnSite,checkInTime);

@override
String toString() {
  return 'VendorWorkOrder(id: $id, title: $title, description: $description, propertyName: $propertyName, unitName: $unitName, tenantName: $tenantName, priority: $priority, status: $status, category: $category, date: $date, timeSlot: $timeSlot, accessInstructions: $accessInstructions, address: $address, latitude: $latitude, longitude: $longitude, bidAmount: $bidAmount, durationOnSite: $durationOnSite, checkInTime: $checkInTime)';
}


}

/// @nodoc
abstract mixin class $VendorWorkOrderCopyWith<$Res>  {
  factory $VendorWorkOrderCopyWith(VendorWorkOrder value, $Res Function(VendorWorkOrder) _then) = _$VendorWorkOrderCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String propertyName, String unitName, String tenantName, String priority, String status, String category, String date, String timeSlot, String accessInstructions, String address, double latitude, double longitude, double bidAmount, int durationOnSite, String? checkInTime
});




}
/// @nodoc
class _$VendorWorkOrderCopyWithImpl<$Res>
    implements $VendorWorkOrderCopyWith<$Res> {
  _$VendorWorkOrderCopyWithImpl(this._self, this._then);

  final VendorWorkOrder _self;
  final $Res Function(VendorWorkOrder) _then;

/// Create a copy of VendorWorkOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? propertyName = null,Object? unitName = null,Object? tenantName = null,Object? priority = null,Object? status = null,Object? category = null,Object? date = null,Object? timeSlot = null,Object? accessInstructions = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? bidAmount = null,Object? durationOnSite = null,Object? checkInTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,accessInstructions: null == accessInstructions ? _self.accessInstructions : accessInstructions // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,bidAmount: null == bidAmount ? _self.bidAmount : bidAmount // ignore: cast_nullable_to_non_nullable
as double,durationOnSite: null == durationOnSite ? _self.durationOnSite : durationOnSite // ignore: cast_nullable_to_non_nullable
as int,checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorWorkOrder].
extension VendorWorkOrderPatterns on VendorWorkOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorWorkOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorWorkOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorWorkOrder value)  $default,){
final _that = this;
switch (_that) {
case _VendorWorkOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorWorkOrder value)?  $default,){
final _that = this;
switch (_that) {
case _VendorWorkOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  String category,  String date,  String timeSlot,  String accessInstructions,  String address,  double latitude,  double longitude,  double bidAmount,  int durationOnSite,  String? checkInTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorWorkOrder() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.address,_that.latitude,_that.longitude,_that.bidAmount,_that.durationOnSite,_that.checkInTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  String category,  String date,  String timeSlot,  String accessInstructions,  String address,  double latitude,  double longitude,  double bidAmount,  int durationOnSite,  String? checkInTime)  $default,) {final _that = this;
switch (_that) {
case _VendorWorkOrder():
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.address,_that.latitude,_that.longitude,_that.bidAmount,_that.durationOnSite,_that.checkInTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  String category,  String date,  String timeSlot,  String accessInstructions,  String address,  double latitude,  double longitude,  double bidAmount,  int durationOnSite,  String? checkInTime)?  $default,) {final _that = this;
switch (_that) {
case _VendorWorkOrder() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.address,_that.latitude,_that.longitude,_that.bidAmount,_that.durationOnSite,_that.checkInTime);case _:
  return null;

}
}

}

/// @nodoc


class _VendorWorkOrder implements VendorWorkOrder {
  const _VendorWorkOrder({required this.id, required this.title, required this.description, required this.propertyName, required this.unitName, required this.tenantName, required this.priority, required this.status, required this.category, required this.date, required this.timeSlot, required this.accessInstructions, required this.address, this.latitude = 47.6062, this.longitude = -122.3321, required this.bidAmount, this.durationOnSite = 0, this.checkInTime});
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String propertyName;
@override final  String unitName;
@override final  String tenantName;
@override final  String priority;
// 'Low', 'Medium', 'High', 'Emergency'
@override final  String status;
// 'Assigned', 'In-Progress', 'Completed'
@override final  String category;
// 'Plumbing', 'Electrical', 'HVAC', 'General'
@override final  String date;
@override final  String timeSlot;
@override final  String accessInstructions;
@override final  String address;
@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;
@override final  double bidAmount;
@override@JsonKey() final  int durationOnSite;
// in seconds
@override final  String? checkInTime;

/// Create a copy of VendorWorkOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorWorkOrderCopyWith<_VendorWorkOrder> get copyWith => __$VendorWorkOrderCopyWithImpl<_VendorWorkOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorWorkOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.accessInstructions, accessInstructions) || other.accessInstructions == accessInstructions)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.bidAmount, bidAmount) || other.bidAmount == bidAmount)&&(identical(other.durationOnSite, durationOnSite) || other.durationOnSite == durationOnSite)&&(identical(other.checkInTime, checkInTime) || other.checkInTime == checkInTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,propertyName,unitName,tenantName,priority,status,category,date,timeSlot,accessInstructions,address,latitude,longitude,bidAmount,durationOnSite,checkInTime);

@override
String toString() {
  return 'VendorWorkOrder(id: $id, title: $title, description: $description, propertyName: $propertyName, unitName: $unitName, tenantName: $tenantName, priority: $priority, status: $status, category: $category, date: $date, timeSlot: $timeSlot, accessInstructions: $accessInstructions, address: $address, latitude: $latitude, longitude: $longitude, bidAmount: $bidAmount, durationOnSite: $durationOnSite, checkInTime: $checkInTime)';
}


}

/// @nodoc
abstract mixin class _$VendorWorkOrderCopyWith<$Res> implements $VendorWorkOrderCopyWith<$Res> {
  factory _$VendorWorkOrderCopyWith(_VendorWorkOrder value, $Res Function(_VendorWorkOrder) _then) = __$VendorWorkOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String propertyName, String unitName, String tenantName, String priority, String status, String category, String date, String timeSlot, String accessInstructions, String address, double latitude, double longitude, double bidAmount, int durationOnSite, String? checkInTime
});




}
/// @nodoc
class __$VendorWorkOrderCopyWithImpl<$Res>
    implements _$VendorWorkOrderCopyWith<$Res> {
  __$VendorWorkOrderCopyWithImpl(this._self, this._then);

  final _VendorWorkOrder _self;
  final $Res Function(_VendorWorkOrder) _then;

/// Create a copy of VendorWorkOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? propertyName = null,Object? unitName = null,Object? tenantName = null,Object? priority = null,Object? status = null,Object? category = null,Object? date = null,Object? timeSlot = null,Object? accessInstructions = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? bidAmount = null,Object? durationOnSite = null,Object? checkInTime = freezed,}) {
  return _then(_VendorWorkOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,accessInstructions: null == accessInstructions ? _self.accessInstructions : accessInstructions // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,bidAmount: null == bidAmount ? _self.bidAmount : bidAmount // ignore: cast_nullable_to_non_nullable
as double,durationOnSite: null == durationOnSite ? _self.durationOnSite : durationOnSite // ignore: cast_nullable_to_non_nullable
as int,checkInTime: freezed == checkInTime ? _self.checkInTime : checkInTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$VendorBid {

 String get id; String get title; String get category; String get description; String get address; double get price; String get status;// 'Pending', 'Accepted', 'Rejected'
 String get dateSubmitted; List<String> get scopeChecklist; String get landlordMessage;
/// Create a copy of VendorBid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorBidCopyWith<VendorBid> get copyWith => _$VendorBidCopyWithImpl<VendorBid>(this as VendorBid, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorBid&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.dateSubmitted, dateSubmitted) || other.dateSubmitted == dateSubmitted)&&const DeepCollectionEquality().equals(other.scopeChecklist, scopeChecklist)&&(identical(other.landlordMessage, landlordMessage) || other.landlordMessage == landlordMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,category,description,address,price,status,dateSubmitted,const DeepCollectionEquality().hash(scopeChecklist),landlordMessage);

@override
String toString() {
  return 'VendorBid(id: $id, title: $title, category: $category, description: $description, address: $address, price: $price, status: $status, dateSubmitted: $dateSubmitted, scopeChecklist: $scopeChecklist, landlordMessage: $landlordMessage)';
}


}

/// @nodoc
abstract mixin class $VendorBidCopyWith<$Res>  {
  factory $VendorBidCopyWith(VendorBid value, $Res Function(VendorBid) _then) = _$VendorBidCopyWithImpl;
@useResult
$Res call({
 String id, String title, String category, String description, String address, double price, String status, String dateSubmitted, List<String> scopeChecklist, String landlordMessage
});




}
/// @nodoc
class _$VendorBidCopyWithImpl<$Res>
    implements $VendorBidCopyWith<$Res> {
  _$VendorBidCopyWithImpl(this._self, this._then);

  final VendorBid _self;
  final $Res Function(VendorBid) _then;

/// Create a copy of VendorBid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? category = null,Object? description = null,Object? address = null,Object? price = null,Object? status = null,Object? dateSubmitted = null,Object? scopeChecklist = null,Object? landlordMessage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dateSubmitted: null == dateSubmitted ? _self.dateSubmitted : dateSubmitted // ignore: cast_nullable_to_non_nullable
as String,scopeChecklist: null == scopeChecklist ? _self.scopeChecklist : scopeChecklist // ignore: cast_nullable_to_non_nullable
as List<String>,landlordMessage: null == landlordMessage ? _self.landlordMessage : landlordMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorBid].
extension VendorBidPatterns on VendorBid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorBid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorBid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorBid value)  $default,){
final _that = this;
switch (_that) {
case _VendorBid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorBid value)?  $default,){
final _that = this;
switch (_that) {
case _VendorBid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String category,  String description,  String address,  double price,  String status,  String dateSubmitted,  List<String> scopeChecklist,  String landlordMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorBid() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.description,_that.address,_that.price,_that.status,_that.dateSubmitted,_that.scopeChecklist,_that.landlordMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String category,  String description,  String address,  double price,  String status,  String dateSubmitted,  List<String> scopeChecklist,  String landlordMessage)  $default,) {final _that = this;
switch (_that) {
case _VendorBid():
return $default(_that.id,_that.title,_that.category,_that.description,_that.address,_that.price,_that.status,_that.dateSubmitted,_that.scopeChecklist,_that.landlordMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String category,  String description,  String address,  double price,  String status,  String dateSubmitted,  List<String> scopeChecklist,  String landlordMessage)?  $default,) {final _that = this;
switch (_that) {
case _VendorBid() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.description,_that.address,_that.price,_that.status,_that.dateSubmitted,_that.scopeChecklist,_that.landlordMessage);case _:
  return null;

}
}

}

/// @nodoc


class _VendorBid implements VendorBid {
  const _VendorBid({required this.id, required this.title, required this.category, required this.description, required this.address, required this.price, required this.status, required this.dateSubmitted, final  List<String> scopeChecklist = const [], this.landlordMessage = ''}): _scopeChecklist = scopeChecklist;
  

@override final  String id;
@override final  String title;
@override final  String category;
@override final  String description;
@override final  String address;
@override final  double price;
@override final  String status;
// 'Pending', 'Accepted', 'Rejected'
@override final  String dateSubmitted;
 final  List<String> _scopeChecklist;
@override@JsonKey() List<String> get scopeChecklist {
  if (_scopeChecklist is EqualUnmodifiableListView) return _scopeChecklist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopeChecklist);
}

@override@JsonKey() final  String landlordMessage;

/// Create a copy of VendorBid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorBidCopyWith<_VendorBid> get copyWith => __$VendorBidCopyWithImpl<_VendorBid>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorBid&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.dateSubmitted, dateSubmitted) || other.dateSubmitted == dateSubmitted)&&const DeepCollectionEquality().equals(other._scopeChecklist, _scopeChecklist)&&(identical(other.landlordMessage, landlordMessage) || other.landlordMessage == landlordMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,category,description,address,price,status,dateSubmitted,const DeepCollectionEquality().hash(_scopeChecklist),landlordMessage);

@override
String toString() {
  return 'VendorBid(id: $id, title: $title, category: $category, description: $description, address: $address, price: $price, status: $status, dateSubmitted: $dateSubmitted, scopeChecklist: $scopeChecklist, landlordMessage: $landlordMessage)';
}


}

/// @nodoc
abstract mixin class _$VendorBidCopyWith<$Res> implements $VendorBidCopyWith<$Res> {
  factory _$VendorBidCopyWith(_VendorBid value, $Res Function(_VendorBid) _then) = __$VendorBidCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String category, String description, String address, double price, String status, String dateSubmitted, List<String> scopeChecklist, String landlordMessage
});




}
/// @nodoc
class __$VendorBidCopyWithImpl<$Res>
    implements _$VendorBidCopyWith<$Res> {
  __$VendorBidCopyWithImpl(this._self, this._then);

  final _VendorBid _self;
  final $Res Function(_VendorBid) _then;

/// Create a copy of VendorBid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? category = null,Object? description = null,Object? address = null,Object? price = null,Object? status = null,Object? dateSubmitted = null,Object? scopeChecklist = null,Object? landlordMessage = null,}) {
  return _then(_VendorBid(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dateSubmitted: null == dateSubmitted ? _self.dateSubmitted : dateSubmitted // ignore: cast_nullable_to_non_nullable
as String,scopeChecklist: null == scopeChecklist ? _self._scopeChecklist : scopeChecklist // ignore: cast_nullable_to_non_nullable
as List<String>,landlordMessage: null == landlordMessage ? _self.landlordMessage : landlordMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$VendorPayment {

 String get id; String get invoiceNumber; double get amount; String get date; String get status;// 'Pending', 'Paid'
 String get jobTitle;
/// Create a copy of VendorPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorPaymentCopyWith<VendorPayment> get copyWith => _$VendorPaymentCopyWithImpl<VendorPayment>(this as VendorPayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle));
}


@override
int get hashCode => Object.hash(runtimeType,id,invoiceNumber,amount,date,status,jobTitle);

@override
String toString() {
  return 'VendorPayment(id: $id, invoiceNumber: $invoiceNumber, amount: $amount, date: $date, status: $status, jobTitle: $jobTitle)';
}


}

/// @nodoc
abstract mixin class $VendorPaymentCopyWith<$Res>  {
  factory $VendorPaymentCopyWith(VendorPayment value, $Res Function(VendorPayment) _then) = _$VendorPaymentCopyWithImpl;
@useResult
$Res call({
 String id, String invoiceNumber, double amount, String date, String status, String jobTitle
});




}
/// @nodoc
class _$VendorPaymentCopyWithImpl<$Res>
    implements $VendorPaymentCopyWith<$Res> {
  _$VendorPaymentCopyWithImpl(this._self, this._then);

  final VendorPayment _self;
  final $Res Function(VendorPayment) _then;

/// Create a copy of VendorPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceNumber = null,Object? amount = null,Object? date = null,Object? status = null,Object? jobTitle = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorPayment].
extension VendorPaymentPatterns on VendorPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorPayment value)  $default,){
final _that = this;
switch (_that) {
case _VendorPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorPayment value)?  $default,){
final _that = this;
switch (_that) {
case _VendorPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String invoiceNumber,  double amount,  String date,  String status,  String jobTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorPayment() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.amount,_that.date,_that.status,_that.jobTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String invoiceNumber,  double amount,  String date,  String status,  String jobTitle)  $default,) {final _that = this;
switch (_that) {
case _VendorPayment():
return $default(_that.id,_that.invoiceNumber,_that.amount,_that.date,_that.status,_that.jobTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String invoiceNumber,  double amount,  String date,  String status,  String jobTitle)?  $default,) {final _that = this;
switch (_that) {
case _VendorPayment() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.amount,_that.date,_that.status,_that.jobTitle);case _:
  return null;

}
}

}

/// @nodoc


class _VendorPayment implements VendorPayment {
  const _VendorPayment({required this.id, required this.invoiceNumber, required this.amount, required this.date, required this.status, required this.jobTitle});
  

@override final  String id;
@override final  String invoiceNumber;
@override final  double amount;
@override final  String date;
@override final  String status;
// 'Pending', 'Paid'
@override final  String jobTitle;

/// Create a copy of VendorPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorPaymentCopyWith<_VendorPayment> get copyWith => __$VendorPaymentCopyWithImpl<_VendorPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle));
}


@override
int get hashCode => Object.hash(runtimeType,id,invoiceNumber,amount,date,status,jobTitle);

@override
String toString() {
  return 'VendorPayment(id: $id, invoiceNumber: $invoiceNumber, amount: $amount, date: $date, status: $status, jobTitle: $jobTitle)';
}


}

/// @nodoc
abstract mixin class _$VendorPaymentCopyWith<$Res> implements $VendorPaymentCopyWith<$Res> {
  factory _$VendorPaymentCopyWith(_VendorPayment value, $Res Function(_VendorPayment) _then) = __$VendorPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String invoiceNumber, double amount, String date, String status, String jobTitle
});




}
/// @nodoc
class __$VendorPaymentCopyWithImpl<$Res>
    implements _$VendorPaymentCopyWith<$Res> {
  __$VendorPaymentCopyWithImpl(this._self, this._then);

  final _VendorPayment _self;
  final $Res Function(_VendorPayment) _then;

/// Create a copy of VendorPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceNumber = null,Object? amount = null,Object? date = null,Object? status = null,Object? jobTitle = null,}) {
  return _then(_VendorPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$VendorState {

 VendorProfile get profile; List<VendorWorkOrder> get activeJobs; List<VendorWorkOrder> get availableJobs; List<VendorBid> get bids; List<VendorPayment> get payments; double get earnings; double get pendingPayments; double get completedPayments; double get rating; int get jobsCount; double get onTimeRate; String get responseTime; bool get checkedIn; String? get checkedInJobId; int get elapsedSeconds; bool get isLoading;
/// Create a copy of VendorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorStateCopyWith<VendorState> get copyWith => _$VendorStateCopyWithImpl<VendorState>(this as VendorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.activeJobs, activeJobs)&&const DeepCollectionEquality().equals(other.availableJobs, availableJobs)&&const DeepCollectionEquality().equals(other.bids, bids)&&const DeepCollectionEquality().equals(other.payments, payments)&&(identical(other.earnings, earnings) || other.earnings == earnings)&&(identical(other.pendingPayments, pendingPayments) || other.pendingPayments == pendingPayments)&&(identical(other.completedPayments, completedPayments) || other.completedPayments == completedPayments)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.jobsCount, jobsCount) || other.jobsCount == jobsCount)&&(identical(other.onTimeRate, onTimeRate) || other.onTimeRate == onTimeRate)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.checkedIn, checkedIn) || other.checkedIn == checkedIn)&&(identical(other.checkedInJobId, checkedInJobId) || other.checkedInJobId == checkedInJobId)&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(activeJobs),const DeepCollectionEquality().hash(availableJobs),const DeepCollectionEquality().hash(bids),const DeepCollectionEquality().hash(payments),earnings,pendingPayments,completedPayments,rating,jobsCount,onTimeRate,responseTime,checkedIn,checkedInJobId,elapsedSeconds,isLoading);

@override
String toString() {
  return 'VendorState(profile: $profile, activeJobs: $activeJobs, availableJobs: $availableJobs, bids: $bids, payments: $payments, earnings: $earnings, pendingPayments: $pendingPayments, completedPayments: $completedPayments, rating: $rating, jobsCount: $jobsCount, onTimeRate: $onTimeRate, responseTime: $responseTime, checkedIn: $checkedIn, checkedInJobId: $checkedInJobId, elapsedSeconds: $elapsedSeconds, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $VendorStateCopyWith<$Res>  {
  factory $VendorStateCopyWith(VendorState value, $Res Function(VendorState) _then) = _$VendorStateCopyWithImpl;
@useResult
$Res call({
 VendorProfile profile, List<VendorWorkOrder> activeJobs, List<VendorWorkOrder> availableJobs, List<VendorBid> bids, List<VendorPayment> payments, double earnings, double pendingPayments, double completedPayments, double rating, int jobsCount, double onTimeRate, String responseTime, bool checkedIn, String? checkedInJobId, int elapsedSeconds, bool isLoading
});


$VendorProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$VendorStateCopyWithImpl<$Res>
    implements $VendorStateCopyWith<$Res> {
  _$VendorStateCopyWithImpl(this._self, this._then);

  final VendorState _self;
  final $Res Function(VendorState) _then;

/// Create a copy of VendorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? activeJobs = null,Object? availableJobs = null,Object? bids = null,Object? payments = null,Object? earnings = null,Object? pendingPayments = null,Object? completedPayments = null,Object? rating = null,Object? jobsCount = null,Object? onTimeRate = null,Object? responseTime = null,Object? checkedIn = null,Object? checkedInJobId = freezed,Object? elapsedSeconds = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as VendorProfile,activeJobs: null == activeJobs ? _self.activeJobs : activeJobs // ignore: cast_nullable_to_non_nullable
as List<VendorWorkOrder>,availableJobs: null == availableJobs ? _self.availableJobs : availableJobs // ignore: cast_nullable_to_non_nullable
as List<VendorWorkOrder>,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as List<VendorBid>,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<VendorPayment>,earnings: null == earnings ? _self.earnings : earnings // ignore: cast_nullable_to_non_nullable
as double,pendingPayments: null == pendingPayments ? _self.pendingPayments : pendingPayments // ignore: cast_nullable_to_non_nullable
as double,completedPayments: null == completedPayments ? _self.completedPayments : completedPayments // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,jobsCount: null == jobsCount ? _self.jobsCount : jobsCount // ignore: cast_nullable_to_non_nullable
as int,onTimeRate: null == onTimeRate ? _self.onTimeRate : onTimeRate // ignore: cast_nullable_to_non_nullable
as double,responseTime: null == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as String,checkedIn: null == checkedIn ? _self.checkedIn : checkedIn // ignore: cast_nullable_to_non_nullable
as bool,checkedInJobId: freezed == checkedInJobId ? _self.checkedInJobId : checkedInJobId // ignore: cast_nullable_to_non_nullable
as String?,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of VendorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VendorProfileCopyWith<$Res> get profile {
  
  return $VendorProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [VendorState].
extension VendorStatePatterns on VendorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorState value)  $default,){
final _that = this;
switch (_that) {
case _VendorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorState value)?  $default,){
final _that = this;
switch (_that) {
case _VendorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VendorProfile profile,  List<VendorWorkOrder> activeJobs,  List<VendorWorkOrder> availableJobs,  List<VendorBid> bids,  List<VendorPayment> payments,  double earnings,  double pendingPayments,  double completedPayments,  double rating,  int jobsCount,  double onTimeRate,  String responseTime,  bool checkedIn,  String? checkedInJobId,  int elapsedSeconds,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorState() when $default != null:
return $default(_that.profile,_that.activeJobs,_that.availableJobs,_that.bids,_that.payments,_that.earnings,_that.pendingPayments,_that.completedPayments,_that.rating,_that.jobsCount,_that.onTimeRate,_that.responseTime,_that.checkedIn,_that.checkedInJobId,_that.elapsedSeconds,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VendorProfile profile,  List<VendorWorkOrder> activeJobs,  List<VendorWorkOrder> availableJobs,  List<VendorBid> bids,  List<VendorPayment> payments,  double earnings,  double pendingPayments,  double completedPayments,  double rating,  int jobsCount,  double onTimeRate,  String responseTime,  bool checkedIn,  String? checkedInJobId,  int elapsedSeconds,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _VendorState():
return $default(_that.profile,_that.activeJobs,_that.availableJobs,_that.bids,_that.payments,_that.earnings,_that.pendingPayments,_that.completedPayments,_that.rating,_that.jobsCount,_that.onTimeRate,_that.responseTime,_that.checkedIn,_that.checkedInJobId,_that.elapsedSeconds,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VendorProfile profile,  List<VendorWorkOrder> activeJobs,  List<VendorWorkOrder> availableJobs,  List<VendorBid> bids,  List<VendorPayment> payments,  double earnings,  double pendingPayments,  double completedPayments,  double rating,  int jobsCount,  double onTimeRate,  String responseTime,  bool checkedIn,  String? checkedInJobId,  int elapsedSeconds,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _VendorState() when $default != null:
return $default(_that.profile,_that.activeJobs,_that.availableJobs,_that.bids,_that.payments,_that.earnings,_that.pendingPayments,_that.completedPayments,_that.rating,_that.jobsCount,_that.onTimeRate,_that.responseTime,_that.checkedIn,_that.checkedInJobId,_that.elapsedSeconds,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _VendorState implements VendorState {
  const _VendorState({this.profile = const VendorProfile(), final  List<VendorWorkOrder> activeJobs = const [], final  List<VendorWorkOrder> availableJobs = const [], final  List<VendorBid> bids = const [], final  List<VendorPayment> payments = const [], this.earnings = 8540.0, this.pendingPayments = 1348.0, this.completedPayments = 7208.0, this.rating = 4.8, this.jobsCount = 248, this.onTimeRate = 96.0, this.responseTime = "18 Mins", this.checkedIn = false, this.checkedInJobId, this.elapsedSeconds = 0, this.isLoading = false}): _activeJobs = activeJobs,_availableJobs = availableJobs,_bids = bids,_payments = payments;
  

@override@JsonKey() final  VendorProfile profile;
 final  List<VendorWorkOrder> _activeJobs;
@override@JsonKey() List<VendorWorkOrder> get activeJobs {
  if (_activeJobs is EqualUnmodifiableListView) return _activeJobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeJobs);
}

 final  List<VendorWorkOrder> _availableJobs;
@override@JsonKey() List<VendorWorkOrder> get availableJobs {
  if (_availableJobs is EqualUnmodifiableListView) return _availableJobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableJobs);
}

 final  List<VendorBid> _bids;
@override@JsonKey() List<VendorBid> get bids {
  if (_bids is EqualUnmodifiableListView) return _bids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bids);
}

 final  List<VendorPayment> _payments;
@override@JsonKey() List<VendorPayment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

@override@JsonKey() final  double earnings;
@override@JsonKey() final  double pendingPayments;
@override@JsonKey() final  double completedPayments;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int jobsCount;
@override@JsonKey() final  double onTimeRate;
@override@JsonKey() final  String responseTime;
@override@JsonKey() final  bool checkedIn;
@override final  String? checkedInJobId;
@override@JsonKey() final  int elapsedSeconds;
@override@JsonKey() final  bool isLoading;

/// Create a copy of VendorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorStateCopyWith<_VendorState> get copyWith => __$VendorStateCopyWithImpl<_VendorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._activeJobs, _activeJobs)&&const DeepCollectionEquality().equals(other._availableJobs, _availableJobs)&&const DeepCollectionEquality().equals(other._bids, _bids)&&const DeepCollectionEquality().equals(other._payments, _payments)&&(identical(other.earnings, earnings) || other.earnings == earnings)&&(identical(other.pendingPayments, pendingPayments) || other.pendingPayments == pendingPayments)&&(identical(other.completedPayments, completedPayments) || other.completedPayments == completedPayments)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.jobsCount, jobsCount) || other.jobsCount == jobsCount)&&(identical(other.onTimeRate, onTimeRate) || other.onTimeRate == onTimeRate)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.checkedIn, checkedIn) || other.checkedIn == checkedIn)&&(identical(other.checkedInJobId, checkedInJobId) || other.checkedInJobId == checkedInJobId)&&(identical(other.elapsedSeconds, elapsedSeconds) || other.elapsedSeconds == elapsedSeconds)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(_activeJobs),const DeepCollectionEquality().hash(_availableJobs),const DeepCollectionEquality().hash(_bids),const DeepCollectionEquality().hash(_payments),earnings,pendingPayments,completedPayments,rating,jobsCount,onTimeRate,responseTime,checkedIn,checkedInJobId,elapsedSeconds,isLoading);

@override
String toString() {
  return 'VendorState(profile: $profile, activeJobs: $activeJobs, availableJobs: $availableJobs, bids: $bids, payments: $payments, earnings: $earnings, pendingPayments: $pendingPayments, completedPayments: $completedPayments, rating: $rating, jobsCount: $jobsCount, onTimeRate: $onTimeRate, responseTime: $responseTime, checkedIn: $checkedIn, checkedInJobId: $checkedInJobId, elapsedSeconds: $elapsedSeconds, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$VendorStateCopyWith<$Res> implements $VendorStateCopyWith<$Res> {
  factory _$VendorStateCopyWith(_VendorState value, $Res Function(_VendorState) _then) = __$VendorStateCopyWithImpl;
@override @useResult
$Res call({
 VendorProfile profile, List<VendorWorkOrder> activeJobs, List<VendorWorkOrder> availableJobs, List<VendorBid> bids, List<VendorPayment> payments, double earnings, double pendingPayments, double completedPayments, double rating, int jobsCount, double onTimeRate, String responseTime, bool checkedIn, String? checkedInJobId, int elapsedSeconds, bool isLoading
});


@override $VendorProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$VendorStateCopyWithImpl<$Res>
    implements _$VendorStateCopyWith<$Res> {
  __$VendorStateCopyWithImpl(this._self, this._then);

  final _VendorState _self;
  final $Res Function(_VendorState) _then;

/// Create a copy of VendorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? activeJobs = null,Object? availableJobs = null,Object? bids = null,Object? payments = null,Object? earnings = null,Object? pendingPayments = null,Object? completedPayments = null,Object? rating = null,Object? jobsCount = null,Object? onTimeRate = null,Object? responseTime = null,Object? checkedIn = null,Object? checkedInJobId = freezed,Object? elapsedSeconds = null,Object? isLoading = null,}) {
  return _then(_VendorState(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as VendorProfile,activeJobs: null == activeJobs ? _self._activeJobs : activeJobs // ignore: cast_nullable_to_non_nullable
as List<VendorWorkOrder>,availableJobs: null == availableJobs ? _self._availableJobs : availableJobs // ignore: cast_nullable_to_non_nullable
as List<VendorWorkOrder>,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as List<VendorBid>,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<VendorPayment>,earnings: null == earnings ? _self.earnings : earnings // ignore: cast_nullable_to_non_nullable
as double,pendingPayments: null == pendingPayments ? _self.pendingPayments : pendingPayments // ignore: cast_nullable_to_non_nullable
as double,completedPayments: null == completedPayments ? _self.completedPayments : completedPayments // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,jobsCount: null == jobsCount ? _self.jobsCount : jobsCount // ignore: cast_nullable_to_non_nullable
as int,onTimeRate: null == onTimeRate ? _self.onTimeRate : onTimeRate // ignore: cast_nullable_to_non_nullable
as double,responseTime: null == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as String,checkedIn: null == checkedIn ? _self.checkedIn : checkedIn // ignore: cast_nullable_to_non_nullable
as bool,checkedInJobId: freezed == checkedInJobId ? _self.checkedInJobId : checkedInJobId // ignore: cast_nullable_to_non_nullable
as String?,elapsedSeconds: null == elapsedSeconds ? _self.elapsedSeconds : elapsedSeconds // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VendorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VendorProfileCopyWith<$Res> get profile {
  
  return $VendorProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on

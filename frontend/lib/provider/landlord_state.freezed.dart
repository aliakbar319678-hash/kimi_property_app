// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'landlord_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Property {

 String get id; String get name; String get address; double get occupancyRate; String get imageUrl; int get totalUnits; int get occupiedUnits; int get vacantUnits; double get monthlyRent;
/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyCopyWith<Property> get copyWith => _$PropertyCopyWithImpl<Property>(this as Property, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Property&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.occupiedUnits, occupiedUnits) || other.occupiedUnits == occupiedUnits)&&(identical(other.vacantUnits, vacantUnits) || other.vacantUnits == vacantUnits)&&(identical(other.monthlyRent, monthlyRent) || other.monthlyRent == monthlyRent));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,occupancyRate,imageUrl,totalUnits,occupiedUnits,vacantUnits,monthlyRent);

@override
String toString() {
  return 'Property(id: $id, name: $name, address: $address, occupancyRate: $occupancyRate, imageUrl: $imageUrl, totalUnits: $totalUnits, occupiedUnits: $occupiedUnits, vacantUnits: $vacantUnits, monthlyRent: $monthlyRent)';
}


}

/// @nodoc
abstract mixin class $PropertyCopyWith<$Res>  {
  factory $PropertyCopyWith(Property value, $Res Function(Property) _then) = _$PropertyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, double occupancyRate, String imageUrl, int totalUnits, int occupiedUnits, int vacantUnits, double monthlyRent
});




}
/// @nodoc
class _$PropertyCopyWithImpl<$Res>
    implements $PropertyCopyWith<$Res> {
  _$PropertyCopyWithImpl(this._self, this._then);

  final Property _self;
  final $Res Function(Property) _then;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? occupancyRate = null,Object? imageUrl = null,Object? totalUnits = null,Object? occupiedUnits = null,Object? vacantUnits = null,Object? monthlyRent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,occupancyRate: null == occupancyRate ? _self.occupancyRate : occupancyRate // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,occupiedUnits: null == occupiedUnits ? _self.occupiedUnits : occupiedUnits // ignore: cast_nullable_to_non_nullable
as int,vacantUnits: null == vacantUnits ? _self.vacantUnits : vacantUnits // ignore: cast_nullable_to_non_nullable
as int,monthlyRent: null == monthlyRent ? _self.monthlyRent : monthlyRent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Property].
extension PropertyPatterns on Property {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Property value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Property() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Property value)  $default,){
final _that = this;
switch (_that) {
case _Property():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Property value)?  $default,){
final _that = this;
switch (_that) {
case _Property() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  double occupancyRate,  String imageUrl,  int totalUnits,  int occupiedUnits,  int vacantUnits,  double monthlyRent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.occupancyRate,_that.imageUrl,_that.totalUnits,_that.occupiedUnits,_that.vacantUnits,_that.monthlyRent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  double occupancyRate,  String imageUrl,  int totalUnits,  int occupiedUnits,  int vacantUnits,  double monthlyRent)  $default,) {final _that = this;
switch (_that) {
case _Property():
return $default(_that.id,_that.name,_that.address,_that.occupancyRate,_that.imageUrl,_that.totalUnits,_that.occupiedUnits,_that.vacantUnits,_that.monthlyRent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  double occupancyRate,  String imageUrl,  int totalUnits,  int occupiedUnits,  int vacantUnits,  double monthlyRent)?  $default,) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.occupancyRate,_that.imageUrl,_that.totalUnits,_that.occupiedUnits,_that.vacantUnits,_that.monthlyRent);case _:
  return null;

}
}

}

/// @nodoc


class _Property implements Property {
  const _Property({required this.id, required this.name, required this.address, required this.occupancyRate, required this.imageUrl, required this.totalUnits, required this.occupiedUnits, required this.vacantUnits, required this.monthlyRent});
  

@override final  String id;
@override final  String name;
@override final  String address;
@override final  double occupancyRate;
@override final  String imageUrl;
@override final  int totalUnits;
@override final  int occupiedUnits;
@override final  int vacantUnits;
@override final  double monthlyRent;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyCopyWith<_Property> get copyWith => __$PropertyCopyWithImpl<_Property>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Property&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.occupiedUnits, occupiedUnits) || other.occupiedUnits == occupiedUnits)&&(identical(other.vacantUnits, vacantUnits) || other.vacantUnits == vacantUnits)&&(identical(other.monthlyRent, monthlyRent) || other.monthlyRent == monthlyRent));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,address,occupancyRate,imageUrl,totalUnits,occupiedUnits,vacantUnits,monthlyRent);

@override
String toString() {
  return 'Property(id: $id, name: $name, address: $address, occupancyRate: $occupancyRate, imageUrl: $imageUrl, totalUnits: $totalUnits, occupiedUnits: $occupiedUnits, vacantUnits: $vacantUnits, monthlyRent: $monthlyRent)';
}


}

/// @nodoc
abstract mixin class _$PropertyCopyWith<$Res> implements $PropertyCopyWith<$Res> {
  factory _$PropertyCopyWith(_Property value, $Res Function(_Property) _then) = __$PropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, double occupancyRate, String imageUrl, int totalUnits, int occupiedUnits, int vacantUnits, double monthlyRent
});




}
/// @nodoc
class __$PropertyCopyWithImpl<$Res>
    implements _$PropertyCopyWith<$Res> {
  __$PropertyCopyWithImpl(this._self, this._then);

  final _Property _self;
  final $Res Function(_Property) _then;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? occupancyRate = null,Object? imageUrl = null,Object? totalUnits = null,Object? occupiedUnits = null,Object? vacantUnits = null,Object? monthlyRent = null,}) {
  return _then(_Property(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,occupancyRate: null == occupancyRate ? _self.occupancyRate : occupancyRate // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,totalUnits: null == totalUnits ? _self.totalUnits : totalUnits // ignore: cast_nullable_to_non_nullable
as int,occupiedUnits: null == occupiedUnits ? _self.occupiedUnits : occupiedUnits // ignore: cast_nullable_to_non_nullable
as int,vacantUnits: null == vacantUnits ? _self.vacantUnits : vacantUnits // ignore: cast_nullable_to_non_nullable
as int,monthlyRent: null == monthlyRent ? _self.monthlyRent : monthlyRent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$Unit {

 String get id; String get name; String get status;// 'Occupied', 'Vacant', 'Maintenance'
 String get tenantName; double get rent; List<String> get amenities;
/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitCopyWith<Unit> get copyWith => _$UnitCopyWithImpl<Unit>(this as Unit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.rent, rent) || other.rent == rent)&&const DeepCollectionEquality().equals(other.amenities, amenities));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,status,tenantName,rent,const DeepCollectionEquality().hash(amenities));

@override
String toString() {
  return 'Unit(id: $id, name: $name, status: $status, tenantName: $tenantName, rent: $rent, amenities: $amenities)';
}


}

/// @nodoc
abstract mixin class $UnitCopyWith<$Res>  {
  factory $UnitCopyWith(Unit value, $Res Function(Unit) _then) = _$UnitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String status, String tenantName, double rent, List<String> amenities
});




}
/// @nodoc
class _$UnitCopyWithImpl<$Res>
    implements $UnitCopyWith<$Res> {
  _$UnitCopyWithImpl(this._self, this._then);

  final Unit _self;
  final $Res Function(Unit) _then;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? tenantName = null,Object? rent = null,Object? amenities = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,rent: null == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as double,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Unit].
extension UnitPatterns on Unit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Unit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Unit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Unit value)  $default,){
final _that = this;
switch (_that) {
case _Unit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Unit value)?  $default,){
final _that = this;
switch (_that) {
case _Unit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String status,  String tenantName,  double rent,  List<String> amenities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.tenantName,_that.rent,_that.amenities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String status,  String tenantName,  double rent,  List<String> amenities)  $default,) {final _that = this;
switch (_that) {
case _Unit():
return $default(_that.id,_that.name,_that.status,_that.tenantName,_that.rent,_that.amenities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String status,  String tenantName,  double rent,  List<String> amenities)?  $default,) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.tenantName,_that.rent,_that.amenities);case _:
  return null;

}
}

}

/// @nodoc


class _Unit implements Unit {
  const _Unit({required this.id, required this.name, required this.status, required this.tenantName, required this.rent, required final  List<String> amenities}): _amenities = amenities;
  

@override final  String id;
@override final  String name;
@override final  String status;
// 'Occupied', 'Vacant', 'Maintenance'
@override final  String tenantName;
@override final  double rent;
 final  List<String> _amenities;
@override List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}


/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitCopyWith<_Unit> get copyWith => __$UnitCopyWithImpl<_Unit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.rent, rent) || other.rent == rent)&&const DeepCollectionEquality().equals(other._amenities, _amenities));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,status,tenantName,rent,const DeepCollectionEquality().hash(_amenities));

@override
String toString() {
  return 'Unit(id: $id, name: $name, status: $status, tenantName: $tenantName, rent: $rent, amenities: $amenities)';
}


}

/// @nodoc
abstract mixin class _$UnitCopyWith<$Res> implements $UnitCopyWith<$Res> {
  factory _$UnitCopyWith(_Unit value, $Res Function(_Unit) _then) = __$UnitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String status, String tenantName, double rent, List<String> amenities
});




}
/// @nodoc
class __$UnitCopyWithImpl<$Res>
    implements _$UnitCopyWith<$Res> {
  __$UnitCopyWithImpl(this._self, this._then);

  final _Unit _self;
  final $Res Function(_Unit) _then;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? tenantName = null,Object? rent = null,Object? amenities = null,}) {
  return _then(_Unit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,rent: null == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as double,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$Tenant {

 String get id; String get name; String get unitName; String get contact; String get email; String get emergencyContactName; String get emergencyContactPhone; List<String> get memos; double get balance; String get status;// 'Active', 'Late Payment'
 String get dateJoined;
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantCopyWith<Tenant> get copyWith => _$TenantCopyWithImpl<Tenant>(this as Tenant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.email, email) || other.email == email)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&const DeepCollectionEquality().equals(other.memos, memos)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unitName,contact,email,emergencyContactName,emergencyContactPhone,const DeepCollectionEquality().hash(memos),balance,status,dateJoined);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, unitName: $unitName, contact: $contact, email: $email, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, memos: $memos, balance: $balance, status: $status, dateJoined: $dateJoined)';
}


}

/// @nodoc
abstract mixin class $TenantCopyWith<$Res>  {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) _then) = _$TenantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String unitName, String contact, String email, String emergencyContactName, String emergencyContactPhone, List<String> memos, double balance, String status, String dateJoined
});




}
/// @nodoc
class _$TenantCopyWithImpl<$Res>
    implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._self, this._then);

  final Tenant _self;
  final $Res Function(Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unitName = null,Object? contact = null,Object? email = null,Object? emergencyContactName = null,Object? emergencyContactPhone = null,Object? memos = null,Object? balance = null,Object? status = null,Object? dateJoined = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emergencyContactName: null == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String,emergencyContactPhone: null == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String,memos: null == memos ? _self.memos : memos // ignore: cast_nullable_to_non_nullable
as List<String>,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Tenant].
extension TenantPatterns on Tenant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tenant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tenant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tenant value)  $default,){
final _that = this;
switch (_that) {
case _Tenant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tenant value)?  $default,){
final _that = this;
switch (_that) {
case _Tenant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String unitName,  String contact,  String email,  String emergencyContactName,  String emergencyContactPhone,  List<String> memos,  double balance,  String status,  String dateJoined)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.unitName,_that.contact,_that.email,_that.emergencyContactName,_that.emergencyContactPhone,_that.memos,_that.balance,_that.status,_that.dateJoined);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String unitName,  String contact,  String email,  String emergencyContactName,  String emergencyContactPhone,  List<String> memos,  double balance,  String status,  String dateJoined)  $default,) {final _that = this;
switch (_that) {
case _Tenant():
return $default(_that.id,_that.name,_that.unitName,_that.contact,_that.email,_that.emergencyContactName,_that.emergencyContactPhone,_that.memos,_that.balance,_that.status,_that.dateJoined);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String unitName,  String contact,  String email,  String emergencyContactName,  String emergencyContactPhone,  List<String> memos,  double balance,  String status,  String dateJoined)?  $default,) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.unitName,_that.contact,_that.email,_that.emergencyContactName,_that.emergencyContactPhone,_that.memos,_that.balance,_that.status,_that.dateJoined);case _:
  return null;

}
}

}

/// @nodoc


class _Tenant implements Tenant {
  const _Tenant({required this.id, required this.name, required this.unitName, required this.contact, required this.email, required this.emergencyContactName, required this.emergencyContactPhone, required final  List<String> memos, required this.balance, required this.status, required this.dateJoined}): _memos = memos;
  

@override final  String id;
@override final  String name;
@override final  String unitName;
@override final  String contact;
@override final  String email;
@override final  String emergencyContactName;
@override final  String emergencyContactPhone;
 final  List<String> _memos;
@override List<String> get memos {
  if (_memos is EqualUnmodifiableListView) return _memos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memos);
}

@override final  double balance;
@override final  String status;
// 'Active', 'Late Payment'
@override final  String dateJoined;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantCopyWith<_Tenant> get copyWith => __$TenantCopyWithImpl<_Tenant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.email, email) || other.email == email)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&const DeepCollectionEquality().equals(other._memos, _memos)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unitName,contact,email,emergencyContactName,emergencyContactPhone,const DeepCollectionEquality().hash(_memos),balance,status,dateJoined);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, unitName: $unitName, contact: $contact, email: $email, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, memos: $memos, balance: $balance, status: $status, dateJoined: $dateJoined)';
}


}

/// @nodoc
abstract mixin class _$TenantCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$TenantCopyWith(_Tenant value, $Res Function(_Tenant) _then) = __$TenantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String unitName, String contact, String email, String emergencyContactName, String emergencyContactPhone, List<String> memos, double balance, String status, String dateJoined
});




}
/// @nodoc
class __$TenantCopyWithImpl<$Res>
    implements _$TenantCopyWith<$Res> {
  __$TenantCopyWithImpl(this._self, this._then);

  final _Tenant _self;
  final $Res Function(_Tenant) _then;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unitName = null,Object? contact = null,Object? email = null,Object? emergencyContactName = null,Object? emergencyContactPhone = null,Object? memos = null,Object? balance = null,Object? status = null,Object? dateJoined = null,}) {
  return _then(_Tenant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emergencyContactName: null == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String,emergencyContactPhone: null == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String,memos: null == memos ? _self._memos : memos // ignore: cast_nullable_to_non_nullable
as List<String>,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dateJoined: null == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$WorkOrder {

 String get id; String get title; String get description; String get propertyName; String get unitName; String get tenantName; String get priority;// 'Low', 'Medium', 'High', 'Emergency'
 String get status;// 'Request', 'Assigned', 'In-Progress', 'Completed'
 List<String> get photos; String get category;// 'Plumbing', 'Electrical', 'HVAC', 'General Repair', etc.
 String get date; String get timeSlot; String get accessInstructions; String? get vendorName; String? get vendorPhone; double? get bidAmount;
/// Create a copy of WorkOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkOrderCopyWith<WorkOrder> get copyWith => _$WorkOrderCopyWithImpl<WorkOrder>(this as WorkOrder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.accessInstructions, accessInstructions) || other.accessInstructions == accessInstructions)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.vendorPhone, vendorPhone) || other.vendorPhone == vendorPhone)&&(identical(other.bidAmount, bidAmount) || other.bidAmount == bidAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,propertyName,unitName,tenantName,priority,status,const DeepCollectionEquality().hash(photos),category,date,timeSlot,accessInstructions,vendorName,vendorPhone,bidAmount);

@override
String toString() {
  return 'WorkOrder(id: $id, title: $title, description: $description, propertyName: $propertyName, unitName: $unitName, tenantName: $tenantName, priority: $priority, status: $status, photos: $photos, category: $category, date: $date, timeSlot: $timeSlot, accessInstructions: $accessInstructions, vendorName: $vendorName, vendorPhone: $vendorPhone, bidAmount: $bidAmount)';
}


}

/// @nodoc
abstract mixin class $WorkOrderCopyWith<$Res>  {
  factory $WorkOrderCopyWith(WorkOrder value, $Res Function(WorkOrder) _then) = _$WorkOrderCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String propertyName, String unitName, String tenantName, String priority, String status, List<String> photos, String category, String date, String timeSlot, String accessInstructions, String? vendorName, String? vendorPhone, double? bidAmount
});




}
/// @nodoc
class _$WorkOrderCopyWithImpl<$Res>
    implements $WorkOrderCopyWith<$Res> {
  _$WorkOrderCopyWithImpl(this._self, this._then);

  final WorkOrder _self;
  final $Res Function(WorkOrder) _then;

/// Create a copy of WorkOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? propertyName = null,Object? unitName = null,Object? tenantName = null,Object? priority = null,Object? status = null,Object? photos = null,Object? category = null,Object? date = null,Object? timeSlot = null,Object? accessInstructions = null,Object? vendorName = freezed,Object? vendorPhone = freezed,Object? bidAmount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,accessInstructions: null == accessInstructions ? _self.accessInstructions : accessInstructions // ignore: cast_nullable_to_non_nullable
as String,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,vendorPhone: freezed == vendorPhone ? _self.vendorPhone : vendorPhone // ignore: cast_nullable_to_non_nullable
as String?,bidAmount: freezed == bidAmount ? _self.bidAmount : bidAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkOrder].
extension WorkOrderPatterns on WorkOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkOrder value)  $default,){
final _that = this;
switch (_that) {
case _WorkOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkOrder value)?  $default,){
final _that = this;
switch (_that) {
case _WorkOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  List<String> photos,  String category,  String date,  String timeSlot,  String accessInstructions,  String? vendorName,  String? vendorPhone,  double? bidAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkOrder() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.photos,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.vendorName,_that.vendorPhone,_that.bidAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  List<String> photos,  String category,  String date,  String timeSlot,  String accessInstructions,  String? vendorName,  String? vendorPhone,  double? bidAmount)  $default,) {final _that = this;
switch (_that) {
case _WorkOrder():
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.photos,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.vendorName,_that.vendorPhone,_that.bidAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  List<String> photos,  String category,  String date,  String timeSlot,  String accessInstructions,  String? vendorName,  String? vendorPhone,  double? bidAmount)?  $default,) {final _that = this;
switch (_that) {
case _WorkOrder() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.photos,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.vendorName,_that.vendorPhone,_that.bidAmount);case _:
  return null;

}
}

}

/// @nodoc


class _WorkOrder implements WorkOrder {
  const _WorkOrder({required this.id, required this.title, required this.description, required this.propertyName, required this.unitName, required this.tenantName, required this.priority, required this.status, required final  List<String> photos, required this.category, required this.date, required this.timeSlot, required this.accessInstructions, this.vendorName, this.vendorPhone, this.bidAmount}): _photos = photos;
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String propertyName;
@override final  String unitName;
@override final  String tenantName;
@override final  String priority;
// 'Low', 'Medium', 'High', 'Emergency'
@override final  String status;
// 'Request', 'Assigned', 'In-Progress', 'Completed'
 final  List<String> _photos;
// 'Request', 'Assigned', 'In-Progress', 'Completed'
@override List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  String category;
// 'Plumbing', 'Electrical', 'HVAC', 'General Repair', etc.
@override final  String date;
@override final  String timeSlot;
@override final  String accessInstructions;
@override final  String? vendorName;
@override final  String? vendorPhone;
@override final  double? bidAmount;

/// Create a copy of WorkOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkOrderCopyWith<_WorkOrder> get copyWith => __$WorkOrderCopyWithImpl<_WorkOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.accessInstructions, accessInstructions) || other.accessInstructions == accessInstructions)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.vendorPhone, vendorPhone) || other.vendorPhone == vendorPhone)&&(identical(other.bidAmount, bidAmount) || other.bidAmount == bidAmount));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,propertyName,unitName,tenantName,priority,status,const DeepCollectionEquality().hash(_photos),category,date,timeSlot,accessInstructions,vendorName,vendorPhone,bidAmount);

@override
String toString() {
  return 'WorkOrder(id: $id, title: $title, description: $description, propertyName: $propertyName, unitName: $unitName, tenantName: $tenantName, priority: $priority, status: $status, photos: $photos, category: $category, date: $date, timeSlot: $timeSlot, accessInstructions: $accessInstructions, vendorName: $vendorName, vendorPhone: $vendorPhone, bidAmount: $bidAmount)';
}


}

/// @nodoc
abstract mixin class _$WorkOrderCopyWith<$Res> implements $WorkOrderCopyWith<$Res> {
  factory _$WorkOrderCopyWith(_WorkOrder value, $Res Function(_WorkOrder) _then) = __$WorkOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String propertyName, String unitName, String tenantName, String priority, String status, List<String> photos, String category, String date, String timeSlot, String accessInstructions, String? vendorName, String? vendorPhone, double? bidAmount
});




}
/// @nodoc
class __$WorkOrderCopyWithImpl<$Res>
    implements _$WorkOrderCopyWith<$Res> {
  __$WorkOrderCopyWithImpl(this._self, this._then);

  final _WorkOrder _self;
  final $Res Function(_WorkOrder) _then;

/// Create a copy of WorkOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? propertyName = null,Object? unitName = null,Object? tenantName = null,Object? priority = null,Object? status = null,Object? photos = null,Object? category = null,Object? date = null,Object? timeSlot = null,Object? accessInstructions = null,Object? vendorName = freezed,Object? vendorPhone = freezed,Object? bidAmount = freezed,}) {
  return _then(_WorkOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,accessInstructions: null == accessInstructions ? _self.accessInstructions : accessInstructions // ignore: cast_nullable_to_non_nullable
as String,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,vendorPhone: freezed == vendorPhone ? _self.vendorPhone : vendorPhone // ignore: cast_nullable_to_non_nullable
as String?,bidAmount: freezed == bidAmount ? _self.bidAmount : bidAmount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$Bid {

 String get id; String get vendorName; double get rating; int get totalJobs; double get price; String get time; String get avatarUrl;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalJobs, totalJobs) || other.totalJobs == totalJobs)&&(identical(other.price, price) || other.price == price)&&(identical(other.time, time) || other.time == time)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,vendorName,rating,totalJobs,price,time,avatarUrl);

@override
String toString() {
  return 'Bid(id: $id, vendorName: $vendorName, rating: $rating, totalJobs: $totalJobs, price: $price, time: $time, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 String id, String vendorName, double rating, int totalJobs, double price, String time, String avatarUrl
});




}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vendorName = null,Object? rating = null,Object? totalJobs = null,Object? price = null,Object? time = null,Object? avatarUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalJobs: null == totalJobs ? _self.totalJobs : totalJobs // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String vendorName,  double rating,  int totalJobs,  double price,  String time,  String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.vendorName,_that.rating,_that.totalJobs,_that.price,_that.time,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String vendorName,  double rating,  int totalJobs,  double price,  String time,  String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.id,_that.vendorName,_that.rating,_that.totalJobs,_that.price,_that.time,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String vendorName,  double rating,  int totalJobs,  double price,  String time,  String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.vendorName,_that.rating,_that.totalJobs,_that.price,_that.time,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Bid implements Bid {
  const _Bid({required this.id, required this.vendorName, required this.rating, required this.totalJobs, required this.price, required this.time, required this.avatarUrl});
  

@override final  String id;
@override final  String vendorName;
@override final  double rating;
@override final  int totalJobs;
@override final  double price;
@override final  String time;
@override final  String avatarUrl;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalJobs, totalJobs) || other.totalJobs == totalJobs)&&(identical(other.price, price) || other.price == price)&&(identical(other.time, time) || other.time == time)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,vendorName,rating,totalJobs,price,time,avatarUrl);

@override
String toString() {
  return 'Bid(id: $id, vendorName: $vendorName, rating: $rating, totalJobs: $totalJobs, price: $price, time: $time, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 String id, String vendorName, double rating, int totalJobs, double price, String time, String avatarUrl
});




}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vendorName = null,Object? rating = null,Object? totalJobs = null,Object? price = null,Object? time = null,Object? avatarUrl = null,}) {
  return _then(_Bid(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalJobs: null == totalJobs ? _self.totalJobs : totalJobs // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ChatMessage {

 String get id; String get senderName; String get role;// 'Landlord', 'Vendor', 'Tenant'
 String get message; String get time;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.role, role) || other.role == role)&&(identical(other.message, message) || other.message == message)&&(identical(other.time, time) || other.time == time));
}


@override
int get hashCode => Object.hash(runtimeType,id,senderName,role,message,time);

@override
String toString() {
  return 'ChatMessage(id: $id, senderName: $senderName, role: $role, message: $message, time: $time)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String senderName, String role, String message, String time
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderName = null,Object? role = null,Object? message = null,Object? time = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderName,  String role,  String message,  String time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderName,_that.role,_that.message,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderName,  String role,  String message,  String time)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.senderName,_that.role,_that.message,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderName,  String role,  String message,  String time)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderName,_that.role,_that.message,_that.time);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.senderName, required this.role, required this.message, required this.time});
  

@override final  String id;
@override final  String senderName;
@override final  String role;
// 'Landlord', 'Vendor', 'Tenant'
@override final  String message;
@override final  String time;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.role, role) || other.role == role)&&(identical(other.message, message) || other.message == message)&&(identical(other.time, time) || other.time == time));
}


@override
int get hashCode => Object.hash(runtimeType,id,senderName,role,message,time);

@override
String toString() {
  return 'ChatMessage(id: $id, senderName: $senderName, role: $role, message: $message, time: $time)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderName, String role, String message, String time
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderName = null,Object? role = null,Object? message = null,Object? time = null,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LandlordState {

 List<Property> get properties; List<Unit> get units; List<Tenant> get tenants; List<WorkOrder> get workOrders; List<Bid> get bids; List<ChatMessage> get chatMessages; double get totalCollected; double get totalOutstanding; double get occupancyRate; bool get isLoading;
/// Create a copy of LandlordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LandlordStateCopyWith<LandlordState> get copyWith => _$LandlordStateCopyWithImpl<LandlordState>(this as LandlordState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LandlordState&&const DeepCollectionEquality().equals(other.properties, properties)&&const DeepCollectionEquality().equals(other.units, units)&&const DeepCollectionEquality().equals(other.tenants, tenants)&&const DeepCollectionEquality().equals(other.workOrders, workOrders)&&const DeepCollectionEquality().equals(other.bids, bids)&&const DeepCollectionEquality().equals(other.chatMessages, chatMessages)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.totalOutstanding, totalOutstanding) || other.totalOutstanding == totalOutstanding)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(properties),const DeepCollectionEquality().hash(units),const DeepCollectionEquality().hash(tenants),const DeepCollectionEquality().hash(workOrders),const DeepCollectionEquality().hash(bids),const DeepCollectionEquality().hash(chatMessages),totalCollected,totalOutstanding,occupancyRate,isLoading);

@override
String toString() {
  return 'LandlordState(properties: $properties, units: $units, tenants: $tenants, workOrders: $workOrders, bids: $bids, chatMessages: $chatMessages, totalCollected: $totalCollected, totalOutstanding: $totalOutstanding, occupancyRate: $occupancyRate, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $LandlordStateCopyWith<$Res>  {
  factory $LandlordStateCopyWith(LandlordState value, $Res Function(LandlordState) _then) = _$LandlordStateCopyWithImpl;
@useResult
$Res call({
 List<Property> properties, List<Unit> units, List<Tenant> tenants, List<WorkOrder> workOrders, List<Bid> bids, List<ChatMessage> chatMessages, double totalCollected, double totalOutstanding, double occupancyRate, bool isLoading
});




}
/// @nodoc
class _$LandlordStateCopyWithImpl<$Res>
    implements $LandlordStateCopyWith<$Res> {
  _$LandlordStateCopyWithImpl(this._self, this._then);

  final LandlordState _self;
  final $Res Function(LandlordState) _then;

/// Create a copy of LandlordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? properties = null,Object? units = null,Object? tenants = null,Object? workOrders = null,Object? bids = null,Object? chatMessages = null,Object? totalCollected = null,Object? totalOutstanding = null,Object? occupancyRate = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
properties: null == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as List<Property>,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as List<Unit>,tenants: null == tenants ? _self.tenants : tenants // ignore: cast_nullable_to_non_nullable
as List<Tenant>,workOrders: null == workOrders ? _self.workOrders : workOrders // ignore: cast_nullable_to_non_nullable
as List<WorkOrder>,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,chatMessages: null == chatMessages ? _self.chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,totalOutstanding: null == totalOutstanding ? _self.totalOutstanding : totalOutstanding // ignore: cast_nullable_to_non_nullable
as double,occupancyRate: null == occupancyRate ? _self.occupancyRate : occupancyRate // ignore: cast_nullable_to_non_nullable
as double,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LandlordState].
extension LandlordStatePatterns on LandlordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LandlordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LandlordState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LandlordState value)  $default,){
final _that = this;
switch (_that) {
case _LandlordState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LandlordState value)?  $default,){
final _that = this;
switch (_that) {
case _LandlordState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Property> properties,  List<Unit> units,  List<Tenant> tenants,  List<WorkOrder> workOrders,  List<Bid> bids,  List<ChatMessage> chatMessages,  double totalCollected,  double totalOutstanding,  double occupancyRate,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LandlordState() when $default != null:
return $default(_that.properties,_that.units,_that.tenants,_that.workOrders,_that.bids,_that.chatMessages,_that.totalCollected,_that.totalOutstanding,_that.occupancyRate,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Property> properties,  List<Unit> units,  List<Tenant> tenants,  List<WorkOrder> workOrders,  List<Bid> bids,  List<ChatMessage> chatMessages,  double totalCollected,  double totalOutstanding,  double occupancyRate,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _LandlordState():
return $default(_that.properties,_that.units,_that.tenants,_that.workOrders,_that.bids,_that.chatMessages,_that.totalCollected,_that.totalOutstanding,_that.occupancyRate,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Property> properties,  List<Unit> units,  List<Tenant> tenants,  List<WorkOrder> workOrders,  List<Bid> bids,  List<ChatMessage> chatMessages,  double totalCollected,  double totalOutstanding,  double occupancyRate,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _LandlordState() when $default != null:
return $default(_that.properties,_that.units,_that.tenants,_that.workOrders,_that.bids,_that.chatMessages,_that.totalCollected,_that.totalOutstanding,_that.occupancyRate,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _LandlordState implements LandlordState {
  const _LandlordState({final  List<Property> properties = const [], final  List<Unit> units = const [], final  List<Tenant> tenants = const [], final  List<WorkOrder> workOrders = const [], final  List<Bid> bids = const [], final  List<ChatMessage> chatMessages = const [], this.totalCollected = 24500.0, this.totalOutstanding = 3200.0, this.occupancyRate = 0.94, this.isLoading = false}): _properties = properties,_units = units,_tenants = tenants,_workOrders = workOrders,_bids = bids,_chatMessages = chatMessages;
  

 final  List<Property> _properties;
@override@JsonKey() List<Property> get properties {
  if (_properties is EqualUnmodifiableListView) return _properties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_properties);
}

 final  List<Unit> _units;
@override@JsonKey() List<Unit> get units {
  if (_units is EqualUnmodifiableListView) return _units;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_units);
}

 final  List<Tenant> _tenants;
@override@JsonKey() List<Tenant> get tenants {
  if (_tenants is EqualUnmodifiableListView) return _tenants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tenants);
}

 final  List<WorkOrder> _workOrders;
@override@JsonKey() List<WorkOrder> get workOrders {
  if (_workOrders is EqualUnmodifiableListView) return _workOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workOrders);
}

 final  List<Bid> _bids;
@override@JsonKey() List<Bid> get bids {
  if (_bids is EqualUnmodifiableListView) return _bids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bids);
}

 final  List<ChatMessage> _chatMessages;
@override@JsonKey() List<ChatMessage> get chatMessages {
  if (_chatMessages is EqualUnmodifiableListView) return _chatMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chatMessages);
}

@override@JsonKey() final  double totalCollected;
@override@JsonKey() final  double totalOutstanding;
@override@JsonKey() final  double occupancyRate;
@override@JsonKey() final  bool isLoading;

/// Create a copy of LandlordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LandlordStateCopyWith<_LandlordState> get copyWith => __$LandlordStateCopyWithImpl<_LandlordState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LandlordState&&const DeepCollectionEquality().equals(other._properties, _properties)&&const DeepCollectionEquality().equals(other._units, _units)&&const DeepCollectionEquality().equals(other._tenants, _tenants)&&const DeepCollectionEquality().equals(other._workOrders, _workOrders)&&const DeepCollectionEquality().equals(other._bids, _bids)&&const DeepCollectionEquality().equals(other._chatMessages, _chatMessages)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.totalOutstanding, totalOutstanding) || other.totalOutstanding == totalOutstanding)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_properties),const DeepCollectionEquality().hash(_units),const DeepCollectionEquality().hash(_tenants),const DeepCollectionEquality().hash(_workOrders),const DeepCollectionEquality().hash(_bids),const DeepCollectionEquality().hash(_chatMessages),totalCollected,totalOutstanding,occupancyRate,isLoading);

@override
String toString() {
  return 'LandlordState(properties: $properties, units: $units, tenants: $tenants, workOrders: $workOrders, bids: $bids, chatMessages: $chatMessages, totalCollected: $totalCollected, totalOutstanding: $totalOutstanding, occupancyRate: $occupancyRate, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$LandlordStateCopyWith<$Res> implements $LandlordStateCopyWith<$Res> {
  factory _$LandlordStateCopyWith(_LandlordState value, $Res Function(_LandlordState) _then) = __$LandlordStateCopyWithImpl;
@override @useResult
$Res call({
 List<Property> properties, List<Unit> units, List<Tenant> tenants, List<WorkOrder> workOrders, List<Bid> bids, List<ChatMessage> chatMessages, double totalCollected, double totalOutstanding, double occupancyRate, bool isLoading
});




}
/// @nodoc
class __$LandlordStateCopyWithImpl<$Res>
    implements _$LandlordStateCopyWith<$Res> {
  __$LandlordStateCopyWithImpl(this._self, this._then);

  final _LandlordState _self;
  final $Res Function(_LandlordState) _then;

/// Create a copy of LandlordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? properties = null,Object? units = null,Object? tenants = null,Object? workOrders = null,Object? bids = null,Object? chatMessages = null,Object? totalCollected = null,Object? totalOutstanding = null,Object? occupancyRate = null,Object? isLoading = null,}) {
  return _then(_LandlordState(
properties: null == properties ? _self._properties : properties // ignore: cast_nullable_to_non_nullable
as List<Property>,units: null == units ? _self._units : units // ignore: cast_nullable_to_non_nullable
as List<Unit>,tenants: null == tenants ? _self._tenants : tenants // ignore: cast_nullable_to_non_nullable
as List<Tenant>,workOrders: null == workOrders ? _self._workOrders : workOrders // ignore: cast_nullable_to_non_nullable
as List<WorkOrder>,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,chatMessages: null == chatMessages ? _self._chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,totalOutstanding: null == totalOutstanding ? _self.totalOutstanding : totalOutstanding // ignore: cast_nullable_to_non_nullable
as double,occupancyRate: null == occupancyRate ? _self.occupancyRate : occupancyRate // ignore: cast_nullable_to_non_nullable
as double,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

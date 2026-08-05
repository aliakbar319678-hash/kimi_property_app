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

 String get id; String get name; String get address; double get occupancyRate; String get imageUrl; int get totalUnits; int get occupiedUnits; int get vacantUnits; double get monthlyRent;// Extra backend fields
 String get type; List<String> get amenities; String get description; String get status;// Approval workflow fields
 String get verificationStatus;// 'pending' | 'approved' | 'rejected' | 'needs_revision' | 'resubmitted' | 'permanently_rejected'
 String? get rejectionReason; int get resubmissionCount; List<dynamic> get requestedDocuments; bool get isPermanentlyRejected; List<dynamic> get revisionHistory;// Extra dynamic fields
 Map<String, dynamic> get metadata; double get latitude; double get longitude;
/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyCopyWith<Property> get copyWith => _$PropertyCopyWithImpl<Property>(this as Property, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Property&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.occupiedUnits, occupiedUnits) || other.occupiedUnits == occupiedUnits)&&(identical(other.vacantUnits, vacantUnits) || other.vacantUnits == vacantUnits)&&(identical(other.monthlyRent, monthlyRent) || other.monthlyRent == monthlyRent)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.resubmissionCount, resubmissionCount) || other.resubmissionCount == resubmissionCount)&&const DeepCollectionEquality().equals(other.requestedDocuments, requestedDocuments)&&(identical(other.isPermanentlyRejected, isPermanentlyRejected) || other.isPermanentlyRejected == isPermanentlyRejected)&&const DeepCollectionEquality().equals(other.revisionHistory, revisionHistory)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,address,occupancyRate,imageUrl,totalUnits,occupiedUnits,vacantUnits,monthlyRent,type,const DeepCollectionEquality().hash(amenities),description,status,verificationStatus,rejectionReason,resubmissionCount,const DeepCollectionEquality().hash(requestedDocuments),isPermanentlyRejected,const DeepCollectionEquality().hash(revisionHistory),const DeepCollectionEquality().hash(metadata),latitude,longitude]);

@override
String toString() {
  return 'Property(id: $id, name: $name, address: $address, occupancyRate: $occupancyRate, imageUrl: $imageUrl, totalUnits: $totalUnits, occupiedUnits: $occupiedUnits, vacantUnits: $vacantUnits, monthlyRent: $monthlyRent, type: $type, amenities: $amenities, description: $description, status: $status, verificationStatus: $verificationStatus, rejectionReason: $rejectionReason, resubmissionCount: $resubmissionCount, requestedDocuments: $requestedDocuments, isPermanentlyRejected: $isPermanentlyRejected, revisionHistory: $revisionHistory, metadata: $metadata, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $PropertyCopyWith<$Res>  {
  factory $PropertyCopyWith(Property value, $Res Function(Property) _then) = _$PropertyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, double occupancyRate, String imageUrl, int totalUnits, int occupiedUnits, int vacantUnits, double monthlyRent, String type, List<String> amenities, String description, String status, String verificationStatus, String? rejectionReason, int resubmissionCount, List<dynamic> requestedDocuments, bool isPermanentlyRejected, List<dynamic> revisionHistory, Map<String, dynamic> metadata, double latitude, double longitude
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? occupancyRate = null,Object? imageUrl = null,Object? totalUnits = null,Object? occupiedUnits = null,Object? vacantUnits = null,Object? monthlyRent = null,Object? type = null,Object? amenities = null,Object? description = null,Object? status = null,Object? verificationStatus = null,Object? rejectionReason = freezed,Object? resubmissionCount = null,Object? requestedDocuments = null,Object? isPermanentlyRejected = null,Object? revisionHistory = null,Object? metadata = null,Object? latitude = null,Object? longitude = null,}) {
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
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,resubmissionCount: null == resubmissionCount ? _self.resubmissionCount : resubmissionCount // ignore: cast_nullable_to_non_nullable
as int,requestedDocuments: null == requestedDocuments ? _self.requestedDocuments : requestedDocuments // ignore: cast_nullable_to_non_nullable
as List<dynamic>,isPermanentlyRejected: null == isPermanentlyRejected ? _self.isPermanentlyRejected : isPermanentlyRejected // ignore: cast_nullable_to_non_nullable
as bool,revisionHistory: null == revisionHistory ? _self.revisionHistory : revisionHistory // ignore: cast_nullable_to_non_nullable
as List<dynamic>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  double occupancyRate,  String imageUrl,  int totalUnits,  int occupiedUnits,  int vacantUnits,  double monthlyRent,  String type,  List<String> amenities,  String description,  String status,  String verificationStatus,  String? rejectionReason,  int resubmissionCount,  List<dynamic> requestedDocuments,  bool isPermanentlyRejected,  List<dynamic> revisionHistory,  Map<String, dynamic> metadata,  double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.occupancyRate,_that.imageUrl,_that.totalUnits,_that.occupiedUnits,_that.vacantUnits,_that.monthlyRent,_that.type,_that.amenities,_that.description,_that.status,_that.verificationStatus,_that.rejectionReason,_that.resubmissionCount,_that.requestedDocuments,_that.isPermanentlyRejected,_that.revisionHistory,_that.metadata,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  double occupancyRate,  String imageUrl,  int totalUnits,  int occupiedUnits,  int vacantUnits,  double monthlyRent,  String type,  List<String> amenities,  String description,  String status,  String verificationStatus,  String? rejectionReason,  int resubmissionCount,  List<dynamic> requestedDocuments,  bool isPermanentlyRejected,  List<dynamic> revisionHistory,  Map<String, dynamic> metadata,  double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _Property():
return $default(_that.id,_that.name,_that.address,_that.occupancyRate,_that.imageUrl,_that.totalUnits,_that.occupiedUnits,_that.vacantUnits,_that.monthlyRent,_that.type,_that.amenities,_that.description,_that.status,_that.verificationStatus,_that.rejectionReason,_that.resubmissionCount,_that.requestedDocuments,_that.isPermanentlyRejected,_that.revisionHistory,_that.metadata,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  double occupancyRate,  String imageUrl,  int totalUnits,  int occupiedUnits,  int vacantUnits,  double monthlyRent,  String type,  List<String> amenities,  String description,  String status,  String verificationStatus,  String? rejectionReason,  int resubmissionCount,  List<dynamic> requestedDocuments,  bool isPermanentlyRejected,  List<dynamic> revisionHistory,  Map<String, dynamic> metadata,  double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.occupancyRate,_that.imageUrl,_that.totalUnits,_that.occupiedUnits,_that.vacantUnits,_that.monthlyRent,_that.type,_that.amenities,_that.description,_that.status,_that.verificationStatus,_that.rejectionReason,_that.resubmissionCount,_that.requestedDocuments,_that.isPermanentlyRejected,_that.revisionHistory,_that.metadata,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc


class _Property implements Property {
  const _Property({required this.id, required this.name, required this.address, required this.occupancyRate, required this.imageUrl, required this.totalUnits, required this.occupiedUnits, required this.vacantUnits, required this.monthlyRent, this.type = 'apartment', final  List<String> amenities = const [], this.description = '', this.status = 'active', this.verificationStatus = 'pending', this.rejectionReason = null, this.resubmissionCount = 0, final  List<dynamic> requestedDocuments = const [], this.isPermanentlyRejected = false, final  List<dynamic> revisionHistory = const [], final  Map<String, dynamic> metadata = const {}, this.latitude = 31.5204, this.longitude = 74.3587}): _amenities = amenities,_requestedDocuments = requestedDocuments,_revisionHistory = revisionHistory,_metadata = metadata;
  

@override final  String id;
@override final  String name;
@override final  String address;
@override final  double occupancyRate;
@override final  String imageUrl;
@override final  int totalUnits;
@override final  int occupiedUnits;
@override final  int vacantUnits;
@override final  double monthlyRent;
// Extra backend fields
@override@JsonKey() final  String type;
 final  List<String> _amenities;
@override@JsonKey() List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

@override@JsonKey() final  String description;
@override@JsonKey() final  String status;
// Approval workflow fields
@override@JsonKey() final  String verificationStatus;
// 'pending' | 'approved' | 'rejected' | 'needs_revision' | 'resubmitted' | 'permanently_rejected'
@override@JsonKey() final  String? rejectionReason;
@override@JsonKey() final  int resubmissionCount;
 final  List<dynamic> _requestedDocuments;
@override@JsonKey() List<dynamic> get requestedDocuments {
  if (_requestedDocuments is EqualUnmodifiableListView) return _requestedDocuments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requestedDocuments);
}

@override@JsonKey() final  bool isPermanentlyRejected;
 final  List<dynamic> _revisionHistory;
@override@JsonKey() List<dynamic> get revisionHistory {
  if (_revisionHistory is EqualUnmodifiableListView) return _revisionHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revisionHistory);
}

// Extra dynamic fields
 final  Map<String, dynamic> _metadata;
// Extra dynamic fields
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override@JsonKey() final  double latitude;
@override@JsonKey() final  double longitude;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyCopyWith<_Property> get copyWith => __$PropertyCopyWithImpl<_Property>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Property&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.totalUnits, totalUnits) || other.totalUnits == totalUnits)&&(identical(other.occupiedUnits, occupiedUnits) || other.occupiedUnits == occupiedUnits)&&(identical(other.vacantUnits, vacantUnits) || other.vacantUnits == vacantUnits)&&(identical(other.monthlyRent, monthlyRent) || other.monthlyRent == monthlyRent)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.resubmissionCount, resubmissionCount) || other.resubmissionCount == resubmissionCount)&&const DeepCollectionEquality().equals(other._requestedDocuments, _requestedDocuments)&&(identical(other.isPermanentlyRejected, isPermanentlyRejected) || other.isPermanentlyRejected == isPermanentlyRejected)&&const DeepCollectionEquality().equals(other._revisionHistory, _revisionHistory)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,address,occupancyRate,imageUrl,totalUnits,occupiedUnits,vacantUnits,monthlyRent,type,const DeepCollectionEquality().hash(_amenities),description,status,verificationStatus,rejectionReason,resubmissionCount,const DeepCollectionEquality().hash(_requestedDocuments),isPermanentlyRejected,const DeepCollectionEquality().hash(_revisionHistory),const DeepCollectionEquality().hash(_metadata),latitude,longitude]);

@override
String toString() {
  return 'Property(id: $id, name: $name, address: $address, occupancyRate: $occupancyRate, imageUrl: $imageUrl, totalUnits: $totalUnits, occupiedUnits: $occupiedUnits, vacantUnits: $vacantUnits, monthlyRent: $monthlyRent, type: $type, amenities: $amenities, description: $description, status: $status, verificationStatus: $verificationStatus, rejectionReason: $rejectionReason, resubmissionCount: $resubmissionCount, requestedDocuments: $requestedDocuments, isPermanentlyRejected: $isPermanentlyRejected, revisionHistory: $revisionHistory, metadata: $metadata, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$PropertyCopyWith<$Res> implements $PropertyCopyWith<$Res> {
  factory _$PropertyCopyWith(_Property value, $Res Function(_Property) _then) = __$PropertyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, double occupancyRate, String imageUrl, int totalUnits, int occupiedUnits, int vacantUnits, double monthlyRent, String type, List<String> amenities, String description, String status, String verificationStatus, String? rejectionReason, int resubmissionCount, List<dynamic> requestedDocuments, bool isPermanentlyRejected, List<dynamic> revisionHistory, Map<String, dynamic> metadata, double latitude, double longitude
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? occupancyRate = null,Object? imageUrl = null,Object? totalUnits = null,Object? occupiedUnits = null,Object? vacantUnits = null,Object? monthlyRent = null,Object? type = null,Object? amenities = null,Object? description = null,Object? status = null,Object? verificationStatus = null,Object? rejectionReason = freezed,Object? resubmissionCount = null,Object? requestedDocuments = null,Object? isPermanentlyRejected = null,Object? revisionHistory = null,Object? metadata = null,Object? latitude = null,Object? longitude = null,}) {
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
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,resubmissionCount: null == resubmissionCount ? _self.resubmissionCount : resubmissionCount // ignore: cast_nullable_to_non_nullable
as int,requestedDocuments: null == requestedDocuments ? _self._requestedDocuments : requestedDocuments // ignore: cast_nullable_to_non_nullable
as List<dynamic>,isPermanentlyRejected: null == isPermanentlyRejected ? _self.isPermanentlyRejected : isPermanentlyRejected // ignore: cast_nullable_to_non_nullable
as bool,revisionHistory: null == revisionHistory ? _self._revisionHistory : revisionHistory // ignore: cast_nullable_to_non_nullable
as List<dynamic>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$Unit {

 String get id; String get name; String get status;// 'occupied', 'vacant', 'maintenance', 'reserved'
 String get tenantName; double get rent; List<String> get amenities;// Extra backend fields
 int get bedrooms; int get bathrooms; int get squareFeet; double get depositAmount; String get availableDate; String get propertyId;
/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitCopyWith<Unit> get copyWith => _$UnitCopyWithImpl<Unit>(this as Unit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.rent, rent) || other.rent == rent)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&(identical(other.bedrooms, bedrooms) || other.bedrooms == bedrooms)&&(identical(other.bathrooms, bathrooms) || other.bathrooms == bathrooms)&&(identical(other.squareFeet, squareFeet) || other.squareFeet == squareFeet)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.availableDate, availableDate) || other.availableDate == availableDate)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,status,tenantName,rent,const DeepCollectionEquality().hash(amenities),bedrooms,bathrooms,squareFeet,depositAmount,availableDate,propertyId);

@override
String toString() {
  return 'Unit(id: $id, name: $name, status: $status, tenantName: $tenantName, rent: $rent, amenities: $amenities, bedrooms: $bedrooms, bathrooms: $bathrooms, squareFeet: $squareFeet, depositAmount: $depositAmount, availableDate: $availableDate, propertyId: $propertyId)';
}


}

/// @nodoc
abstract mixin class $UnitCopyWith<$Res>  {
  factory $UnitCopyWith(Unit value, $Res Function(Unit) _then) = _$UnitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String status, String tenantName, double rent, List<String> amenities, int bedrooms, int bathrooms, int squareFeet, double depositAmount, String availableDate, String propertyId
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? tenantName = null,Object? rent = null,Object? amenities = null,Object? bedrooms = null,Object? bathrooms = null,Object? squareFeet = null,Object? depositAmount = null,Object? availableDate = null,Object? propertyId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,rent: null == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as double,amenities: null == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,bedrooms: null == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int,bathrooms: null == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int,squareFeet: null == squareFeet ? _self.squareFeet : squareFeet // ignore: cast_nullable_to_non_nullable
as int,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,availableDate: null == availableDate ? _self.availableDate : availableDate // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String status,  String tenantName,  double rent,  List<String> amenities,  int bedrooms,  int bathrooms,  int squareFeet,  double depositAmount,  String availableDate,  String propertyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.tenantName,_that.rent,_that.amenities,_that.bedrooms,_that.bathrooms,_that.squareFeet,_that.depositAmount,_that.availableDate,_that.propertyId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String status,  String tenantName,  double rent,  List<String> amenities,  int bedrooms,  int bathrooms,  int squareFeet,  double depositAmount,  String availableDate,  String propertyId)  $default,) {final _that = this;
switch (_that) {
case _Unit():
return $default(_that.id,_that.name,_that.status,_that.tenantName,_that.rent,_that.amenities,_that.bedrooms,_that.bathrooms,_that.squareFeet,_that.depositAmount,_that.availableDate,_that.propertyId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String status,  String tenantName,  double rent,  List<String> amenities,  int bedrooms,  int bathrooms,  int squareFeet,  double depositAmount,  String availableDate,  String propertyId)?  $default,) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.tenantName,_that.rent,_that.amenities,_that.bedrooms,_that.bathrooms,_that.squareFeet,_that.depositAmount,_that.availableDate,_that.propertyId);case _:
  return null;

}
}

}

/// @nodoc


class _Unit implements Unit {
  const _Unit({required this.id, required this.name, required this.status, required this.tenantName, required this.rent, required final  List<String> amenities, this.bedrooms = 0, this.bathrooms = 0, this.squareFeet = 0, this.depositAmount = 0.0, this.availableDate = '', this.propertyId = ''}): _amenities = amenities;
  

@override final  String id;
@override final  String name;
@override final  String status;
// 'occupied', 'vacant', 'maintenance', 'reserved'
@override final  String tenantName;
@override final  double rent;
 final  List<String> _amenities;
@override List<String> get amenities {
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amenities);
}

// Extra backend fields
@override@JsonKey() final  int bedrooms;
@override@JsonKey() final  int bathrooms;
@override@JsonKey() final  int squareFeet;
@override@JsonKey() final  double depositAmount;
@override@JsonKey() final  String availableDate;
@override@JsonKey() final  String propertyId;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitCopyWith<_Unit> get copyWith => __$UnitCopyWithImpl<_Unit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.rent, rent) || other.rent == rent)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&(identical(other.bedrooms, bedrooms) || other.bedrooms == bedrooms)&&(identical(other.bathrooms, bathrooms) || other.bathrooms == bathrooms)&&(identical(other.squareFeet, squareFeet) || other.squareFeet == squareFeet)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.availableDate, availableDate) || other.availableDate == availableDate)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,status,tenantName,rent,const DeepCollectionEquality().hash(_amenities),bedrooms,bathrooms,squareFeet,depositAmount,availableDate,propertyId);

@override
String toString() {
  return 'Unit(id: $id, name: $name, status: $status, tenantName: $tenantName, rent: $rent, amenities: $amenities, bedrooms: $bedrooms, bathrooms: $bathrooms, squareFeet: $squareFeet, depositAmount: $depositAmount, availableDate: $availableDate, propertyId: $propertyId)';
}


}

/// @nodoc
abstract mixin class _$UnitCopyWith<$Res> implements $UnitCopyWith<$Res> {
  factory _$UnitCopyWith(_Unit value, $Res Function(_Unit) _then) = __$UnitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String status, String tenantName, double rent, List<String> amenities, int bedrooms, int bathrooms, int squareFeet, double depositAmount, String availableDate, String propertyId
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? tenantName = null,Object? rent = null,Object? amenities = null,Object? bedrooms = null,Object? bathrooms = null,Object? squareFeet = null,Object? depositAmount = null,Object? availableDate = null,Object? propertyId = null,}) {
  return _then(_Unit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,rent: null == rent ? _self.rent : rent // ignore: cast_nullable_to_non_nullable
as double,amenities: null == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<String>,bedrooms: null == bedrooms ? _self.bedrooms : bedrooms // ignore: cast_nullable_to_non_nullable
as int,bathrooms: null == bathrooms ? _self.bathrooms : bathrooms // ignore: cast_nullable_to_non_nullable
as int,squareFeet: null == squareFeet ? _self.squareFeet : squareFeet // ignore: cast_nullable_to_non_nullable
as int,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,availableDate: null == availableDate ? _self.availableDate : availableDate // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Tenant {

 String get id; String get name; String get unitName; String get contact; String get email; String get emergencyContactName; String get emergencyContactPhone; List<String> get memos; double get balance; String get status;// 'Active', 'Late Payment'
 String get dateJoined;// Extra lease-linked fields
 String get propertyName; String get leaseEndDate; double get rentAmount; String get avatarUrl;
/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantCopyWith<Tenant> get copyWith => _$TenantCopyWithImpl<Tenant>(this as Tenant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.email, email) || other.email == email)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&const DeepCollectionEquality().equals(other.memos, memos)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.leaseEndDate, leaseEndDate) || other.leaseEndDate == leaseEndDate)&&(identical(other.rentAmount, rentAmount) || other.rentAmount == rentAmount)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unitName,contact,email,emergencyContactName,emergencyContactPhone,const DeepCollectionEquality().hash(memos),balance,status,dateJoined,propertyName,leaseEndDate,rentAmount,avatarUrl);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, unitName: $unitName, contact: $contact, email: $email, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, memos: $memos, balance: $balance, status: $status, dateJoined: $dateJoined, propertyName: $propertyName, leaseEndDate: $leaseEndDate, rentAmount: $rentAmount, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $TenantCopyWith<$Res>  {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) _then) = _$TenantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String unitName, String contact, String email, String emergencyContactName, String emergencyContactPhone, List<String> memos, double balance, String status, String dateJoined, String propertyName, String leaseEndDate, double rentAmount, String avatarUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unitName = null,Object? contact = null,Object? email = null,Object? emergencyContactName = null,Object? emergencyContactPhone = null,Object? memos = null,Object? balance = null,Object? status = null,Object? dateJoined = null,Object? propertyName = null,Object? leaseEndDate = null,Object? rentAmount = null,Object? avatarUrl = null,}) {
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
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,leaseEndDate: null == leaseEndDate ? _self.leaseEndDate : leaseEndDate // ignore: cast_nullable_to_non_nullable
as String,rentAmount: null == rentAmount ? _self.rentAmount : rentAmount // ignore: cast_nullable_to_non_nullable
as double,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String unitName,  String contact,  String email,  String emergencyContactName,  String emergencyContactPhone,  List<String> memos,  double balance,  String status,  String dateJoined,  String propertyName,  String leaseEndDate,  double rentAmount,  String avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.unitName,_that.contact,_that.email,_that.emergencyContactName,_that.emergencyContactPhone,_that.memos,_that.balance,_that.status,_that.dateJoined,_that.propertyName,_that.leaseEndDate,_that.rentAmount,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String unitName,  String contact,  String email,  String emergencyContactName,  String emergencyContactPhone,  List<String> memos,  double balance,  String status,  String dateJoined,  String propertyName,  String leaseEndDate,  double rentAmount,  String avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _Tenant():
return $default(_that.id,_that.name,_that.unitName,_that.contact,_that.email,_that.emergencyContactName,_that.emergencyContactPhone,_that.memos,_that.balance,_that.status,_that.dateJoined,_that.propertyName,_that.leaseEndDate,_that.rentAmount,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String unitName,  String contact,  String email,  String emergencyContactName,  String emergencyContactPhone,  List<String> memos,  double balance,  String status,  String dateJoined,  String propertyName,  String leaseEndDate,  double rentAmount,  String avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _Tenant() when $default != null:
return $default(_that.id,_that.name,_that.unitName,_that.contact,_that.email,_that.emergencyContactName,_that.emergencyContactPhone,_that.memos,_that.balance,_that.status,_that.dateJoined,_that.propertyName,_that.leaseEndDate,_that.rentAmount,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Tenant implements Tenant {
  const _Tenant({required this.id, required this.name, required this.unitName, required this.contact, required this.email, required this.emergencyContactName, required this.emergencyContactPhone, required final  List<String> memos, required this.balance, required this.status, required this.dateJoined, this.propertyName = '', this.leaseEndDate = '', this.rentAmount = 0.0, this.avatarUrl = ''}): _memos = memos;
  

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
// Extra lease-linked fields
@override@JsonKey() final  String propertyName;
@override@JsonKey() final  String leaseEndDate;
@override@JsonKey() final  double rentAmount;
@override@JsonKey() final  String avatarUrl;

/// Create a copy of Tenant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantCopyWith<_Tenant> get copyWith => __$TenantCopyWithImpl<_Tenant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tenant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.email, email) || other.email == email)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&const DeepCollectionEquality().equals(other._memos, _memos)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.status, status) || other.status == status)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.leaseEndDate, leaseEndDate) || other.leaseEndDate == leaseEndDate)&&(identical(other.rentAmount, rentAmount) || other.rentAmount == rentAmount)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,unitName,contact,email,emergencyContactName,emergencyContactPhone,const DeepCollectionEquality().hash(_memos),balance,status,dateJoined,propertyName,leaseEndDate,rentAmount,avatarUrl);

@override
String toString() {
  return 'Tenant(id: $id, name: $name, unitName: $unitName, contact: $contact, email: $email, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, memos: $memos, balance: $balance, status: $status, dateJoined: $dateJoined, propertyName: $propertyName, leaseEndDate: $leaseEndDate, rentAmount: $rentAmount, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$TenantCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$TenantCopyWith(_Tenant value, $Res Function(_Tenant) _then) = __$TenantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String unitName, String contact, String email, String emergencyContactName, String emergencyContactPhone, List<String> memos, double balance, String status, String dateJoined, String propertyName, String leaseEndDate, double rentAmount, String avatarUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unitName = null,Object? contact = null,Object? email = null,Object? emergencyContactName = null,Object? emergencyContactPhone = null,Object? memos = null,Object? balance = null,Object? status = null,Object? dateJoined = null,Object? propertyName = null,Object? leaseEndDate = null,Object? rentAmount = null,Object? avatarUrl = null,}) {
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
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,leaseEndDate: null == leaseEndDate ? _self.leaseEndDate : leaseEndDate // ignore: cast_nullable_to_non_nullable
as String,rentAmount: null == rentAmount ? _self.rentAmount : rentAmount // ignore: cast_nullable_to_non_nullable
as double,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$WorkOrder {

 String get id; String get title; String get description; String get propertyName; String get unitName; String get tenantName; String get priority;// 'Low', 'Medium', 'High', 'Emergency'
 String get status;// 'Request', 'Assigned', 'In-Progress', 'Completed'
 List<String> get photos; String get category;// 'Plumbing', 'Electrical', 'HVAC', 'General Repair', etc.
 String get date; String get timeSlot; String get accessInstructions; String? get vendorName; String? get vendorPhone; double? get bidAmount; String get assignedVendorName; String get assignedVendorId; double get cost;
/// Create a copy of WorkOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkOrderCopyWith<WorkOrder> get copyWith => _$WorkOrderCopyWithImpl<WorkOrder>(this as WorkOrder, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.accessInstructions, accessInstructions) || other.accessInstructions == accessInstructions)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.vendorPhone, vendorPhone) || other.vendorPhone == vendorPhone)&&(identical(other.bidAmount, bidAmount) || other.bidAmount == bidAmount)&&(identical(other.assignedVendorName, assignedVendorName) || other.assignedVendorName == assignedVendorName)&&(identical(other.assignedVendorId, assignedVendorId) || other.assignedVendorId == assignedVendorId)&&(identical(other.cost, cost) || other.cost == cost));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,propertyName,unitName,tenantName,priority,status,const DeepCollectionEquality().hash(photos),category,date,timeSlot,accessInstructions,vendorName,vendorPhone,bidAmount,assignedVendorName,assignedVendorId,cost]);

@override
String toString() {
  return 'WorkOrder(id: $id, title: $title, description: $description, propertyName: $propertyName, unitName: $unitName, tenantName: $tenantName, priority: $priority, status: $status, photos: $photos, category: $category, date: $date, timeSlot: $timeSlot, accessInstructions: $accessInstructions, vendorName: $vendorName, vendorPhone: $vendorPhone, bidAmount: $bidAmount, assignedVendorName: $assignedVendorName, assignedVendorId: $assignedVendorId, cost: $cost)';
}


}

/// @nodoc
abstract mixin class $WorkOrderCopyWith<$Res>  {
  factory $WorkOrderCopyWith(WorkOrder value, $Res Function(WorkOrder) _then) = _$WorkOrderCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String propertyName, String unitName, String tenantName, String priority, String status, List<String> photos, String category, String date, String timeSlot, String accessInstructions, String? vendorName, String? vendorPhone, double? bidAmount, String assignedVendorName, String assignedVendorId, double cost
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? propertyName = null,Object? unitName = null,Object? tenantName = null,Object? priority = null,Object? status = null,Object? photos = null,Object? category = null,Object? date = null,Object? timeSlot = null,Object? accessInstructions = null,Object? vendorName = freezed,Object? vendorPhone = freezed,Object? bidAmount = freezed,Object? assignedVendorName = null,Object? assignedVendorId = null,Object? cost = null,}) {
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
as double?,assignedVendorName: null == assignedVendorName ? _self.assignedVendorName : assignedVendorName // ignore: cast_nullable_to_non_nullable
as String,assignedVendorId: null == assignedVendorId ? _self.assignedVendorId : assignedVendorId // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  List<String> photos,  String category,  String date,  String timeSlot,  String accessInstructions,  String? vendorName,  String? vendorPhone,  double? bidAmount,  String assignedVendorName,  String assignedVendorId,  double cost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkOrder() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.photos,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.vendorName,_that.vendorPhone,_that.bidAmount,_that.assignedVendorName,_that.assignedVendorId,_that.cost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  List<String> photos,  String category,  String date,  String timeSlot,  String accessInstructions,  String? vendorName,  String? vendorPhone,  double? bidAmount,  String assignedVendorName,  String assignedVendorId,  double cost)  $default,) {final _that = this;
switch (_that) {
case _WorkOrder():
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.photos,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.vendorName,_that.vendorPhone,_that.bidAmount,_that.assignedVendorName,_that.assignedVendorId,_that.cost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String propertyName,  String unitName,  String tenantName,  String priority,  String status,  List<String> photos,  String category,  String date,  String timeSlot,  String accessInstructions,  String? vendorName,  String? vendorPhone,  double? bidAmount,  String assignedVendorName,  String assignedVendorId,  double cost)?  $default,) {final _that = this;
switch (_that) {
case _WorkOrder() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.propertyName,_that.unitName,_that.tenantName,_that.priority,_that.status,_that.photos,_that.category,_that.date,_that.timeSlot,_that.accessInstructions,_that.vendorName,_that.vendorPhone,_that.bidAmount,_that.assignedVendorName,_that.assignedVendorId,_that.cost);case _:
  return null;

}
}

}

/// @nodoc


class _WorkOrder implements WorkOrder {
  const _WorkOrder({required this.id, required this.title, required this.description, required this.propertyName, required this.unitName, required this.tenantName, required this.priority, required this.status, required final  List<String> photos, required this.category, required this.date, required this.timeSlot, required this.accessInstructions, this.vendorName, this.vendorPhone, this.bidAmount, this.assignedVendorName = '', this.assignedVendorId = '', this.cost = 0.0}): _photos = photos;
  

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
@override@JsonKey() final  String assignedVendorName;
@override@JsonKey() final  String assignedVendorId;
@override@JsonKey() final  double cost;

/// Create a copy of WorkOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkOrderCopyWith<_WorkOrder> get copyWith => __$WorkOrderCopyWithImpl<_WorkOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.accessInstructions, accessInstructions) || other.accessInstructions == accessInstructions)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.vendorPhone, vendorPhone) || other.vendorPhone == vendorPhone)&&(identical(other.bidAmount, bidAmount) || other.bidAmount == bidAmount)&&(identical(other.assignedVendorName, assignedVendorName) || other.assignedVendorName == assignedVendorName)&&(identical(other.assignedVendorId, assignedVendorId) || other.assignedVendorId == assignedVendorId)&&(identical(other.cost, cost) || other.cost == cost));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,propertyName,unitName,tenantName,priority,status,const DeepCollectionEquality().hash(_photos),category,date,timeSlot,accessInstructions,vendorName,vendorPhone,bidAmount,assignedVendorName,assignedVendorId,cost]);

@override
String toString() {
  return 'WorkOrder(id: $id, title: $title, description: $description, propertyName: $propertyName, unitName: $unitName, tenantName: $tenantName, priority: $priority, status: $status, photos: $photos, category: $category, date: $date, timeSlot: $timeSlot, accessInstructions: $accessInstructions, vendorName: $vendorName, vendorPhone: $vendorPhone, bidAmount: $bidAmount, assignedVendorName: $assignedVendorName, assignedVendorId: $assignedVendorId, cost: $cost)';
}


}

/// @nodoc
abstract mixin class _$WorkOrderCopyWith<$Res> implements $WorkOrderCopyWith<$Res> {
  factory _$WorkOrderCopyWith(_WorkOrder value, $Res Function(_WorkOrder) _then) = __$WorkOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String propertyName, String unitName, String tenantName, String priority, String status, List<String> photos, String category, String date, String timeSlot, String accessInstructions, String? vendorName, String? vendorPhone, double? bidAmount, String assignedVendorName, String assignedVendorId, double cost
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? propertyName = null,Object? unitName = null,Object? tenantName = null,Object? priority = null,Object? status = null,Object? photos = null,Object? category = null,Object? date = null,Object? timeSlot = null,Object? accessInstructions = null,Object? vendorName = freezed,Object? vendorPhone = freezed,Object? bidAmount = freezed,Object? assignedVendorName = null,Object? assignedVendorId = null,Object? cost = null,}) {
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
as double?,assignedVendorName: null == assignedVendorName ? _self.assignedVendorName : assignedVendorName // ignore: cast_nullable_to_non_nullable
as String,assignedVendorId: null == assignedVendorId ? _self.assignedVendorId : assignedVendorId // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,
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
mixin _$VendorProfile {

 String get id; String get displayName; String get email; double get avgRating;
/// Create a copy of VendorProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorProfileCopyWith<VendorProfile> get copyWith => _$VendorProfileCopyWithImpl<VendorProfile>(this as VendorProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,avgRating);

@override
String toString() {
  return 'VendorProfile(id: $id, displayName: $displayName, email: $email, avgRating: $avgRating)';
}


}

/// @nodoc
abstract mixin class $VendorProfileCopyWith<$Res>  {
  factory $VendorProfileCopyWith(VendorProfile value, $Res Function(VendorProfile) _then) = _$VendorProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String email, double avgRating
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? email = null,Object? avgRating = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String email,  double avgRating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.avgRating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String email,  double avgRating)  $default,) {final _that = this;
switch (_that) {
case _VendorProfile():
return $default(_that.id,_that.displayName,_that.email,_that.avgRating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String email,  double avgRating)?  $default,) {final _that = this;
switch (_that) {
case _VendorProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.avgRating);case _:
  return null;

}
}

}

/// @nodoc


class _VendorProfile implements VendorProfile {
  const _VendorProfile({required this.id, required this.displayName, required this.email, required this.avgRating});
  

@override final  String id;
@override final  String displayName;
@override final  String email;
@override final  double avgRating;

/// Create a copy of VendorProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorProfileCopyWith<_VendorProfile> get copyWith => __$VendorProfileCopyWithImpl<_VendorProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.avgRating, avgRating) || other.avgRating == avgRating));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,avgRating);

@override
String toString() {
  return 'VendorProfile(id: $id, displayName: $displayName, email: $email, avgRating: $avgRating)';
}


}

/// @nodoc
abstract mixin class _$VendorProfileCopyWith<$Res> implements $VendorProfileCopyWith<$Res> {
  factory _$VendorProfileCopyWith(_VendorProfile value, $Res Function(_VendorProfile) _then) = __$VendorProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String email, double avgRating
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? email = null,Object? avgRating = null,}) {
  return _then(_VendorProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avgRating: null == avgRating ? _self.avgRating : avgRating // ignore: cast_nullable_to_non_nullable
as double,
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
mixin _$Lease {

 String get id; String get unitName; String get tenantName; String get propertyName; double get rentAmount; String get startDate; String get endDate; String get status;// 'active', 'expired', 'pending'
 int get daysLeft; String get tenantId;
/// Create a copy of Lease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaseCopyWith<Lease> get copyWith => _$LeaseCopyWithImpl<Lease>(this as Lease, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lease&&(identical(other.id, id) || other.id == id)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.rentAmount, rentAmount) || other.rentAmount == rentAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId));
}


@override
int get hashCode => Object.hash(runtimeType,id,unitName,tenantName,propertyName,rentAmount,startDate,endDate,status,daysLeft,tenantId);

@override
String toString() {
  return 'Lease(id: $id, unitName: $unitName, tenantName: $tenantName, propertyName: $propertyName, rentAmount: $rentAmount, startDate: $startDate, endDate: $endDate, status: $status, daysLeft: $daysLeft, tenantId: $tenantId)';
}


}

/// @nodoc
abstract mixin class $LeaseCopyWith<$Res>  {
  factory $LeaseCopyWith(Lease value, $Res Function(Lease) _then) = _$LeaseCopyWithImpl;
@useResult
$Res call({
 String id, String unitName, String tenantName, String propertyName, double rentAmount, String startDate, String endDate, String status, int daysLeft, String tenantId
});




}
/// @nodoc
class _$LeaseCopyWithImpl<$Res>
    implements $LeaseCopyWith<$Res> {
  _$LeaseCopyWithImpl(this._self, this._then);

  final Lease _self;
  final $Res Function(Lease) _then;

/// Create a copy of Lease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unitName = null,Object? tenantName = null,Object? propertyName = null,Object? rentAmount = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? daysLeft = null,Object? tenantId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,rentAmount: null == rentAmount ? _self.rentAmount : rentAmount // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Lease].
extension LeasePatterns on Lease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lease value)  $default,){
final _that = this;
switch (_that) {
case _Lease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lease value)?  $default,){
final _that = this;
switch (_that) {
case _Lease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String unitName,  String tenantName,  String propertyName,  double rentAmount,  String startDate,  String endDate,  String status,  int daysLeft,  String tenantId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lease() when $default != null:
return $default(_that.id,_that.unitName,_that.tenantName,_that.propertyName,_that.rentAmount,_that.startDate,_that.endDate,_that.status,_that.daysLeft,_that.tenantId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String unitName,  String tenantName,  String propertyName,  double rentAmount,  String startDate,  String endDate,  String status,  int daysLeft,  String tenantId)  $default,) {final _that = this;
switch (_that) {
case _Lease():
return $default(_that.id,_that.unitName,_that.tenantName,_that.propertyName,_that.rentAmount,_that.startDate,_that.endDate,_that.status,_that.daysLeft,_that.tenantId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String unitName,  String tenantName,  String propertyName,  double rentAmount,  String startDate,  String endDate,  String status,  int daysLeft,  String tenantId)?  $default,) {final _that = this;
switch (_that) {
case _Lease() when $default != null:
return $default(_that.id,_that.unitName,_that.tenantName,_that.propertyName,_that.rentAmount,_that.startDate,_that.endDate,_that.status,_that.daysLeft,_that.tenantId);case _:
  return null;

}
}

}

/// @nodoc


class _Lease implements Lease {
  const _Lease({required this.id, required this.unitName, required this.tenantName, required this.propertyName, required this.rentAmount, required this.startDate, required this.endDate, required this.status, this.daysLeft = 0, this.tenantId = ''});
  

@override final  String id;
@override final  String unitName;
@override final  String tenantName;
@override final  String propertyName;
@override final  double rentAmount;
@override final  String startDate;
@override final  String endDate;
@override final  String status;
// 'active', 'expired', 'pending'
@override@JsonKey() final  int daysLeft;
@override@JsonKey() final  String tenantId;

/// Create a copy of Lease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaseCopyWith<_Lease> get copyWith => __$LeaseCopyWithImpl<_Lease>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lease&&(identical(other.id, id) || other.id == id)&&(identical(other.unitName, unitName) || other.unitName == unitName)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.propertyName, propertyName) || other.propertyName == propertyName)&&(identical(other.rentAmount, rentAmount) || other.rentAmount == rentAmount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId));
}


@override
int get hashCode => Object.hash(runtimeType,id,unitName,tenantName,propertyName,rentAmount,startDate,endDate,status,daysLeft,tenantId);

@override
String toString() {
  return 'Lease(id: $id, unitName: $unitName, tenantName: $tenantName, propertyName: $propertyName, rentAmount: $rentAmount, startDate: $startDate, endDate: $endDate, status: $status, daysLeft: $daysLeft, tenantId: $tenantId)';
}


}

/// @nodoc
abstract mixin class _$LeaseCopyWith<$Res> implements $LeaseCopyWith<$Res> {
  factory _$LeaseCopyWith(_Lease value, $Res Function(_Lease) _then) = __$LeaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String unitName, String tenantName, String propertyName, double rentAmount, String startDate, String endDate, String status, int daysLeft, String tenantId
});




}
/// @nodoc
class __$LeaseCopyWithImpl<$Res>
    implements _$LeaseCopyWith<$Res> {
  __$LeaseCopyWithImpl(this._self, this._then);

  final _Lease _self;
  final $Res Function(_Lease) _then;

/// Create a copy of Lease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unitName = null,Object? tenantName = null,Object? propertyName = null,Object? rentAmount = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? daysLeft = null,Object? tenantId = null,}) {
  return _then(_Lease(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitName: null == unitName ? _self.unitName : unitName // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,propertyName: null == propertyName ? _self.propertyName : propertyName // ignore: cast_nullable_to_non_nullable
as String,rentAmount: null == rentAmount ? _self.rentAmount : rentAmount // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$UrgentAlert {

 String get id; String get title; String get description; String get type;// 'maintenance' | 'lease'
 String? get priority;
/// Create a copy of UrgentAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UrgentAlertCopyWith<UrgentAlert> get copyWith => _$UrgentAlertCopyWithImpl<UrgentAlert>(this as UrgentAlert, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UrgentAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.priority, priority) || other.priority == priority));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,type,priority);

@override
String toString() {
  return 'UrgentAlert(id: $id, title: $title, description: $description, type: $type, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $UrgentAlertCopyWith<$Res>  {
  factory $UrgentAlertCopyWith(UrgentAlert value, $Res Function(UrgentAlert) _then) = _$UrgentAlertCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String type, String? priority
});




}
/// @nodoc
class _$UrgentAlertCopyWithImpl<$Res>
    implements $UrgentAlertCopyWith<$Res> {
  _$UrgentAlertCopyWithImpl(this._self, this._then);

  final UrgentAlert _self;
  final $Res Function(UrgentAlert) _then;

/// Create a copy of UrgentAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? type = null,Object? priority = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UrgentAlert].
extension UrgentAlertPatterns on UrgentAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UrgentAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UrgentAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UrgentAlert value)  $default,){
final _that = this;
switch (_that) {
case _UrgentAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UrgentAlert value)?  $default,){
final _that = this;
switch (_that) {
case _UrgentAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String type,  String? priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UrgentAlert() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.type,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String type,  String? priority)  $default,) {final _that = this;
switch (_that) {
case _UrgentAlert():
return $default(_that.id,_that.title,_that.description,_that.type,_that.priority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String type,  String? priority)?  $default,) {final _that = this;
switch (_that) {
case _UrgentAlert() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.type,_that.priority);case _:
  return null;

}
}

}

/// @nodoc


class _UrgentAlert implements UrgentAlert {
  const _UrgentAlert({required this.id, required this.title, required this.description, required this.type, this.priority});
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String type;
// 'maintenance' | 'lease'
@override final  String? priority;

/// Create a copy of UrgentAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UrgentAlertCopyWith<_UrgentAlert> get copyWith => __$UrgentAlertCopyWithImpl<_UrgentAlert>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UrgentAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.priority, priority) || other.priority == priority));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,type,priority);

@override
String toString() {
  return 'UrgentAlert(id: $id, title: $title, description: $description, type: $type, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$UrgentAlertCopyWith<$Res> implements $UrgentAlertCopyWith<$Res> {
  factory _$UrgentAlertCopyWith(_UrgentAlert value, $Res Function(_UrgentAlert) _then) = __$UrgentAlertCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String type, String? priority
});




}
/// @nodoc
class __$UrgentAlertCopyWithImpl<$Res>
    implements _$UrgentAlertCopyWith<$Res> {
  __$UrgentAlertCopyWithImpl(this._self, this._then);

  final _UrgentAlert _self;
  final $Res Function(_UrgentAlert) _then;

/// Create a copy of UrgentAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? type = null,Object? priority = freezed,}) {
  return _then(_UrgentAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$NotificationItem {

 String get id; String get title; String get body; String get type; bool get isRead; String get createdAt;
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationItemCopyWith<NotificationItem> get copyWith => _$NotificationItemCopyWithImpl<NotificationItem>(this as NotificationItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,isRead,createdAt);

@override
String toString() {
  return 'NotificationItem(id: $id, title: $title, body: $body, type: $type, isRead: $isRead, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $NotificationItemCopyWith<$Res>  {
  factory $NotificationItemCopyWith(NotificationItem value, $Res Function(NotificationItem) _then) = _$NotificationItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, String type, bool isRead, String createdAt
});




}
/// @nodoc
class _$NotificationItemCopyWithImpl<$Res>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._self, this._then);

  final NotificationItem _self;
  final $Res Function(NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? isRead = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationItem].
extension NotificationItemPatterns on NotificationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String type,  bool isRead,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.isRead,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String type,  bool isRead,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that.id,_that.title,_that.body,_that.type,_that.isRead,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  String type,  bool isRead,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.isRead,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationItem implements NotificationItem {
  const _NotificationItem({required this.id, required this.title, required this.body, required this.type, required this.isRead, required this.createdAt});
  

@override final  String id;
@override final  String title;
@override final  String body;
@override final  String type;
@override final  bool isRead;
@override final  String createdAt;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationItemCopyWith<_NotificationItem> get copyWith => __$NotificationItemCopyWithImpl<_NotificationItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,isRead,createdAt);

@override
String toString() {
  return 'NotificationItem(id: $id, title: $title, body: $body, type: $type, isRead: $isRead, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationItemCopyWith<$Res> implements $NotificationItemCopyWith<$Res> {
  factory _$NotificationItemCopyWith(_NotificationItem value, $Res Function(_NotificationItem) _then) = __$NotificationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, String type, bool isRead, String createdAt
});




}
/// @nodoc
class __$NotificationItemCopyWithImpl<$Res>
    implements _$NotificationItemCopyWith<$Res> {
  __$NotificationItemCopyWithImpl(this._self, this._then);

  final _NotificationItem _self;
  final $Res Function(_NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? isRead = null,Object? createdAt = null,}) {
  return _then(_NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LandlordState {

// ── Profile ────────────────────────────────────────────────
 String get userName; String get userAvatarUrl;// ── Core Lists ─────────────────────────────────────────────
 List<Property> get properties; List<Unit> get units; List<Tenant> get tenants; List<WorkOrder> get workOrders; List<Bid> get bids; List<VendorProfile> get vendors; List<ChatMessage> get chatMessages; List<Lease> get leases;// ── Finance ────────────────────────────────────────────────
 double get totalCollected; double get totalOutstanding; double get occupancyRate; double get rentCollectionPercent;// 0.0 to 1.0
// ── Maintenance Summary ────────────────────────────────────
 int get maintenanceEmergency; int get maintenanceInProgress; int get maintenanceCompleted;// ── Lease Summary ─────────────────────────────────────────
 int get activeLeaseCount; int get expiringLeaseCount;// ── Urgent Alerts (home dashboard) ────────────────────────
 List<UrgentAlert> get urgentAlerts;// ── Notifications ─────────────────────────────────────────
 List<NotificationItem> get notifications; int get unreadNotifications;// ── Loading ────────────────────────────────────────────────
 bool get isLoading; bool get isTenantsLoading; bool get isLeasesLoading; bool get isUnitsLoading; bool get isBidsLoading;// ── Error ──────────────────────────────────────────────────
 String get errorMessage;
/// Create a copy of LandlordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LandlordStateCopyWith<LandlordState> get copyWith => _$LandlordStateCopyWithImpl<LandlordState>(this as LandlordState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LandlordState&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&const DeepCollectionEquality().equals(other.properties, properties)&&const DeepCollectionEquality().equals(other.units, units)&&const DeepCollectionEquality().equals(other.tenants, tenants)&&const DeepCollectionEquality().equals(other.workOrders, workOrders)&&const DeepCollectionEquality().equals(other.bids, bids)&&const DeepCollectionEquality().equals(other.vendors, vendors)&&const DeepCollectionEquality().equals(other.chatMessages, chatMessages)&&const DeepCollectionEquality().equals(other.leases, leases)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.totalOutstanding, totalOutstanding) || other.totalOutstanding == totalOutstanding)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.rentCollectionPercent, rentCollectionPercent) || other.rentCollectionPercent == rentCollectionPercent)&&(identical(other.maintenanceEmergency, maintenanceEmergency) || other.maintenanceEmergency == maintenanceEmergency)&&(identical(other.maintenanceInProgress, maintenanceInProgress) || other.maintenanceInProgress == maintenanceInProgress)&&(identical(other.maintenanceCompleted, maintenanceCompleted) || other.maintenanceCompleted == maintenanceCompleted)&&(identical(other.activeLeaseCount, activeLeaseCount) || other.activeLeaseCount == activeLeaseCount)&&(identical(other.expiringLeaseCount, expiringLeaseCount) || other.expiringLeaseCount == expiringLeaseCount)&&const DeepCollectionEquality().equals(other.urgentAlerts, urgentAlerts)&&const DeepCollectionEquality().equals(other.notifications, notifications)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isTenantsLoading, isTenantsLoading) || other.isTenantsLoading == isTenantsLoading)&&(identical(other.isLeasesLoading, isLeasesLoading) || other.isLeasesLoading == isLeasesLoading)&&(identical(other.isUnitsLoading, isUnitsLoading) || other.isUnitsLoading == isUnitsLoading)&&(identical(other.isBidsLoading, isBidsLoading) || other.isBidsLoading == isBidsLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,userName,userAvatarUrl,const DeepCollectionEquality().hash(properties),const DeepCollectionEquality().hash(units),const DeepCollectionEquality().hash(tenants),const DeepCollectionEquality().hash(workOrders),const DeepCollectionEquality().hash(bids),const DeepCollectionEquality().hash(vendors),const DeepCollectionEquality().hash(chatMessages),const DeepCollectionEquality().hash(leases),totalCollected,totalOutstanding,occupancyRate,rentCollectionPercent,maintenanceEmergency,maintenanceInProgress,maintenanceCompleted,activeLeaseCount,expiringLeaseCount,const DeepCollectionEquality().hash(urgentAlerts),const DeepCollectionEquality().hash(notifications),unreadNotifications,isLoading,isTenantsLoading,isLeasesLoading,isUnitsLoading,isBidsLoading,errorMessage]);

@override
String toString() {
  return 'LandlordState(userName: $userName, userAvatarUrl: $userAvatarUrl, properties: $properties, units: $units, tenants: $tenants, workOrders: $workOrders, bids: $bids, vendors: $vendors, chatMessages: $chatMessages, leases: $leases, totalCollected: $totalCollected, totalOutstanding: $totalOutstanding, occupancyRate: $occupancyRate, rentCollectionPercent: $rentCollectionPercent, maintenanceEmergency: $maintenanceEmergency, maintenanceInProgress: $maintenanceInProgress, maintenanceCompleted: $maintenanceCompleted, activeLeaseCount: $activeLeaseCount, expiringLeaseCount: $expiringLeaseCount, urgentAlerts: $urgentAlerts, notifications: $notifications, unreadNotifications: $unreadNotifications, isLoading: $isLoading, isTenantsLoading: $isTenantsLoading, isLeasesLoading: $isLeasesLoading, isUnitsLoading: $isUnitsLoading, isBidsLoading: $isBidsLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $LandlordStateCopyWith<$Res>  {
  factory $LandlordStateCopyWith(LandlordState value, $Res Function(LandlordState) _then) = _$LandlordStateCopyWithImpl;
@useResult
$Res call({
 String userName, String userAvatarUrl, List<Property> properties, List<Unit> units, List<Tenant> tenants, List<WorkOrder> workOrders, List<Bid> bids, List<VendorProfile> vendors, List<ChatMessage> chatMessages, List<Lease> leases, double totalCollected, double totalOutstanding, double occupancyRate, double rentCollectionPercent, int maintenanceEmergency, int maintenanceInProgress, int maintenanceCompleted, int activeLeaseCount, int expiringLeaseCount, List<UrgentAlert> urgentAlerts, List<NotificationItem> notifications, int unreadNotifications, bool isLoading, bool isTenantsLoading, bool isLeasesLoading, bool isUnitsLoading, bool isBidsLoading, String errorMessage
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
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? userAvatarUrl = null,Object? properties = null,Object? units = null,Object? tenants = null,Object? workOrders = null,Object? bids = null,Object? vendors = null,Object? chatMessages = null,Object? leases = null,Object? totalCollected = null,Object? totalOutstanding = null,Object? occupancyRate = null,Object? rentCollectionPercent = null,Object? maintenanceEmergency = null,Object? maintenanceInProgress = null,Object? maintenanceCompleted = null,Object? activeLeaseCount = null,Object? expiringLeaseCount = null,Object? urgentAlerts = null,Object? notifications = null,Object? unreadNotifications = null,Object? isLoading = null,Object? isTenantsLoading = null,Object? isLeasesLoading = null,Object? isUnitsLoading = null,Object? isBidsLoading = null,Object? errorMessage = null,}) {
  return _then(_self.copyWith(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: null == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,properties: null == properties ? _self.properties : properties // ignore: cast_nullable_to_non_nullable
as List<Property>,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as List<Unit>,tenants: null == tenants ? _self.tenants : tenants // ignore: cast_nullable_to_non_nullable
as List<Tenant>,workOrders: null == workOrders ? _self.workOrders : workOrders // ignore: cast_nullable_to_non_nullable
as List<WorkOrder>,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,vendors: null == vendors ? _self.vendors : vendors // ignore: cast_nullable_to_non_nullable
as List<VendorProfile>,chatMessages: null == chatMessages ? _self.chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,leases: null == leases ? _self.leases : leases // ignore: cast_nullable_to_non_nullable
as List<Lease>,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,totalOutstanding: null == totalOutstanding ? _self.totalOutstanding : totalOutstanding // ignore: cast_nullable_to_non_nullable
as double,occupancyRate: null == occupancyRate ? _self.occupancyRate : occupancyRate // ignore: cast_nullable_to_non_nullable
as double,rentCollectionPercent: null == rentCollectionPercent ? _self.rentCollectionPercent : rentCollectionPercent // ignore: cast_nullable_to_non_nullable
as double,maintenanceEmergency: null == maintenanceEmergency ? _self.maintenanceEmergency : maintenanceEmergency // ignore: cast_nullable_to_non_nullable
as int,maintenanceInProgress: null == maintenanceInProgress ? _self.maintenanceInProgress : maintenanceInProgress // ignore: cast_nullable_to_non_nullable
as int,maintenanceCompleted: null == maintenanceCompleted ? _self.maintenanceCompleted : maintenanceCompleted // ignore: cast_nullable_to_non_nullable
as int,activeLeaseCount: null == activeLeaseCount ? _self.activeLeaseCount : activeLeaseCount // ignore: cast_nullable_to_non_nullable
as int,expiringLeaseCount: null == expiringLeaseCount ? _self.expiringLeaseCount : expiringLeaseCount // ignore: cast_nullable_to_non_nullable
as int,urgentAlerts: null == urgentAlerts ? _self.urgentAlerts : urgentAlerts // ignore: cast_nullable_to_non_nullable
as List<UrgentAlert>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationItem>,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isTenantsLoading: null == isTenantsLoading ? _self.isTenantsLoading : isTenantsLoading // ignore: cast_nullable_to_non_nullable
as bool,isLeasesLoading: null == isLeasesLoading ? _self.isLeasesLoading : isLeasesLoading // ignore: cast_nullable_to_non_nullable
as bool,isUnitsLoading: null == isUnitsLoading ? _self.isUnitsLoading : isUnitsLoading // ignore: cast_nullable_to_non_nullable
as bool,isBidsLoading: null == isBidsLoading ? _self.isBidsLoading : isBidsLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  String userAvatarUrl,  List<Property> properties,  List<Unit> units,  List<Tenant> tenants,  List<WorkOrder> workOrders,  List<Bid> bids,  List<VendorProfile> vendors,  List<ChatMessage> chatMessages,  List<Lease> leases,  double totalCollected,  double totalOutstanding,  double occupancyRate,  double rentCollectionPercent,  int maintenanceEmergency,  int maintenanceInProgress,  int maintenanceCompleted,  int activeLeaseCount,  int expiringLeaseCount,  List<UrgentAlert> urgentAlerts,  List<NotificationItem> notifications,  int unreadNotifications,  bool isLoading,  bool isTenantsLoading,  bool isLeasesLoading,  bool isUnitsLoading,  bool isBidsLoading,  String errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LandlordState() when $default != null:
return $default(_that.userName,_that.userAvatarUrl,_that.properties,_that.units,_that.tenants,_that.workOrders,_that.bids,_that.vendors,_that.chatMessages,_that.leases,_that.totalCollected,_that.totalOutstanding,_that.occupancyRate,_that.rentCollectionPercent,_that.maintenanceEmergency,_that.maintenanceInProgress,_that.maintenanceCompleted,_that.activeLeaseCount,_that.expiringLeaseCount,_that.urgentAlerts,_that.notifications,_that.unreadNotifications,_that.isLoading,_that.isTenantsLoading,_that.isLeasesLoading,_that.isUnitsLoading,_that.isBidsLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  String userAvatarUrl,  List<Property> properties,  List<Unit> units,  List<Tenant> tenants,  List<WorkOrder> workOrders,  List<Bid> bids,  List<VendorProfile> vendors,  List<ChatMessage> chatMessages,  List<Lease> leases,  double totalCollected,  double totalOutstanding,  double occupancyRate,  double rentCollectionPercent,  int maintenanceEmergency,  int maintenanceInProgress,  int maintenanceCompleted,  int activeLeaseCount,  int expiringLeaseCount,  List<UrgentAlert> urgentAlerts,  List<NotificationItem> notifications,  int unreadNotifications,  bool isLoading,  bool isTenantsLoading,  bool isLeasesLoading,  bool isUnitsLoading,  bool isBidsLoading,  String errorMessage)  $default,) {final _that = this;
switch (_that) {
case _LandlordState():
return $default(_that.userName,_that.userAvatarUrl,_that.properties,_that.units,_that.tenants,_that.workOrders,_that.bids,_that.vendors,_that.chatMessages,_that.leases,_that.totalCollected,_that.totalOutstanding,_that.occupancyRate,_that.rentCollectionPercent,_that.maintenanceEmergency,_that.maintenanceInProgress,_that.maintenanceCompleted,_that.activeLeaseCount,_that.expiringLeaseCount,_that.urgentAlerts,_that.notifications,_that.unreadNotifications,_that.isLoading,_that.isTenantsLoading,_that.isLeasesLoading,_that.isUnitsLoading,_that.isBidsLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  String userAvatarUrl,  List<Property> properties,  List<Unit> units,  List<Tenant> tenants,  List<WorkOrder> workOrders,  List<Bid> bids,  List<VendorProfile> vendors,  List<ChatMessage> chatMessages,  List<Lease> leases,  double totalCollected,  double totalOutstanding,  double occupancyRate,  double rentCollectionPercent,  int maintenanceEmergency,  int maintenanceInProgress,  int maintenanceCompleted,  int activeLeaseCount,  int expiringLeaseCount,  List<UrgentAlert> urgentAlerts,  List<NotificationItem> notifications,  int unreadNotifications,  bool isLoading,  bool isTenantsLoading,  bool isLeasesLoading,  bool isUnitsLoading,  bool isBidsLoading,  String errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _LandlordState() when $default != null:
return $default(_that.userName,_that.userAvatarUrl,_that.properties,_that.units,_that.tenants,_that.workOrders,_that.bids,_that.vendors,_that.chatMessages,_that.leases,_that.totalCollected,_that.totalOutstanding,_that.occupancyRate,_that.rentCollectionPercent,_that.maintenanceEmergency,_that.maintenanceInProgress,_that.maintenanceCompleted,_that.activeLeaseCount,_that.expiringLeaseCount,_that.urgentAlerts,_that.notifications,_that.unreadNotifications,_that.isLoading,_that.isTenantsLoading,_that.isLeasesLoading,_that.isUnitsLoading,_that.isBidsLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LandlordState implements LandlordState {
  const _LandlordState({this.userName = '', this.userAvatarUrl = '', final  List<Property> properties = const [], final  List<Unit> units = const [], final  List<Tenant> tenants = const [], final  List<WorkOrder> workOrders = const [], final  List<Bid> bids = const [], final  List<VendorProfile> vendors = const [], final  List<ChatMessage> chatMessages = const [], final  List<Lease> leases = const [], this.totalCollected = 0.0, this.totalOutstanding = 0.0, this.occupancyRate = 0.0, this.rentCollectionPercent = 0.0, this.maintenanceEmergency = 0, this.maintenanceInProgress = 0, this.maintenanceCompleted = 0, this.activeLeaseCount = 0, this.expiringLeaseCount = 0, final  List<UrgentAlert> urgentAlerts = const [], final  List<NotificationItem> notifications = const [], this.unreadNotifications = 0, this.isLoading = false, this.isTenantsLoading = false, this.isLeasesLoading = false, this.isUnitsLoading = false, this.isBidsLoading = false, this.errorMessage = ''}): _properties = properties,_units = units,_tenants = tenants,_workOrders = workOrders,_bids = bids,_vendors = vendors,_chatMessages = chatMessages,_leases = leases,_urgentAlerts = urgentAlerts,_notifications = notifications;
  

// ── Profile ────────────────────────────────────────────────
@override@JsonKey() final  String userName;
@override@JsonKey() final  String userAvatarUrl;
// ── Core Lists ─────────────────────────────────────────────
 final  List<Property> _properties;
// ── Core Lists ─────────────────────────────────────────────
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

 final  List<VendorProfile> _vendors;
@override@JsonKey() List<VendorProfile> get vendors {
  if (_vendors is EqualUnmodifiableListView) return _vendors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vendors);
}

 final  List<ChatMessage> _chatMessages;
@override@JsonKey() List<ChatMessage> get chatMessages {
  if (_chatMessages is EqualUnmodifiableListView) return _chatMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chatMessages);
}

 final  List<Lease> _leases;
@override@JsonKey() List<Lease> get leases {
  if (_leases is EqualUnmodifiableListView) return _leases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_leases);
}

// ── Finance ────────────────────────────────────────────────
@override@JsonKey() final  double totalCollected;
@override@JsonKey() final  double totalOutstanding;
@override@JsonKey() final  double occupancyRate;
@override@JsonKey() final  double rentCollectionPercent;
// 0.0 to 1.0
// ── Maintenance Summary ────────────────────────────────────
@override@JsonKey() final  int maintenanceEmergency;
@override@JsonKey() final  int maintenanceInProgress;
@override@JsonKey() final  int maintenanceCompleted;
// ── Lease Summary ─────────────────────────────────────────
@override@JsonKey() final  int activeLeaseCount;
@override@JsonKey() final  int expiringLeaseCount;
// ── Urgent Alerts (home dashboard) ────────────────────────
 final  List<UrgentAlert> _urgentAlerts;
// ── Urgent Alerts (home dashboard) ────────────────────────
@override@JsonKey() List<UrgentAlert> get urgentAlerts {
  if (_urgentAlerts is EqualUnmodifiableListView) return _urgentAlerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_urgentAlerts);
}

// ── Notifications ─────────────────────────────────────────
 final  List<NotificationItem> _notifications;
// ── Notifications ─────────────────────────────────────────
@override@JsonKey() List<NotificationItem> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

@override@JsonKey() final  int unreadNotifications;
// ── Loading ────────────────────────────────────────────────
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isTenantsLoading;
@override@JsonKey() final  bool isLeasesLoading;
@override@JsonKey() final  bool isUnitsLoading;
@override@JsonKey() final  bool isBidsLoading;
// ── Error ──────────────────────────────────────────────────
@override@JsonKey() final  String errorMessage;

/// Create a copy of LandlordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LandlordStateCopyWith<_LandlordState> get copyWith => __$LandlordStateCopyWithImpl<_LandlordState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LandlordState&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&const DeepCollectionEquality().equals(other._properties, _properties)&&const DeepCollectionEquality().equals(other._units, _units)&&const DeepCollectionEquality().equals(other._tenants, _tenants)&&const DeepCollectionEquality().equals(other._workOrders, _workOrders)&&const DeepCollectionEquality().equals(other._bids, _bids)&&const DeepCollectionEquality().equals(other._vendors, _vendors)&&const DeepCollectionEquality().equals(other._chatMessages, _chatMessages)&&const DeepCollectionEquality().equals(other._leases, _leases)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.totalOutstanding, totalOutstanding) || other.totalOutstanding == totalOutstanding)&&(identical(other.occupancyRate, occupancyRate) || other.occupancyRate == occupancyRate)&&(identical(other.rentCollectionPercent, rentCollectionPercent) || other.rentCollectionPercent == rentCollectionPercent)&&(identical(other.maintenanceEmergency, maintenanceEmergency) || other.maintenanceEmergency == maintenanceEmergency)&&(identical(other.maintenanceInProgress, maintenanceInProgress) || other.maintenanceInProgress == maintenanceInProgress)&&(identical(other.maintenanceCompleted, maintenanceCompleted) || other.maintenanceCompleted == maintenanceCompleted)&&(identical(other.activeLeaseCount, activeLeaseCount) || other.activeLeaseCount == activeLeaseCount)&&(identical(other.expiringLeaseCount, expiringLeaseCount) || other.expiringLeaseCount == expiringLeaseCount)&&const DeepCollectionEquality().equals(other._urgentAlerts, _urgentAlerts)&&const DeepCollectionEquality().equals(other._notifications, _notifications)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isTenantsLoading, isTenantsLoading) || other.isTenantsLoading == isTenantsLoading)&&(identical(other.isLeasesLoading, isLeasesLoading) || other.isLeasesLoading == isLeasesLoading)&&(identical(other.isUnitsLoading, isUnitsLoading) || other.isUnitsLoading == isUnitsLoading)&&(identical(other.isBidsLoading, isBidsLoading) || other.isBidsLoading == isBidsLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,userName,userAvatarUrl,const DeepCollectionEquality().hash(_properties),const DeepCollectionEquality().hash(_units),const DeepCollectionEquality().hash(_tenants),const DeepCollectionEquality().hash(_workOrders),const DeepCollectionEquality().hash(_bids),const DeepCollectionEquality().hash(_vendors),const DeepCollectionEquality().hash(_chatMessages),const DeepCollectionEquality().hash(_leases),totalCollected,totalOutstanding,occupancyRate,rentCollectionPercent,maintenanceEmergency,maintenanceInProgress,maintenanceCompleted,activeLeaseCount,expiringLeaseCount,const DeepCollectionEquality().hash(_urgentAlerts),const DeepCollectionEquality().hash(_notifications),unreadNotifications,isLoading,isTenantsLoading,isLeasesLoading,isUnitsLoading,isBidsLoading,errorMessage]);

@override
String toString() {
  return 'LandlordState(userName: $userName, userAvatarUrl: $userAvatarUrl, properties: $properties, units: $units, tenants: $tenants, workOrders: $workOrders, bids: $bids, vendors: $vendors, chatMessages: $chatMessages, leases: $leases, totalCollected: $totalCollected, totalOutstanding: $totalOutstanding, occupancyRate: $occupancyRate, rentCollectionPercent: $rentCollectionPercent, maintenanceEmergency: $maintenanceEmergency, maintenanceInProgress: $maintenanceInProgress, maintenanceCompleted: $maintenanceCompleted, activeLeaseCount: $activeLeaseCount, expiringLeaseCount: $expiringLeaseCount, urgentAlerts: $urgentAlerts, notifications: $notifications, unreadNotifications: $unreadNotifications, isLoading: $isLoading, isTenantsLoading: $isTenantsLoading, isLeasesLoading: $isLeasesLoading, isUnitsLoading: $isUnitsLoading, isBidsLoading: $isBidsLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$LandlordStateCopyWith<$Res> implements $LandlordStateCopyWith<$Res> {
  factory _$LandlordStateCopyWith(_LandlordState value, $Res Function(_LandlordState) _then) = __$LandlordStateCopyWithImpl;
@override @useResult
$Res call({
 String userName, String userAvatarUrl, List<Property> properties, List<Unit> units, List<Tenant> tenants, List<WorkOrder> workOrders, List<Bid> bids, List<VendorProfile> vendors, List<ChatMessage> chatMessages, List<Lease> leases, double totalCollected, double totalOutstanding, double occupancyRate, double rentCollectionPercent, int maintenanceEmergency, int maintenanceInProgress, int maintenanceCompleted, int activeLeaseCount, int expiringLeaseCount, List<UrgentAlert> urgentAlerts, List<NotificationItem> notifications, int unreadNotifications, bool isLoading, bool isTenantsLoading, bool isLeasesLoading, bool isUnitsLoading, bool isBidsLoading, String errorMessage
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
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? userAvatarUrl = null,Object? properties = null,Object? units = null,Object? tenants = null,Object? workOrders = null,Object? bids = null,Object? vendors = null,Object? chatMessages = null,Object? leases = null,Object? totalCollected = null,Object? totalOutstanding = null,Object? occupancyRate = null,Object? rentCollectionPercent = null,Object? maintenanceEmergency = null,Object? maintenanceInProgress = null,Object? maintenanceCompleted = null,Object? activeLeaseCount = null,Object? expiringLeaseCount = null,Object? urgentAlerts = null,Object? notifications = null,Object? unreadNotifications = null,Object? isLoading = null,Object? isTenantsLoading = null,Object? isLeasesLoading = null,Object? isUnitsLoading = null,Object? isBidsLoading = null,Object? errorMessage = null,}) {
  return _then(_LandlordState(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: null == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,properties: null == properties ? _self._properties : properties // ignore: cast_nullable_to_non_nullable
as List<Property>,units: null == units ? _self._units : units // ignore: cast_nullable_to_non_nullable
as List<Unit>,tenants: null == tenants ? _self._tenants : tenants // ignore: cast_nullable_to_non_nullable
as List<Tenant>,workOrders: null == workOrders ? _self._workOrders : workOrders // ignore: cast_nullable_to_non_nullable
as List<WorkOrder>,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,vendors: null == vendors ? _self._vendors : vendors // ignore: cast_nullable_to_non_nullable
as List<VendorProfile>,chatMessages: null == chatMessages ? _self._chatMessages : chatMessages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,leases: null == leases ? _self._leases : leases // ignore: cast_nullable_to_non_nullable
as List<Lease>,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,totalOutstanding: null == totalOutstanding ? _self.totalOutstanding : totalOutstanding // ignore: cast_nullable_to_non_nullable
as double,occupancyRate: null == occupancyRate ? _self.occupancyRate : occupancyRate // ignore: cast_nullable_to_non_nullable
as double,rentCollectionPercent: null == rentCollectionPercent ? _self.rentCollectionPercent : rentCollectionPercent // ignore: cast_nullable_to_non_nullable
as double,maintenanceEmergency: null == maintenanceEmergency ? _self.maintenanceEmergency : maintenanceEmergency // ignore: cast_nullable_to_non_nullable
as int,maintenanceInProgress: null == maintenanceInProgress ? _self.maintenanceInProgress : maintenanceInProgress // ignore: cast_nullable_to_non_nullable
as int,maintenanceCompleted: null == maintenanceCompleted ? _self.maintenanceCompleted : maintenanceCompleted // ignore: cast_nullable_to_non_nullable
as int,activeLeaseCount: null == activeLeaseCount ? _self.activeLeaseCount : activeLeaseCount // ignore: cast_nullable_to_non_nullable
as int,expiringLeaseCount: null == expiringLeaseCount ? _self.expiringLeaseCount : expiringLeaseCount // ignore: cast_nullable_to_non_nullable
as int,urgentAlerts: null == urgentAlerts ? _self._urgentAlerts : urgentAlerts // ignore: cast_nullable_to_non_nullable
as List<UrgentAlert>,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationItem>,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isTenantsLoading: null == isTenantsLoading ? _self.isTenantsLoading : isTenantsLoading // ignore: cast_nullable_to_non_nullable
as bool,isLeasesLoading: null == isLeasesLoading ? _self.isLeasesLoading : isLeasesLoading // ignore: cast_nullable_to_non_nullable
as bool,isUnitsLoading: null == isUnitsLoading ? _self.isUnitsLoading : isUnitsLoading // ignore: cast_nullable_to_non_nullable
as bool,isBidsLoading: null == isBidsLoading ? _self.isBidsLoading : isBidsLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

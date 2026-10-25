// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_tx.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TxSignatureVerification {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxSignatureVerification);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TxSignatureVerification()';
}


}

/// @nodoc
class $TxSignatureVerificationCopyWith<$Res>  {
$TxSignatureVerificationCopyWith(TxSignatureVerification _, $Res Function(TxSignatureVerification) __);
}


/// Adds pattern-matching-related methods to [TxSignatureVerification].
extension TxSignatureVerificationPatterns on TxSignatureVerification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TxSignatureVerification_Valid value)?  valid,TResult Function( TxSignatureVerification_InvalidSignatures value)?  invalidSignatures,TResult Function( TxSignatureVerification_Malformed value)?  malformed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TxSignatureVerification_Valid() when valid != null:
return valid(_that);case TxSignatureVerification_InvalidSignatures() when invalidSignatures != null:
return invalidSignatures(_that);case TxSignatureVerification_Malformed() when malformed != null:
return malformed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TxSignatureVerification_Valid value)  valid,required TResult Function( TxSignatureVerification_InvalidSignatures value)  invalidSignatures,required TResult Function( TxSignatureVerification_Malformed value)  malformed,}){
final _that = this;
switch (_that) {
case TxSignatureVerification_Valid():
return valid(_that);case TxSignatureVerification_InvalidSignatures():
return invalidSignatures(_that);case TxSignatureVerification_Malformed():
return malformed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TxSignatureVerification_Valid value)?  valid,TResult? Function( TxSignatureVerification_InvalidSignatures value)?  invalidSignatures,TResult? Function( TxSignatureVerification_Malformed value)?  malformed,}){
final _that = this;
switch (_that) {
case TxSignatureVerification_Valid() when valid != null:
return valid(_that);case TxSignatureVerification_InvalidSignatures() when invalidSignatures != null:
return invalidSignatures(_that);case TxSignatureVerification_Malformed() when malformed != null:
return malformed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  valid,TResult Function( Uint32List invalidInputIndexes)?  invalidSignatures,TResult Function( String message)?  malformed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TxSignatureVerification_Valid() when valid != null:
return valid();case TxSignatureVerification_InvalidSignatures() when invalidSignatures != null:
return invalidSignatures(_that.invalidInputIndexes);case TxSignatureVerification_Malformed() when malformed != null:
return malformed(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  valid,required TResult Function( Uint32List invalidInputIndexes)  invalidSignatures,required TResult Function( String message)  malformed,}) {final _that = this;
switch (_that) {
case TxSignatureVerification_Valid():
return valid();case TxSignatureVerification_InvalidSignatures():
return invalidSignatures(_that.invalidInputIndexes);case TxSignatureVerification_Malformed():
return malformed(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  valid,TResult? Function( Uint32List invalidInputIndexes)?  invalidSignatures,TResult? Function( String message)?  malformed,}) {final _that = this;
switch (_that) {
case TxSignatureVerification_Valid() when valid != null:
return valid();case TxSignatureVerification_InvalidSignatures() when invalidSignatures != null:
return invalidSignatures(_that.invalidInputIndexes);case TxSignatureVerification_Malformed() when malformed != null:
return malformed(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class TxSignatureVerification_Valid extends TxSignatureVerification {
  const TxSignatureVerification_Valid(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxSignatureVerification_Valid);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TxSignatureVerification.valid()';
}


}




/// @nodoc


class TxSignatureVerification_InvalidSignatures extends TxSignatureVerification {
  const TxSignatureVerification_InvalidSignatures({required this.invalidInputIndexes}): super._();
  

 final  Uint32List invalidInputIndexes;

/// Create a copy of TxSignatureVerification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxSignatureVerification_InvalidSignaturesCopyWith<TxSignatureVerification_InvalidSignatures> get copyWith => _$TxSignatureVerification_InvalidSignaturesCopyWithImpl<TxSignatureVerification_InvalidSignatures>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxSignatureVerification_InvalidSignatures&&const DeepCollectionEquality().equals(other.invalidInputIndexes, invalidInputIndexes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(invalidInputIndexes));

@override
String toString() {
  return 'TxSignatureVerification.invalidSignatures(invalidInputIndexes: $invalidInputIndexes)';
}


}

/// @nodoc
abstract mixin class $TxSignatureVerification_InvalidSignaturesCopyWith<$Res> implements $TxSignatureVerificationCopyWith<$Res> {
  factory $TxSignatureVerification_InvalidSignaturesCopyWith(TxSignatureVerification_InvalidSignatures value, $Res Function(TxSignatureVerification_InvalidSignatures) _then) = _$TxSignatureVerification_InvalidSignaturesCopyWithImpl;
@useResult
$Res call({
 Uint32List invalidInputIndexes
});




}
/// @nodoc
class _$TxSignatureVerification_InvalidSignaturesCopyWithImpl<$Res>
    implements $TxSignatureVerification_InvalidSignaturesCopyWith<$Res> {
  _$TxSignatureVerification_InvalidSignaturesCopyWithImpl(this._self, this._then);

  final TxSignatureVerification_InvalidSignatures _self;
  final $Res Function(TxSignatureVerification_InvalidSignatures) _then;

/// Create a copy of TxSignatureVerification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invalidInputIndexes = null,}) {
  return _then(TxSignatureVerification_InvalidSignatures(
invalidInputIndexes: null == invalidInputIndexes ? _self.invalidInputIndexes : invalidInputIndexes // ignore: cast_nullable_to_non_nullable
as Uint32List,
  ));
}


}

/// @nodoc


class TxSignatureVerification_Malformed extends TxSignatureVerification {
  const TxSignatureVerification_Malformed({required this.message}): super._();
  

 final  String message;

/// Create a copy of TxSignatureVerification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxSignatureVerification_MalformedCopyWith<TxSignatureVerification_Malformed> get copyWith => _$TxSignatureVerification_MalformedCopyWithImpl<TxSignatureVerification_Malformed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxSignatureVerification_Malformed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TxSignatureVerification.malformed(message: $message)';
}


}

/// @nodoc
abstract mixin class $TxSignatureVerification_MalformedCopyWith<$Res> implements $TxSignatureVerificationCopyWith<$Res> {
  factory $TxSignatureVerification_MalformedCopyWith(TxSignatureVerification_Malformed value, $Res Function(TxSignatureVerification_Malformed) _then) = _$TxSignatureVerification_MalformedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$TxSignatureVerification_MalformedCopyWithImpl<$Res>
    implements $TxSignatureVerification_MalformedCopyWith<$Res> {
  _$TxSignatureVerification_MalformedCopyWithImpl(this._self, this._then);

  final TxSignatureVerification_Malformed _self;
  final $Res Function(TxSignatureVerification_Malformed) _then;

/// Create a copy of TxSignatureVerification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(TxSignatureVerification_Malformed(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

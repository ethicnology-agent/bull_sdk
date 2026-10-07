// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simple.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutputDestination {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutputDestination);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OutputDestination()';
}


}

/// @nodoc
class $OutputDestinationCopyWith<$Res>  {
$OutputDestinationCopyWith(OutputDestination _, $Res Function(OutputDestination) __);
}


/// Adds pattern-matching-related methods to [OutputDestination].
extension OutputDestinationPatterns on OutputDestination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OutputDestination_SilentPayment value)?  silentPayment,TResult Function( OutputDestination_Address value)?  address,TResult Function( OutputDestination_Script value)?  script,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OutputDestination_SilentPayment() when silentPayment != null:
return silentPayment(_that);case OutputDestination_Address() when address != null:
return address(_that);case OutputDestination_Script() when script != null:
return script(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OutputDestination_SilentPayment value)  silentPayment,required TResult Function( OutputDestination_Address value)  address,required TResult Function( OutputDestination_Script value)  script,}){
final _that = this;
switch (_that) {
case OutputDestination_SilentPayment():
return silentPayment(_that);case OutputDestination_Address():
return address(_that);case OutputDestination_Script():
return script(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OutputDestination_SilentPayment value)?  silentPayment,TResult? Function( OutputDestination_Address value)?  address,TResult? Function( OutputDestination_Script value)?  script,}){
final _that = this;
switch (_that) {
case OutputDestination_SilentPayment() when silentPayment != null:
return silentPayment(_that);case OutputDestination_Address() when address != null:
return address(_that);case OutputDestination_Script() when script != null:
return script(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String address,  String scanKey,  String spendKey,  int? label)?  silentPayment,TResult Function( String address)?  address,TResult Function( String scriptHex)?  script,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OutputDestination_SilentPayment() when silentPayment != null:
return silentPayment(_that.address,_that.scanKey,_that.spendKey,_that.label);case OutputDestination_Address() when address != null:
return address(_that.address);case OutputDestination_Script() when script != null:
return script(_that.scriptHex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String address,  String scanKey,  String spendKey,  int? label)  silentPayment,required TResult Function( String address)  address,required TResult Function( String scriptHex)  script,}) {final _that = this;
switch (_that) {
case OutputDestination_SilentPayment():
return silentPayment(_that.address,_that.scanKey,_that.spendKey,_that.label);case OutputDestination_Address():
return address(_that.address);case OutputDestination_Script():
return script(_that.scriptHex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String address,  String scanKey,  String spendKey,  int? label)?  silentPayment,TResult? Function( String address)?  address,TResult? Function( String scriptHex)?  script,}) {final _that = this;
switch (_that) {
case OutputDestination_SilentPayment() when silentPayment != null:
return silentPayment(_that.address,_that.scanKey,_that.spendKey,_that.label);case OutputDestination_Address() when address != null:
return address(_that.address);case OutputDestination_Script() when script != null:
return script(_that.scriptHex);case _:
  return null;

}
}

}

/// @nodoc


class OutputDestination_SilentPayment extends OutputDestination {
  const OutputDestination_SilentPayment({required this.address, required this.scanKey, required this.spendKey, this.label}): super._();
  

 final  String address;
 final  String scanKey;
 final  String spendKey;
 final  int? label;

/// Create a copy of OutputDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutputDestination_SilentPaymentCopyWith<OutputDestination_SilentPayment> get copyWith => _$OutputDestination_SilentPaymentCopyWithImpl<OutputDestination_SilentPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutputDestination_SilentPayment&&(identical(other.address, address) || other.address == address)&&(identical(other.scanKey, scanKey) || other.scanKey == scanKey)&&(identical(other.spendKey, spendKey) || other.spendKey == spendKey)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,address,scanKey,spendKey,label);

@override
String toString() {
  return 'OutputDestination.silentPayment(address: $address, scanKey: $scanKey, spendKey: $spendKey, label: $label)';
}


}

/// @nodoc
abstract mixin class $OutputDestination_SilentPaymentCopyWith<$Res> implements $OutputDestinationCopyWith<$Res> {
  factory $OutputDestination_SilentPaymentCopyWith(OutputDestination_SilentPayment value, $Res Function(OutputDestination_SilentPayment) _then) = _$OutputDestination_SilentPaymentCopyWithImpl;
@useResult
$Res call({
 String address, String scanKey, String spendKey, int? label
});




}
/// @nodoc
class _$OutputDestination_SilentPaymentCopyWithImpl<$Res>
    implements $OutputDestination_SilentPaymentCopyWith<$Res> {
  _$OutputDestination_SilentPaymentCopyWithImpl(this._self, this._then);

  final OutputDestination_SilentPayment _self;
  final $Res Function(OutputDestination_SilentPayment) _then;

/// Create a copy of OutputDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? address = null,Object? scanKey = null,Object? spendKey = null,Object? label = freezed,}) {
  return _then(OutputDestination_SilentPayment(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,scanKey: null == scanKey ? _self.scanKey : scanKey // ignore: cast_nullable_to_non_nullable
as String,spendKey: null == spendKey ? _self.spendKey : spendKey // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class OutputDestination_Address extends OutputDestination {
  const OutputDestination_Address({required this.address}): super._();
  

 final  String address;

/// Create a copy of OutputDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutputDestination_AddressCopyWith<OutputDestination_Address> get copyWith => _$OutputDestination_AddressCopyWithImpl<OutputDestination_Address>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutputDestination_Address&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode => Object.hash(runtimeType,address);

@override
String toString() {
  return 'OutputDestination.address(address: $address)';
}


}

/// @nodoc
abstract mixin class $OutputDestination_AddressCopyWith<$Res> implements $OutputDestinationCopyWith<$Res> {
  factory $OutputDestination_AddressCopyWith(OutputDestination_Address value, $Res Function(OutputDestination_Address) _then) = _$OutputDestination_AddressCopyWithImpl;
@useResult
$Res call({
 String address
});




}
/// @nodoc
class _$OutputDestination_AddressCopyWithImpl<$Res>
    implements $OutputDestination_AddressCopyWith<$Res> {
  _$OutputDestination_AddressCopyWithImpl(this._self, this._then);

  final OutputDestination_Address _self;
  final $Res Function(OutputDestination_Address) _then;

/// Create a copy of OutputDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? address = null,}) {
  return _then(OutputDestination_Address(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class OutputDestination_Script extends OutputDestination {
  const OutputDestination_Script({required this.scriptHex}): super._();
  

 final  String scriptHex;

/// Create a copy of OutputDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutputDestination_ScriptCopyWith<OutputDestination_Script> get copyWith => _$OutputDestination_ScriptCopyWithImpl<OutputDestination_Script>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutputDestination_Script&&(identical(other.scriptHex, scriptHex) || other.scriptHex == scriptHex));
}


@override
int get hashCode => Object.hash(runtimeType,scriptHex);

@override
String toString() {
  return 'OutputDestination.script(scriptHex: $scriptHex)';
}


}

/// @nodoc
abstract mixin class $OutputDestination_ScriptCopyWith<$Res> implements $OutputDestinationCopyWith<$Res> {
  factory $OutputDestination_ScriptCopyWith(OutputDestination_Script value, $Res Function(OutputDestination_Script) _then) = _$OutputDestination_ScriptCopyWithImpl;
@useResult
$Res call({
 String scriptHex
});




}
/// @nodoc
class _$OutputDestination_ScriptCopyWithImpl<$Res>
    implements $OutputDestination_ScriptCopyWith<$Res> {
  _$OutputDestination_ScriptCopyWithImpl(this._self, this._then);

  final OutputDestination_Script _self;
  final $Res Function(OutputDestination_Script) _then;

/// Create a copy of OutputDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scriptHex = null,}) {
  return _then(OutputDestination_Script(
scriptHex: null == scriptHex ? _self.scriptHex : scriptHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$RecipientView {

 String get address; BigInt get amountSat; bool get isMax;
/// Create a copy of RecipientView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipientViewCopyWith<RecipientView> get copyWith => _$RecipientViewCopyWithImpl<RecipientView>(this as RecipientView, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipientView&&(identical(other.address, address) || other.address == address)&&(identical(other.amountSat, amountSat) || other.amountSat == amountSat)&&(identical(other.isMax, isMax) || other.isMax == isMax));
}


@override
int get hashCode => Object.hash(runtimeType,address,amountSat,isMax);

@override
String toString() {
  return 'RecipientView(address: $address, amountSat: $amountSat, isMax: $isMax)';
}


}

/// @nodoc
abstract mixin class $RecipientViewCopyWith<$Res>  {
  factory $RecipientViewCopyWith(RecipientView value, $Res Function(RecipientView) _then) = _$RecipientViewCopyWithImpl;
@useResult
$Res call({
 String address, BigInt amountSat, bool isMax
});




}
/// @nodoc
class _$RecipientViewCopyWithImpl<$Res>
    implements $RecipientViewCopyWith<$Res> {
  _$RecipientViewCopyWithImpl(this._self, this._then);

  final RecipientView _self;
  final $Res Function(RecipientView) _then;

/// Create a copy of RecipientView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? amountSat = null,Object? isMax = null,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,amountSat: null == amountSat ? _self.amountSat : amountSat // ignore: cast_nullable_to_non_nullable
as BigInt,isMax: null == isMax ? _self.isMax : isMax // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipientView].
extension RecipientViewPatterns on RecipientView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RecipientView_Sp value)?  sp,TResult Function( RecipientView_Standard value)?  standard,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RecipientView_Sp() when sp != null:
return sp(_that);case RecipientView_Standard() when standard != null:
return standard(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RecipientView_Sp value)  sp,required TResult Function( RecipientView_Standard value)  standard,}){
final _that = this;
switch (_that) {
case RecipientView_Sp():
return sp(_that);case RecipientView_Standard():
return standard(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RecipientView_Sp value)?  sp,TResult? Function( RecipientView_Standard value)?  standard,}){
final _that = this;
switch (_that) {
case RecipientView_Sp() when sp != null:
return sp(_that);case RecipientView_Standard() when standard != null:
return standard(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String address,  BigInt amountSat,  int? label,  bool isMax)?  sp,TResult Function( String address,  BigInt amountSat,  bool isMax)?  standard,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RecipientView_Sp() when sp != null:
return sp(_that.address,_that.amountSat,_that.label,_that.isMax);case RecipientView_Standard() when standard != null:
return standard(_that.address,_that.amountSat,_that.isMax);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String address,  BigInt amountSat,  int? label,  bool isMax)  sp,required TResult Function( String address,  BigInt amountSat,  bool isMax)  standard,}) {final _that = this;
switch (_that) {
case RecipientView_Sp():
return sp(_that.address,_that.amountSat,_that.label,_that.isMax);case RecipientView_Standard():
return standard(_that.address,_that.amountSat,_that.isMax);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String address,  BigInt amountSat,  int? label,  bool isMax)?  sp,TResult? Function( String address,  BigInt amountSat,  bool isMax)?  standard,}) {final _that = this;
switch (_that) {
case RecipientView_Sp() when sp != null:
return sp(_that.address,_that.amountSat,_that.label,_that.isMax);case RecipientView_Standard() when standard != null:
return standard(_that.address,_that.amountSat,_that.isMax);case _:
  return null;

}
}

}

/// @nodoc


class RecipientView_Sp extends RecipientView {
  const RecipientView_Sp({required this.address, required this.amountSat, this.label, required this.isMax}): super._();
  

@override final  String address;
@override final  BigInt amountSat;
 final  int? label;
@override final  bool isMax;

/// Create a copy of RecipientView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipientView_SpCopyWith<RecipientView_Sp> get copyWith => _$RecipientView_SpCopyWithImpl<RecipientView_Sp>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipientView_Sp&&(identical(other.address, address) || other.address == address)&&(identical(other.amountSat, amountSat) || other.amountSat == amountSat)&&(identical(other.label, label) || other.label == label)&&(identical(other.isMax, isMax) || other.isMax == isMax));
}


@override
int get hashCode => Object.hash(runtimeType,address,amountSat,label,isMax);

@override
String toString() {
  return 'RecipientView.sp(address: $address, amountSat: $amountSat, label: $label, isMax: $isMax)';
}


}

/// @nodoc
abstract mixin class $RecipientView_SpCopyWith<$Res> implements $RecipientViewCopyWith<$Res> {
  factory $RecipientView_SpCopyWith(RecipientView_Sp value, $Res Function(RecipientView_Sp) _then) = _$RecipientView_SpCopyWithImpl;
@override @useResult
$Res call({
 String address, BigInt amountSat, int? label, bool isMax
});




}
/// @nodoc
class _$RecipientView_SpCopyWithImpl<$Res>
    implements $RecipientView_SpCopyWith<$Res> {
  _$RecipientView_SpCopyWithImpl(this._self, this._then);

  final RecipientView_Sp _self;
  final $Res Function(RecipientView_Sp) _then;

/// Create a copy of RecipientView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? amountSat = null,Object? label = freezed,Object? isMax = null,}) {
  return _then(RecipientView_Sp(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,amountSat: null == amountSat ? _self.amountSat : amountSat // ignore: cast_nullable_to_non_nullable
as BigInt,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as int?,isMax: null == isMax ? _self.isMax : isMax // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class RecipientView_Standard extends RecipientView {
  const RecipientView_Standard({required this.address, required this.amountSat, required this.isMax}): super._();
  

@override final  String address;
@override final  BigInt amountSat;
@override final  bool isMax;

/// Create a copy of RecipientView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipientView_StandardCopyWith<RecipientView_Standard> get copyWith => _$RecipientView_StandardCopyWithImpl<RecipientView_Standard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipientView_Standard&&(identical(other.address, address) || other.address == address)&&(identical(other.amountSat, amountSat) || other.amountSat == amountSat)&&(identical(other.isMax, isMax) || other.isMax == isMax));
}


@override
int get hashCode => Object.hash(runtimeType,address,amountSat,isMax);

@override
String toString() {
  return 'RecipientView.standard(address: $address, amountSat: $amountSat, isMax: $isMax)';
}


}

/// @nodoc
abstract mixin class $RecipientView_StandardCopyWith<$Res> implements $RecipientViewCopyWith<$Res> {
  factory $RecipientView_StandardCopyWith(RecipientView_Standard value, $Res Function(RecipientView_Standard) _then) = _$RecipientView_StandardCopyWithImpl;
@override @useResult
$Res call({
 String address, BigInt amountSat, bool isMax
});




}
/// @nodoc
class _$RecipientView_StandardCopyWithImpl<$Res>
    implements $RecipientView_StandardCopyWith<$Res> {
  _$RecipientView_StandardCopyWithImpl(this._self, this._then);

  final RecipientView_Standard _self;
  final $Res Function(RecipientView_Standard) _then;

/// Create a copy of RecipientView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? amountSat = null,Object? isMax = null,}) {
  return _then(RecipientView_Standard(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,amountSat: null == amountSat ? _self.amountSat : amountSat // ignore: cast_nullable_to_non_nullable
as BigInt,isMax: null == isMax ? _self.isMax : isMax // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SpError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpError()';
}


}

/// @nodoc
class $SpErrorCopyWith<$Res>  {
$SpErrorCopyWith(SpError _, $Res Function(SpError) __);
}


/// Adds pattern-matching-related methods to [SpError].
extension SpErrorPatterns on SpError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpError_ScannerAlreadyRunning value)?  scannerAlreadyRunning,TResult Function( SpError_DisposeTimedOut value)?  disposeTimedOut,TResult Function( SpError_SimulationDrifted value)?  simulationDrifted,TResult Function( SpError_TooManyCoins value)?  tooManyCoins,TResult Function( SpError_NothingToSendAfterFee value)?  nothingToSendAfterFee,TResult Function( SpError_InvalidDescriptor value)?  invalidDescriptor,TResult Function( SpError_Signing value)?  signing,TResult Function( SpError_SignedPsbtMismatch value)?  signedPsbtMismatch,TResult Function( SpError_Verification value)?  verification,TResult Function( SpError_Other value)?  other,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpError_ScannerAlreadyRunning() when scannerAlreadyRunning != null:
return scannerAlreadyRunning(_that);case SpError_DisposeTimedOut() when disposeTimedOut != null:
return disposeTimedOut(_that);case SpError_SimulationDrifted() when simulationDrifted != null:
return simulationDrifted(_that);case SpError_TooManyCoins() when tooManyCoins != null:
return tooManyCoins(_that);case SpError_NothingToSendAfterFee() when nothingToSendAfterFee != null:
return nothingToSendAfterFee(_that);case SpError_InvalidDescriptor() when invalidDescriptor != null:
return invalidDescriptor(_that);case SpError_Signing() when signing != null:
return signing(_that);case SpError_SignedPsbtMismatch() when signedPsbtMismatch != null:
return signedPsbtMismatch(_that);case SpError_Verification() when verification != null:
return verification(_that);case SpError_Other() when other != null:
return other(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpError_ScannerAlreadyRunning value)  scannerAlreadyRunning,required TResult Function( SpError_DisposeTimedOut value)  disposeTimedOut,required TResult Function( SpError_SimulationDrifted value)  simulationDrifted,required TResult Function( SpError_TooManyCoins value)  tooManyCoins,required TResult Function( SpError_NothingToSendAfterFee value)  nothingToSendAfterFee,required TResult Function( SpError_InvalidDescriptor value)  invalidDescriptor,required TResult Function( SpError_Signing value)  signing,required TResult Function( SpError_SignedPsbtMismatch value)  signedPsbtMismatch,required TResult Function( SpError_Verification value)  verification,required TResult Function( SpError_Other value)  other,}){
final _that = this;
switch (_that) {
case SpError_ScannerAlreadyRunning():
return scannerAlreadyRunning(_that);case SpError_DisposeTimedOut():
return disposeTimedOut(_that);case SpError_SimulationDrifted():
return simulationDrifted(_that);case SpError_TooManyCoins():
return tooManyCoins(_that);case SpError_NothingToSendAfterFee():
return nothingToSendAfterFee(_that);case SpError_InvalidDescriptor():
return invalidDescriptor(_that);case SpError_Signing():
return signing(_that);case SpError_SignedPsbtMismatch():
return signedPsbtMismatch(_that);case SpError_Verification():
return verification(_that);case SpError_Other():
return other(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpError_ScannerAlreadyRunning value)?  scannerAlreadyRunning,TResult? Function( SpError_DisposeTimedOut value)?  disposeTimedOut,TResult? Function( SpError_SimulationDrifted value)?  simulationDrifted,TResult? Function( SpError_TooManyCoins value)?  tooManyCoins,TResult? Function( SpError_NothingToSendAfterFee value)?  nothingToSendAfterFee,TResult? Function( SpError_InvalidDescriptor value)?  invalidDescriptor,TResult? Function( SpError_Signing value)?  signing,TResult? Function( SpError_SignedPsbtMismatch value)?  signedPsbtMismatch,TResult? Function( SpError_Verification value)?  verification,TResult? Function( SpError_Other value)?  other,}){
final _that = this;
switch (_that) {
case SpError_ScannerAlreadyRunning() when scannerAlreadyRunning != null:
return scannerAlreadyRunning(_that);case SpError_DisposeTimedOut() when disposeTimedOut != null:
return disposeTimedOut(_that);case SpError_SimulationDrifted() when simulationDrifted != null:
return simulationDrifted(_that);case SpError_TooManyCoins() when tooManyCoins != null:
return tooManyCoins(_that);case SpError_NothingToSendAfterFee() when nothingToSendAfterFee != null:
return nothingToSendAfterFee(_that);case SpError_InvalidDescriptor() when invalidDescriptor != null:
return invalidDescriptor(_that);case SpError_Signing() when signing != null:
return signing(_that);case SpError_SignedPsbtMismatch() when signedPsbtMismatch != null:
return signedPsbtMismatch(_that);case SpError_Verification() when verification != null:
return verification(_that);case SpError_Other() when other != null:
return other(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  scannerAlreadyRunning,TResult Function()?  disposeTimedOut,TResult Function( String detail)?  simulationDrifted,TResult Function( int count,  int max)?  tooManyCoins,TResult Function( BigInt remainderSat)?  nothingToSendAfterFee,TResult Function( String reason)?  invalidDescriptor,TResult Function( String reason)?  signing,TResult Function( String detail)?  signedPsbtMismatch,TResult Function( String reason)?  verification,TResult Function( String message)?  other,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpError_ScannerAlreadyRunning() when scannerAlreadyRunning != null:
return scannerAlreadyRunning();case SpError_DisposeTimedOut() when disposeTimedOut != null:
return disposeTimedOut();case SpError_SimulationDrifted() when simulationDrifted != null:
return simulationDrifted(_that.detail);case SpError_TooManyCoins() when tooManyCoins != null:
return tooManyCoins(_that.count,_that.max);case SpError_NothingToSendAfterFee() when nothingToSendAfterFee != null:
return nothingToSendAfterFee(_that.remainderSat);case SpError_InvalidDescriptor() when invalidDescriptor != null:
return invalidDescriptor(_that.reason);case SpError_Signing() when signing != null:
return signing(_that.reason);case SpError_SignedPsbtMismatch() when signedPsbtMismatch != null:
return signedPsbtMismatch(_that.detail);case SpError_Verification() when verification != null:
return verification(_that.reason);case SpError_Other() when other != null:
return other(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  scannerAlreadyRunning,required TResult Function()  disposeTimedOut,required TResult Function( String detail)  simulationDrifted,required TResult Function( int count,  int max)  tooManyCoins,required TResult Function( BigInt remainderSat)  nothingToSendAfterFee,required TResult Function( String reason)  invalidDescriptor,required TResult Function( String reason)  signing,required TResult Function( String detail)  signedPsbtMismatch,required TResult Function( String reason)  verification,required TResult Function( String message)  other,}) {final _that = this;
switch (_that) {
case SpError_ScannerAlreadyRunning():
return scannerAlreadyRunning();case SpError_DisposeTimedOut():
return disposeTimedOut();case SpError_SimulationDrifted():
return simulationDrifted(_that.detail);case SpError_TooManyCoins():
return tooManyCoins(_that.count,_that.max);case SpError_NothingToSendAfterFee():
return nothingToSendAfterFee(_that.remainderSat);case SpError_InvalidDescriptor():
return invalidDescriptor(_that.reason);case SpError_Signing():
return signing(_that.reason);case SpError_SignedPsbtMismatch():
return signedPsbtMismatch(_that.detail);case SpError_Verification():
return verification(_that.reason);case SpError_Other():
return other(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  scannerAlreadyRunning,TResult? Function()?  disposeTimedOut,TResult? Function( String detail)?  simulationDrifted,TResult? Function( int count,  int max)?  tooManyCoins,TResult? Function( BigInt remainderSat)?  nothingToSendAfterFee,TResult? Function( String reason)?  invalidDescriptor,TResult? Function( String reason)?  signing,TResult? Function( String detail)?  signedPsbtMismatch,TResult? Function( String reason)?  verification,TResult? Function( String message)?  other,}) {final _that = this;
switch (_that) {
case SpError_ScannerAlreadyRunning() when scannerAlreadyRunning != null:
return scannerAlreadyRunning();case SpError_DisposeTimedOut() when disposeTimedOut != null:
return disposeTimedOut();case SpError_SimulationDrifted() when simulationDrifted != null:
return simulationDrifted(_that.detail);case SpError_TooManyCoins() when tooManyCoins != null:
return tooManyCoins(_that.count,_that.max);case SpError_NothingToSendAfterFee() when nothingToSendAfterFee != null:
return nothingToSendAfterFee(_that.remainderSat);case SpError_InvalidDescriptor() when invalidDescriptor != null:
return invalidDescriptor(_that.reason);case SpError_Signing() when signing != null:
return signing(_that.reason);case SpError_SignedPsbtMismatch() when signedPsbtMismatch != null:
return signedPsbtMismatch(_that.detail);case SpError_Verification() when verification != null:
return verification(_that.reason);case SpError_Other() when other != null:
return other(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SpError_ScannerAlreadyRunning extends SpError {
  const SpError_ScannerAlreadyRunning(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_ScannerAlreadyRunning);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpError.scannerAlreadyRunning()';
}


}




/// @nodoc


class SpError_DisposeTimedOut extends SpError {
  const SpError_DisposeTimedOut(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_DisposeTimedOut);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpError.disposeTimedOut()';
}


}




/// @nodoc


class SpError_SimulationDrifted extends SpError {
  const SpError_SimulationDrifted({required this.detail}): super._();
  

 final  String detail;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_SimulationDriftedCopyWith<SpError_SimulationDrifted> get copyWith => _$SpError_SimulationDriftedCopyWithImpl<SpError_SimulationDrifted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_SimulationDrifted&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,detail);

@override
String toString() {
  return 'SpError.simulationDrifted(detail: $detail)';
}


}

/// @nodoc
abstract mixin class $SpError_SimulationDriftedCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_SimulationDriftedCopyWith(SpError_SimulationDrifted value, $Res Function(SpError_SimulationDrifted) _then) = _$SpError_SimulationDriftedCopyWithImpl;
@useResult
$Res call({
 String detail
});




}
/// @nodoc
class _$SpError_SimulationDriftedCopyWithImpl<$Res>
    implements $SpError_SimulationDriftedCopyWith<$Res> {
  _$SpError_SimulationDriftedCopyWithImpl(this._self, this._then);

  final SpError_SimulationDrifted _self;
  final $Res Function(SpError_SimulationDrifted) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? detail = null,}) {
  return _then(SpError_SimulationDrifted(
detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpError_TooManyCoins extends SpError {
  const SpError_TooManyCoins({required this.count, required this.max}): super._();
  

 final  int count;
 final  int max;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_TooManyCoinsCopyWith<SpError_TooManyCoins> get copyWith => _$SpError_TooManyCoinsCopyWithImpl<SpError_TooManyCoins>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_TooManyCoins&&(identical(other.count, count) || other.count == count)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode => Object.hash(runtimeType,count,max);

@override
String toString() {
  return 'SpError.tooManyCoins(count: $count, max: $max)';
}


}

/// @nodoc
abstract mixin class $SpError_TooManyCoinsCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_TooManyCoinsCopyWith(SpError_TooManyCoins value, $Res Function(SpError_TooManyCoins) _then) = _$SpError_TooManyCoinsCopyWithImpl;
@useResult
$Res call({
 int count, int max
});




}
/// @nodoc
class _$SpError_TooManyCoinsCopyWithImpl<$Res>
    implements $SpError_TooManyCoinsCopyWith<$Res> {
  _$SpError_TooManyCoinsCopyWithImpl(this._self, this._then);

  final SpError_TooManyCoins _self;
  final $Res Function(SpError_TooManyCoins) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? count = null,Object? max = null,}) {
  return _then(SpError_TooManyCoins(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SpError_NothingToSendAfterFee extends SpError {
  const SpError_NothingToSendAfterFee({required this.remainderSat}): super._();
  

 final  BigInt remainderSat;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_NothingToSendAfterFeeCopyWith<SpError_NothingToSendAfterFee> get copyWith => _$SpError_NothingToSendAfterFeeCopyWithImpl<SpError_NothingToSendAfterFee>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_NothingToSendAfterFee&&(identical(other.remainderSat, remainderSat) || other.remainderSat == remainderSat));
}


@override
int get hashCode => Object.hash(runtimeType,remainderSat);

@override
String toString() {
  return 'SpError.nothingToSendAfterFee(remainderSat: $remainderSat)';
}


}

/// @nodoc
abstract mixin class $SpError_NothingToSendAfterFeeCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_NothingToSendAfterFeeCopyWith(SpError_NothingToSendAfterFee value, $Res Function(SpError_NothingToSendAfterFee) _then) = _$SpError_NothingToSendAfterFeeCopyWithImpl;
@useResult
$Res call({
 BigInt remainderSat
});




}
/// @nodoc
class _$SpError_NothingToSendAfterFeeCopyWithImpl<$Res>
    implements $SpError_NothingToSendAfterFeeCopyWith<$Res> {
  _$SpError_NothingToSendAfterFeeCopyWithImpl(this._self, this._then);

  final SpError_NothingToSendAfterFee _self;
  final $Res Function(SpError_NothingToSendAfterFee) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? remainderSat = null,}) {
  return _then(SpError_NothingToSendAfterFee(
remainderSat: null == remainderSat ? _self.remainderSat : remainderSat // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class SpError_InvalidDescriptor extends SpError {
  const SpError_InvalidDescriptor({required this.reason}): super._();
  

 final  String reason;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_InvalidDescriptorCopyWith<SpError_InvalidDescriptor> get copyWith => _$SpError_InvalidDescriptorCopyWithImpl<SpError_InvalidDescriptor>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_InvalidDescriptor&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'SpError.invalidDescriptor(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $SpError_InvalidDescriptorCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_InvalidDescriptorCopyWith(SpError_InvalidDescriptor value, $Res Function(SpError_InvalidDescriptor) _then) = _$SpError_InvalidDescriptorCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$SpError_InvalidDescriptorCopyWithImpl<$Res>
    implements $SpError_InvalidDescriptorCopyWith<$Res> {
  _$SpError_InvalidDescriptorCopyWithImpl(this._self, this._then);

  final SpError_InvalidDescriptor _self;
  final $Res Function(SpError_InvalidDescriptor) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SpError_InvalidDescriptor(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpError_Signing extends SpError {
  const SpError_Signing({required this.reason}): super._();
  

 final  String reason;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_SigningCopyWith<SpError_Signing> get copyWith => _$SpError_SigningCopyWithImpl<SpError_Signing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_Signing&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'SpError.signing(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $SpError_SigningCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_SigningCopyWith(SpError_Signing value, $Res Function(SpError_Signing) _then) = _$SpError_SigningCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$SpError_SigningCopyWithImpl<$Res>
    implements $SpError_SigningCopyWith<$Res> {
  _$SpError_SigningCopyWithImpl(this._self, this._then);

  final SpError_Signing _self;
  final $Res Function(SpError_Signing) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SpError_Signing(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpError_SignedPsbtMismatch extends SpError {
  const SpError_SignedPsbtMismatch({required this.detail}): super._();
  

 final  String detail;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_SignedPsbtMismatchCopyWith<SpError_SignedPsbtMismatch> get copyWith => _$SpError_SignedPsbtMismatchCopyWithImpl<SpError_SignedPsbtMismatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_SignedPsbtMismatch&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,detail);

@override
String toString() {
  return 'SpError.signedPsbtMismatch(detail: $detail)';
}


}

/// @nodoc
abstract mixin class $SpError_SignedPsbtMismatchCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_SignedPsbtMismatchCopyWith(SpError_SignedPsbtMismatch value, $Res Function(SpError_SignedPsbtMismatch) _then) = _$SpError_SignedPsbtMismatchCopyWithImpl;
@useResult
$Res call({
 String detail
});




}
/// @nodoc
class _$SpError_SignedPsbtMismatchCopyWithImpl<$Res>
    implements $SpError_SignedPsbtMismatchCopyWith<$Res> {
  _$SpError_SignedPsbtMismatchCopyWithImpl(this._self, this._then);

  final SpError_SignedPsbtMismatch _self;
  final $Res Function(SpError_SignedPsbtMismatch) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? detail = null,}) {
  return _then(SpError_SignedPsbtMismatch(
detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpError_Verification extends SpError {
  const SpError_Verification({required this.reason}): super._();
  

 final  String reason;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_VerificationCopyWith<SpError_Verification> get copyWith => _$SpError_VerificationCopyWithImpl<SpError_Verification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_Verification&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'SpError.verification(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $SpError_VerificationCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_VerificationCopyWith(SpError_Verification value, $Res Function(SpError_Verification) _then) = _$SpError_VerificationCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$SpError_VerificationCopyWithImpl<$Res>
    implements $SpError_VerificationCopyWith<$Res> {
  _$SpError_VerificationCopyWithImpl(this._self, this._then);

  final SpError_Verification _self;
  final $Res Function(SpError_Verification) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SpError_Verification(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpError_Other extends SpError {
  const SpError_Other({required this.message}): super._();
  

 final  String message;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpError_OtherCopyWith<SpError_Other> get copyWith => _$SpError_OtherCopyWithImpl<SpError_Other>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpError_Other&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SpError.other(message: $message)';
}


}

/// @nodoc
abstract mixin class $SpError_OtherCopyWith<$Res> implements $SpErrorCopyWith<$Res> {
  factory $SpError_OtherCopyWith(SpError_Other value, $Res Function(SpError_Other) _then) = _$SpError_OtherCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SpError_OtherCopyWithImpl<$Res>
    implements $SpError_OtherCopyWith<$Res> {
  _$SpError_OtherCopyWithImpl(this._self, this._then);

  final SpError_Other _self;
  final $Res Function(SpError_Other) _then;

/// Create a copy of SpError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SpError_Other(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SpNotification {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpNotification()';
}


}

/// @nodoc
class $SpNotificationCopyWith<$Res>  {
$SpNotificationCopyWith(SpNotification _, $Res Function(SpNotification) __);
}


/// Adds pattern-matching-related methods to [SpNotification].
extension SpNotificationPatterns on SpNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpNotification_ScanStarted value)?  scanStarted,TResult Function( SpNotification_ScanReceiveProgress value)?  scanReceiveProgress,TResult Function( SpNotification_ScanCompleted value)?  scanCompleted,TResult Function( SpNotification_ScanStopped value)?  scanStopped,TResult Function( SpNotification_ScanFailed value)?  scanFailed,TResult Function( SpNotification_NewOutput value)?  newOutput,TResult Function( SpNotification_OutputSpent value)?  outputSpent,TResult Function( SpNotification_Broadcasted value)?  broadcasted,TResult Function( SpNotification_BroadcastFailed value)?  broadcastFailed,TResult Function( SpNotification_BackendOffline value)?  backendOffline,TResult Function( SpNotification_ElectrumTx value)?  electrumTx,TResult Function( SpNotification_ScanSpendProgress value)?  scanSpendProgress,TResult Function( SpNotification_HeaderProgressStarted value)?  headerProgressStarted,TResult Function( SpNotification_HeaderProgress value)?  headerProgress,TResult Function( SpNotification_HeaderProgressCompleted value)?  headerProgressCompleted,TResult Function( SpNotification_HeaderProgressFailed value)?  headerProgressFailed,TResult Function( SpNotification_PaymentHistoryUpdated value)?  paymentHistoryUpdated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpNotification_ScanStarted() when scanStarted != null:
return scanStarted(_that);case SpNotification_ScanReceiveProgress() when scanReceiveProgress != null:
return scanReceiveProgress(_that);case SpNotification_ScanCompleted() when scanCompleted != null:
return scanCompleted(_that);case SpNotification_ScanStopped() when scanStopped != null:
return scanStopped(_that);case SpNotification_ScanFailed() when scanFailed != null:
return scanFailed(_that);case SpNotification_NewOutput() when newOutput != null:
return newOutput(_that);case SpNotification_OutputSpent() when outputSpent != null:
return outputSpent(_that);case SpNotification_Broadcasted() when broadcasted != null:
return broadcasted(_that);case SpNotification_BroadcastFailed() when broadcastFailed != null:
return broadcastFailed(_that);case SpNotification_BackendOffline() when backendOffline != null:
return backendOffline(_that);case SpNotification_ElectrumTx() when electrumTx != null:
return electrumTx(_that);case SpNotification_ScanSpendProgress() when scanSpendProgress != null:
return scanSpendProgress(_that);case SpNotification_HeaderProgressStarted() when headerProgressStarted != null:
return headerProgressStarted(_that);case SpNotification_HeaderProgress() when headerProgress != null:
return headerProgress(_that);case SpNotification_HeaderProgressCompleted() when headerProgressCompleted != null:
return headerProgressCompleted(_that);case SpNotification_HeaderProgressFailed() when headerProgressFailed != null:
return headerProgressFailed(_that);case SpNotification_PaymentHistoryUpdated() when paymentHistoryUpdated != null:
return paymentHistoryUpdated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpNotification_ScanStarted value)  scanStarted,required TResult Function( SpNotification_ScanReceiveProgress value)  scanReceiveProgress,required TResult Function( SpNotification_ScanCompleted value)  scanCompleted,required TResult Function( SpNotification_ScanStopped value)  scanStopped,required TResult Function( SpNotification_ScanFailed value)  scanFailed,required TResult Function( SpNotification_NewOutput value)  newOutput,required TResult Function( SpNotification_OutputSpent value)  outputSpent,required TResult Function( SpNotification_Broadcasted value)  broadcasted,required TResult Function( SpNotification_BroadcastFailed value)  broadcastFailed,required TResult Function( SpNotification_BackendOffline value)  backendOffline,required TResult Function( SpNotification_ElectrumTx value)  electrumTx,required TResult Function( SpNotification_ScanSpendProgress value)  scanSpendProgress,required TResult Function( SpNotification_HeaderProgressStarted value)  headerProgressStarted,required TResult Function( SpNotification_HeaderProgress value)  headerProgress,required TResult Function( SpNotification_HeaderProgressCompleted value)  headerProgressCompleted,required TResult Function( SpNotification_HeaderProgressFailed value)  headerProgressFailed,required TResult Function( SpNotification_PaymentHistoryUpdated value)  paymentHistoryUpdated,}){
final _that = this;
switch (_that) {
case SpNotification_ScanStarted():
return scanStarted(_that);case SpNotification_ScanReceiveProgress():
return scanReceiveProgress(_that);case SpNotification_ScanCompleted():
return scanCompleted(_that);case SpNotification_ScanStopped():
return scanStopped(_that);case SpNotification_ScanFailed():
return scanFailed(_that);case SpNotification_NewOutput():
return newOutput(_that);case SpNotification_OutputSpent():
return outputSpent(_that);case SpNotification_Broadcasted():
return broadcasted(_that);case SpNotification_BroadcastFailed():
return broadcastFailed(_that);case SpNotification_BackendOffline():
return backendOffline(_that);case SpNotification_ElectrumTx():
return electrumTx(_that);case SpNotification_ScanSpendProgress():
return scanSpendProgress(_that);case SpNotification_HeaderProgressStarted():
return headerProgressStarted(_that);case SpNotification_HeaderProgress():
return headerProgress(_that);case SpNotification_HeaderProgressCompleted():
return headerProgressCompleted(_that);case SpNotification_HeaderProgressFailed():
return headerProgressFailed(_that);case SpNotification_PaymentHistoryUpdated():
return paymentHistoryUpdated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpNotification_ScanStarted value)?  scanStarted,TResult? Function( SpNotification_ScanReceiveProgress value)?  scanReceiveProgress,TResult? Function( SpNotification_ScanCompleted value)?  scanCompleted,TResult? Function( SpNotification_ScanStopped value)?  scanStopped,TResult? Function( SpNotification_ScanFailed value)?  scanFailed,TResult? Function( SpNotification_NewOutput value)?  newOutput,TResult? Function( SpNotification_OutputSpent value)?  outputSpent,TResult? Function( SpNotification_Broadcasted value)?  broadcasted,TResult? Function( SpNotification_BroadcastFailed value)?  broadcastFailed,TResult? Function( SpNotification_BackendOffline value)?  backendOffline,TResult? Function( SpNotification_ElectrumTx value)?  electrumTx,TResult? Function( SpNotification_ScanSpendProgress value)?  scanSpendProgress,TResult? Function( SpNotification_HeaderProgressStarted value)?  headerProgressStarted,TResult? Function( SpNotification_HeaderProgress value)?  headerProgress,TResult? Function( SpNotification_HeaderProgressCompleted value)?  headerProgressCompleted,TResult? Function( SpNotification_HeaderProgressFailed value)?  headerProgressFailed,TResult? Function( SpNotification_PaymentHistoryUpdated value)?  paymentHistoryUpdated,}){
final _that = this;
switch (_that) {
case SpNotification_ScanStarted() when scanStarted != null:
return scanStarted(_that);case SpNotification_ScanReceiveProgress() when scanReceiveProgress != null:
return scanReceiveProgress(_that);case SpNotification_ScanCompleted() when scanCompleted != null:
return scanCompleted(_that);case SpNotification_ScanStopped() when scanStopped != null:
return scanStopped(_that);case SpNotification_ScanFailed() when scanFailed != null:
return scanFailed(_that);case SpNotification_NewOutput() when newOutput != null:
return newOutput(_that);case SpNotification_OutputSpent() when outputSpent != null:
return outputSpent(_that);case SpNotification_Broadcasted() when broadcasted != null:
return broadcasted(_that);case SpNotification_BroadcastFailed() when broadcastFailed != null:
return broadcastFailed(_that);case SpNotification_BackendOffline() when backendOffline != null:
return backendOffline(_that);case SpNotification_ElectrumTx() when electrumTx != null:
return electrumTx(_that);case SpNotification_ScanSpendProgress() when scanSpendProgress != null:
return scanSpendProgress(_that);case SpNotification_HeaderProgressStarted() when headerProgressStarted != null:
return headerProgressStarted(_that);case SpNotification_HeaderProgress() when headerProgress != null:
return headerProgress(_that);case SpNotification_HeaderProgressCompleted() when headerProgressCompleted != null:
return headerProgressCompleted(_that);case SpNotification_HeaderProgressFailed() when headerProgressFailed != null:
return headerProgressFailed(_that);case SpNotification_PaymentHistoryUpdated() when paymentHistoryUpdated != null:
return paymentHistoryUpdated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int from,  int to)?  scanStarted,TResult Function( int current,  int end)?  scanReceiveProgress,TResult Function()?  scanCompleted,TResult Function()?  scanStopped,TResult Function( String message)?  scanFailed,TResult Function( String outpoint,  BigInt amountSat)?  newOutput,TResult Function( String outpoint)?  outputSpent,TResult Function( String txid)?  broadcasted,TResult Function( String message)?  broadcastFailed,TResult Function()?  backendOffline,TResult Function( CoinSource kind,  String txid,  BigInt amountSat,  int? height)?  electrumTx,TResult Function( int current,  int end)?  scanSpendProgress,TResult Function( HeaderProgressPhase phase,  int start,  int end)?  headerProgressStarted,TResult Function( HeaderProgressPhase phase,  int current,  int end)?  headerProgress,TResult Function( HeaderProgressPhase phase)?  headerProgressCompleted,TResult Function( HeaderProgressPhase phase)?  headerProgressFailed,TResult Function()?  paymentHistoryUpdated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpNotification_ScanStarted() when scanStarted != null:
return scanStarted(_that.from,_that.to);case SpNotification_ScanReceiveProgress() when scanReceiveProgress != null:
return scanReceiveProgress(_that.current,_that.end);case SpNotification_ScanCompleted() when scanCompleted != null:
return scanCompleted();case SpNotification_ScanStopped() when scanStopped != null:
return scanStopped();case SpNotification_ScanFailed() when scanFailed != null:
return scanFailed(_that.message);case SpNotification_NewOutput() when newOutput != null:
return newOutput(_that.outpoint,_that.amountSat);case SpNotification_OutputSpent() when outputSpent != null:
return outputSpent(_that.outpoint);case SpNotification_Broadcasted() when broadcasted != null:
return broadcasted(_that.txid);case SpNotification_BroadcastFailed() when broadcastFailed != null:
return broadcastFailed(_that.message);case SpNotification_BackendOffline() when backendOffline != null:
return backendOffline();case SpNotification_ElectrumTx() when electrumTx != null:
return electrumTx(_that.kind,_that.txid,_that.amountSat,_that.height);case SpNotification_ScanSpendProgress() when scanSpendProgress != null:
return scanSpendProgress(_that.current,_that.end);case SpNotification_HeaderProgressStarted() when headerProgressStarted != null:
return headerProgressStarted(_that.phase,_that.start,_that.end);case SpNotification_HeaderProgress() when headerProgress != null:
return headerProgress(_that.phase,_that.current,_that.end);case SpNotification_HeaderProgressCompleted() when headerProgressCompleted != null:
return headerProgressCompleted(_that.phase);case SpNotification_HeaderProgressFailed() when headerProgressFailed != null:
return headerProgressFailed(_that.phase);case SpNotification_PaymentHistoryUpdated() when paymentHistoryUpdated != null:
return paymentHistoryUpdated();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int from,  int to)  scanStarted,required TResult Function( int current,  int end)  scanReceiveProgress,required TResult Function()  scanCompleted,required TResult Function()  scanStopped,required TResult Function( String message)  scanFailed,required TResult Function( String outpoint,  BigInt amountSat)  newOutput,required TResult Function( String outpoint)  outputSpent,required TResult Function( String txid)  broadcasted,required TResult Function( String message)  broadcastFailed,required TResult Function()  backendOffline,required TResult Function( CoinSource kind,  String txid,  BigInt amountSat,  int? height)  electrumTx,required TResult Function( int current,  int end)  scanSpendProgress,required TResult Function( HeaderProgressPhase phase,  int start,  int end)  headerProgressStarted,required TResult Function( HeaderProgressPhase phase,  int current,  int end)  headerProgress,required TResult Function( HeaderProgressPhase phase)  headerProgressCompleted,required TResult Function( HeaderProgressPhase phase)  headerProgressFailed,required TResult Function()  paymentHistoryUpdated,}) {final _that = this;
switch (_that) {
case SpNotification_ScanStarted():
return scanStarted(_that.from,_that.to);case SpNotification_ScanReceiveProgress():
return scanReceiveProgress(_that.current,_that.end);case SpNotification_ScanCompleted():
return scanCompleted();case SpNotification_ScanStopped():
return scanStopped();case SpNotification_ScanFailed():
return scanFailed(_that.message);case SpNotification_NewOutput():
return newOutput(_that.outpoint,_that.amountSat);case SpNotification_OutputSpent():
return outputSpent(_that.outpoint);case SpNotification_Broadcasted():
return broadcasted(_that.txid);case SpNotification_BroadcastFailed():
return broadcastFailed(_that.message);case SpNotification_BackendOffline():
return backendOffline();case SpNotification_ElectrumTx():
return electrumTx(_that.kind,_that.txid,_that.amountSat,_that.height);case SpNotification_ScanSpendProgress():
return scanSpendProgress(_that.current,_that.end);case SpNotification_HeaderProgressStarted():
return headerProgressStarted(_that.phase,_that.start,_that.end);case SpNotification_HeaderProgress():
return headerProgress(_that.phase,_that.current,_that.end);case SpNotification_HeaderProgressCompleted():
return headerProgressCompleted(_that.phase);case SpNotification_HeaderProgressFailed():
return headerProgressFailed(_that.phase);case SpNotification_PaymentHistoryUpdated():
return paymentHistoryUpdated();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int from,  int to)?  scanStarted,TResult? Function( int current,  int end)?  scanReceiveProgress,TResult? Function()?  scanCompleted,TResult? Function()?  scanStopped,TResult? Function( String message)?  scanFailed,TResult? Function( String outpoint,  BigInt amountSat)?  newOutput,TResult? Function( String outpoint)?  outputSpent,TResult? Function( String txid)?  broadcasted,TResult? Function( String message)?  broadcastFailed,TResult? Function()?  backendOffline,TResult? Function( CoinSource kind,  String txid,  BigInt amountSat,  int? height)?  electrumTx,TResult? Function( int current,  int end)?  scanSpendProgress,TResult? Function( HeaderProgressPhase phase,  int start,  int end)?  headerProgressStarted,TResult? Function( HeaderProgressPhase phase,  int current,  int end)?  headerProgress,TResult? Function( HeaderProgressPhase phase)?  headerProgressCompleted,TResult? Function( HeaderProgressPhase phase)?  headerProgressFailed,TResult? Function()?  paymentHistoryUpdated,}) {final _that = this;
switch (_that) {
case SpNotification_ScanStarted() when scanStarted != null:
return scanStarted(_that.from,_that.to);case SpNotification_ScanReceiveProgress() when scanReceiveProgress != null:
return scanReceiveProgress(_that.current,_that.end);case SpNotification_ScanCompleted() when scanCompleted != null:
return scanCompleted();case SpNotification_ScanStopped() when scanStopped != null:
return scanStopped();case SpNotification_ScanFailed() when scanFailed != null:
return scanFailed(_that.message);case SpNotification_NewOutput() when newOutput != null:
return newOutput(_that.outpoint,_that.amountSat);case SpNotification_OutputSpent() when outputSpent != null:
return outputSpent(_that.outpoint);case SpNotification_Broadcasted() when broadcasted != null:
return broadcasted(_that.txid);case SpNotification_BroadcastFailed() when broadcastFailed != null:
return broadcastFailed(_that.message);case SpNotification_BackendOffline() when backendOffline != null:
return backendOffline();case SpNotification_ElectrumTx() when electrumTx != null:
return electrumTx(_that.kind,_that.txid,_that.amountSat,_that.height);case SpNotification_ScanSpendProgress() when scanSpendProgress != null:
return scanSpendProgress(_that.current,_that.end);case SpNotification_HeaderProgressStarted() when headerProgressStarted != null:
return headerProgressStarted(_that.phase,_that.start,_that.end);case SpNotification_HeaderProgress() when headerProgress != null:
return headerProgress(_that.phase,_that.current,_that.end);case SpNotification_HeaderProgressCompleted() when headerProgressCompleted != null:
return headerProgressCompleted(_that.phase);case SpNotification_HeaderProgressFailed() when headerProgressFailed != null:
return headerProgressFailed(_that.phase);case SpNotification_PaymentHistoryUpdated() when paymentHistoryUpdated != null:
return paymentHistoryUpdated();case _:
  return null;

}
}

}

/// @nodoc


class SpNotification_ScanStarted extends SpNotification {
  const SpNotification_ScanStarted({required this.from, required this.to}): super._();
  

 final  int from;
 final  int to;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_ScanStartedCopyWith<SpNotification_ScanStarted> get copyWith => _$SpNotification_ScanStartedCopyWithImpl<SpNotification_ScanStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ScanStarted&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,from,to);

@override
String toString() {
  return 'SpNotification.scanStarted(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $SpNotification_ScanStartedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_ScanStartedCopyWith(SpNotification_ScanStarted value, $Res Function(SpNotification_ScanStarted) _then) = _$SpNotification_ScanStartedCopyWithImpl;
@useResult
$Res call({
 int from, int to
});




}
/// @nodoc
class _$SpNotification_ScanStartedCopyWithImpl<$Res>
    implements $SpNotification_ScanStartedCopyWith<$Res> {
  _$SpNotification_ScanStartedCopyWithImpl(this._self, this._then);

  final SpNotification_ScanStarted _self;
  final $Res Function(SpNotification_ScanStarted) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(SpNotification_ScanStarted(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as int,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SpNotification_ScanReceiveProgress extends SpNotification {
  const SpNotification_ScanReceiveProgress({required this.current, required this.end}): super._();
  

 final  int current;
 final  int end;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_ScanReceiveProgressCopyWith<SpNotification_ScanReceiveProgress> get copyWith => _$SpNotification_ScanReceiveProgressCopyWithImpl<SpNotification_ScanReceiveProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ScanReceiveProgress&&(identical(other.current, current) || other.current == current)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,current,end);

@override
String toString() {
  return 'SpNotification.scanReceiveProgress(current: $current, end: $end)';
}


}

/// @nodoc
abstract mixin class $SpNotification_ScanReceiveProgressCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_ScanReceiveProgressCopyWith(SpNotification_ScanReceiveProgress value, $Res Function(SpNotification_ScanReceiveProgress) _then) = _$SpNotification_ScanReceiveProgressCopyWithImpl;
@useResult
$Res call({
 int current, int end
});




}
/// @nodoc
class _$SpNotification_ScanReceiveProgressCopyWithImpl<$Res>
    implements $SpNotification_ScanReceiveProgressCopyWith<$Res> {
  _$SpNotification_ScanReceiveProgressCopyWithImpl(this._self, this._then);

  final SpNotification_ScanReceiveProgress _self;
  final $Res Function(SpNotification_ScanReceiveProgress) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? current = null,Object? end = null,}) {
  return _then(SpNotification_ScanReceiveProgress(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SpNotification_ScanCompleted extends SpNotification {
  const SpNotification_ScanCompleted(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ScanCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpNotification.scanCompleted()';
}


}




/// @nodoc


class SpNotification_ScanStopped extends SpNotification {
  const SpNotification_ScanStopped(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ScanStopped);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpNotification.scanStopped()';
}


}




/// @nodoc


class SpNotification_ScanFailed extends SpNotification {
  const SpNotification_ScanFailed({required this.message}): super._();
  

 final  String message;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_ScanFailedCopyWith<SpNotification_ScanFailed> get copyWith => _$SpNotification_ScanFailedCopyWithImpl<SpNotification_ScanFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ScanFailed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SpNotification.scanFailed(message: $message)';
}


}

/// @nodoc
abstract mixin class $SpNotification_ScanFailedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_ScanFailedCopyWith(SpNotification_ScanFailed value, $Res Function(SpNotification_ScanFailed) _then) = _$SpNotification_ScanFailedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SpNotification_ScanFailedCopyWithImpl<$Res>
    implements $SpNotification_ScanFailedCopyWith<$Res> {
  _$SpNotification_ScanFailedCopyWithImpl(this._self, this._then);

  final SpNotification_ScanFailed _self;
  final $Res Function(SpNotification_ScanFailed) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SpNotification_ScanFailed(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpNotification_NewOutput extends SpNotification {
  const SpNotification_NewOutput({required this.outpoint, required this.amountSat}): super._();
  

 final  String outpoint;
 final  BigInt amountSat;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_NewOutputCopyWith<SpNotification_NewOutput> get copyWith => _$SpNotification_NewOutputCopyWithImpl<SpNotification_NewOutput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_NewOutput&&(identical(other.outpoint, outpoint) || other.outpoint == outpoint)&&(identical(other.amountSat, amountSat) || other.amountSat == amountSat));
}


@override
int get hashCode => Object.hash(runtimeType,outpoint,amountSat);

@override
String toString() {
  return 'SpNotification.newOutput(outpoint: $outpoint, amountSat: $amountSat)';
}


}

/// @nodoc
abstract mixin class $SpNotification_NewOutputCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_NewOutputCopyWith(SpNotification_NewOutput value, $Res Function(SpNotification_NewOutput) _then) = _$SpNotification_NewOutputCopyWithImpl;
@useResult
$Res call({
 String outpoint, BigInt amountSat
});




}
/// @nodoc
class _$SpNotification_NewOutputCopyWithImpl<$Res>
    implements $SpNotification_NewOutputCopyWith<$Res> {
  _$SpNotification_NewOutputCopyWithImpl(this._self, this._then);

  final SpNotification_NewOutput _self;
  final $Res Function(SpNotification_NewOutput) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outpoint = null,Object? amountSat = null,}) {
  return _then(SpNotification_NewOutput(
outpoint: null == outpoint ? _self.outpoint : outpoint // ignore: cast_nullable_to_non_nullable
as String,amountSat: null == amountSat ? _self.amountSat : amountSat // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class SpNotification_OutputSpent extends SpNotification {
  const SpNotification_OutputSpent({required this.outpoint}): super._();
  

 final  String outpoint;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_OutputSpentCopyWith<SpNotification_OutputSpent> get copyWith => _$SpNotification_OutputSpentCopyWithImpl<SpNotification_OutputSpent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_OutputSpent&&(identical(other.outpoint, outpoint) || other.outpoint == outpoint));
}


@override
int get hashCode => Object.hash(runtimeType,outpoint);

@override
String toString() {
  return 'SpNotification.outputSpent(outpoint: $outpoint)';
}


}

/// @nodoc
abstract mixin class $SpNotification_OutputSpentCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_OutputSpentCopyWith(SpNotification_OutputSpent value, $Res Function(SpNotification_OutputSpent) _then) = _$SpNotification_OutputSpentCopyWithImpl;
@useResult
$Res call({
 String outpoint
});




}
/// @nodoc
class _$SpNotification_OutputSpentCopyWithImpl<$Res>
    implements $SpNotification_OutputSpentCopyWith<$Res> {
  _$SpNotification_OutputSpentCopyWithImpl(this._self, this._then);

  final SpNotification_OutputSpent _self;
  final $Res Function(SpNotification_OutputSpent) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outpoint = null,}) {
  return _then(SpNotification_OutputSpent(
outpoint: null == outpoint ? _self.outpoint : outpoint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpNotification_Broadcasted extends SpNotification {
  const SpNotification_Broadcasted({required this.txid}): super._();
  

 final  String txid;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_BroadcastedCopyWith<SpNotification_Broadcasted> get copyWith => _$SpNotification_BroadcastedCopyWithImpl<SpNotification_Broadcasted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_Broadcasted&&(identical(other.txid, txid) || other.txid == txid));
}


@override
int get hashCode => Object.hash(runtimeType,txid);

@override
String toString() {
  return 'SpNotification.broadcasted(txid: $txid)';
}


}

/// @nodoc
abstract mixin class $SpNotification_BroadcastedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_BroadcastedCopyWith(SpNotification_Broadcasted value, $Res Function(SpNotification_Broadcasted) _then) = _$SpNotification_BroadcastedCopyWithImpl;
@useResult
$Res call({
 String txid
});




}
/// @nodoc
class _$SpNotification_BroadcastedCopyWithImpl<$Res>
    implements $SpNotification_BroadcastedCopyWith<$Res> {
  _$SpNotification_BroadcastedCopyWithImpl(this._self, this._then);

  final SpNotification_Broadcasted _self;
  final $Res Function(SpNotification_Broadcasted) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? txid = null,}) {
  return _then(SpNotification_Broadcasted(
txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpNotification_BroadcastFailed extends SpNotification {
  const SpNotification_BroadcastFailed({required this.message}): super._();
  

 final  String message;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_BroadcastFailedCopyWith<SpNotification_BroadcastFailed> get copyWith => _$SpNotification_BroadcastFailedCopyWithImpl<SpNotification_BroadcastFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_BroadcastFailed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SpNotification.broadcastFailed(message: $message)';
}


}

/// @nodoc
abstract mixin class $SpNotification_BroadcastFailedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_BroadcastFailedCopyWith(SpNotification_BroadcastFailed value, $Res Function(SpNotification_BroadcastFailed) _then) = _$SpNotification_BroadcastFailedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SpNotification_BroadcastFailedCopyWithImpl<$Res>
    implements $SpNotification_BroadcastFailedCopyWith<$Res> {
  _$SpNotification_BroadcastFailedCopyWithImpl(this._self, this._then);

  final SpNotification_BroadcastFailed _self;
  final $Res Function(SpNotification_BroadcastFailed) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SpNotification_BroadcastFailed(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpNotification_BackendOffline extends SpNotification {
  const SpNotification_BackendOffline(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_BackendOffline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpNotification.backendOffline()';
}


}




/// @nodoc


class SpNotification_ElectrumTx extends SpNotification {
  const SpNotification_ElectrumTx({required this.kind, required this.txid, required this.amountSat, this.height}): super._();
  

 final  CoinSource kind;
 final  String txid;
 final  BigInt amountSat;
 final  int? height;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_ElectrumTxCopyWith<SpNotification_ElectrumTx> get copyWith => _$SpNotification_ElectrumTxCopyWithImpl<SpNotification_ElectrumTx>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ElectrumTx&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.txid, txid) || other.txid == txid)&&(identical(other.amountSat, amountSat) || other.amountSat == amountSat)&&(identical(other.height, height) || other.height == height));
}


@override
int get hashCode => Object.hash(runtimeType,kind,txid,amountSat,height);

@override
String toString() {
  return 'SpNotification.electrumTx(kind: $kind, txid: $txid, amountSat: $amountSat, height: $height)';
}


}

/// @nodoc
abstract mixin class $SpNotification_ElectrumTxCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_ElectrumTxCopyWith(SpNotification_ElectrumTx value, $Res Function(SpNotification_ElectrumTx) _then) = _$SpNotification_ElectrumTxCopyWithImpl;
@useResult
$Res call({
 CoinSource kind, String txid, BigInt amountSat, int? height
});




}
/// @nodoc
class _$SpNotification_ElectrumTxCopyWithImpl<$Res>
    implements $SpNotification_ElectrumTxCopyWith<$Res> {
  _$SpNotification_ElectrumTxCopyWithImpl(this._self, this._then);

  final SpNotification_ElectrumTx _self;
  final $Res Function(SpNotification_ElectrumTx) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? txid = null,Object? amountSat = null,Object? height = freezed,}) {
  return _then(SpNotification_ElectrumTx(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CoinSource,txid: null == txid ? _self.txid : txid // ignore: cast_nullable_to_non_nullable
as String,amountSat: null == amountSat ? _self.amountSat : amountSat // ignore: cast_nullable_to_non_nullable
as BigInt,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class SpNotification_ScanSpendProgress extends SpNotification {
  const SpNotification_ScanSpendProgress({required this.current, required this.end}): super._();
  

 final  int current;
 final  int end;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_ScanSpendProgressCopyWith<SpNotification_ScanSpendProgress> get copyWith => _$SpNotification_ScanSpendProgressCopyWithImpl<SpNotification_ScanSpendProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_ScanSpendProgress&&(identical(other.current, current) || other.current == current)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,current,end);

@override
String toString() {
  return 'SpNotification.scanSpendProgress(current: $current, end: $end)';
}


}

/// @nodoc
abstract mixin class $SpNotification_ScanSpendProgressCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_ScanSpendProgressCopyWith(SpNotification_ScanSpendProgress value, $Res Function(SpNotification_ScanSpendProgress) _then) = _$SpNotification_ScanSpendProgressCopyWithImpl;
@useResult
$Res call({
 int current, int end
});




}
/// @nodoc
class _$SpNotification_ScanSpendProgressCopyWithImpl<$Res>
    implements $SpNotification_ScanSpendProgressCopyWith<$Res> {
  _$SpNotification_ScanSpendProgressCopyWithImpl(this._self, this._then);

  final SpNotification_ScanSpendProgress _self;
  final $Res Function(SpNotification_ScanSpendProgress) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? current = null,Object? end = null,}) {
  return _then(SpNotification_ScanSpendProgress(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SpNotification_HeaderProgressStarted extends SpNotification {
  const SpNotification_HeaderProgressStarted({required this.phase, required this.start, required this.end}): super._();
  

 final  HeaderProgressPhase phase;
 final  int start;
 final  int end;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_HeaderProgressStartedCopyWith<SpNotification_HeaderProgressStarted> get copyWith => _$SpNotification_HeaderProgressStartedCopyWithImpl<SpNotification_HeaderProgressStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_HeaderProgressStarted&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,phase,start,end);

@override
String toString() {
  return 'SpNotification.headerProgressStarted(phase: $phase, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $SpNotification_HeaderProgressStartedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_HeaderProgressStartedCopyWith(SpNotification_HeaderProgressStarted value, $Res Function(SpNotification_HeaderProgressStarted) _then) = _$SpNotification_HeaderProgressStartedCopyWithImpl;
@useResult
$Res call({
 HeaderProgressPhase phase, int start, int end
});




}
/// @nodoc
class _$SpNotification_HeaderProgressStartedCopyWithImpl<$Res>
    implements $SpNotification_HeaderProgressStartedCopyWith<$Res> {
  _$SpNotification_HeaderProgressStartedCopyWithImpl(this._self, this._then);

  final SpNotification_HeaderProgressStarted _self;
  final $Res Function(SpNotification_HeaderProgressStarted) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? start = null,Object? end = null,}) {
  return _then(SpNotification_HeaderProgressStarted(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as HeaderProgressPhase,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SpNotification_HeaderProgress extends SpNotification {
  const SpNotification_HeaderProgress({required this.phase, required this.current, required this.end}): super._();
  

 final  HeaderProgressPhase phase;
 final  int current;
 final  int end;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_HeaderProgressCopyWith<SpNotification_HeaderProgress> get copyWith => _$SpNotification_HeaderProgressCopyWithImpl<SpNotification_HeaderProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_HeaderProgress&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.current, current) || other.current == current)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,phase,current,end);

@override
String toString() {
  return 'SpNotification.headerProgress(phase: $phase, current: $current, end: $end)';
}


}

/// @nodoc
abstract mixin class $SpNotification_HeaderProgressCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_HeaderProgressCopyWith(SpNotification_HeaderProgress value, $Res Function(SpNotification_HeaderProgress) _then) = _$SpNotification_HeaderProgressCopyWithImpl;
@useResult
$Res call({
 HeaderProgressPhase phase, int current, int end
});




}
/// @nodoc
class _$SpNotification_HeaderProgressCopyWithImpl<$Res>
    implements $SpNotification_HeaderProgressCopyWith<$Res> {
  _$SpNotification_HeaderProgressCopyWithImpl(this._self, this._then);

  final SpNotification_HeaderProgress _self;
  final $Res Function(SpNotification_HeaderProgress) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? current = null,Object? end = null,}) {
  return _then(SpNotification_HeaderProgress(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as HeaderProgressPhase,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SpNotification_HeaderProgressCompleted extends SpNotification {
  const SpNotification_HeaderProgressCompleted({required this.phase}): super._();
  

 final  HeaderProgressPhase phase;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_HeaderProgressCompletedCopyWith<SpNotification_HeaderProgressCompleted> get copyWith => _$SpNotification_HeaderProgressCompletedCopyWithImpl<SpNotification_HeaderProgressCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_HeaderProgressCompleted&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode => Object.hash(runtimeType,phase);

@override
String toString() {
  return 'SpNotification.headerProgressCompleted(phase: $phase)';
}


}

/// @nodoc
abstract mixin class $SpNotification_HeaderProgressCompletedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_HeaderProgressCompletedCopyWith(SpNotification_HeaderProgressCompleted value, $Res Function(SpNotification_HeaderProgressCompleted) _then) = _$SpNotification_HeaderProgressCompletedCopyWithImpl;
@useResult
$Res call({
 HeaderProgressPhase phase
});




}
/// @nodoc
class _$SpNotification_HeaderProgressCompletedCopyWithImpl<$Res>
    implements $SpNotification_HeaderProgressCompletedCopyWith<$Res> {
  _$SpNotification_HeaderProgressCompletedCopyWithImpl(this._self, this._then);

  final SpNotification_HeaderProgressCompleted _self;
  final $Res Function(SpNotification_HeaderProgressCompleted) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,}) {
  return _then(SpNotification_HeaderProgressCompleted(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as HeaderProgressPhase,
  ));
}


}

/// @nodoc


class SpNotification_HeaderProgressFailed extends SpNotification {
  const SpNotification_HeaderProgressFailed({required this.phase}): super._();
  

 final  HeaderProgressPhase phase;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpNotification_HeaderProgressFailedCopyWith<SpNotification_HeaderProgressFailed> get copyWith => _$SpNotification_HeaderProgressFailedCopyWithImpl<SpNotification_HeaderProgressFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_HeaderProgressFailed&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode => Object.hash(runtimeType,phase);

@override
String toString() {
  return 'SpNotification.headerProgressFailed(phase: $phase)';
}


}

/// @nodoc
abstract mixin class $SpNotification_HeaderProgressFailedCopyWith<$Res> implements $SpNotificationCopyWith<$Res> {
  factory $SpNotification_HeaderProgressFailedCopyWith(SpNotification_HeaderProgressFailed value, $Res Function(SpNotification_HeaderProgressFailed) _then) = _$SpNotification_HeaderProgressFailedCopyWithImpl;
@useResult
$Res call({
 HeaderProgressPhase phase
});




}
/// @nodoc
class _$SpNotification_HeaderProgressFailedCopyWithImpl<$Res>
    implements $SpNotification_HeaderProgressFailedCopyWith<$Res> {
  _$SpNotification_HeaderProgressFailedCopyWithImpl(this._self, this._then);

  final SpNotification_HeaderProgressFailed _self;
  final $Res Function(SpNotification_HeaderProgressFailed) _then;

/// Create a copy of SpNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,}) {
  return _then(SpNotification_HeaderProgressFailed(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as HeaderProgressPhase,
  ));
}


}

/// @nodoc


class SpNotification_PaymentHistoryUpdated extends SpNotification {
  const SpNotification_PaymentHistoryUpdated(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpNotification_PaymentHistoryUpdated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpNotification.paymentHistoryUpdated()';
}


}




/// @nodoc
mixin _$TxFee {

 Object get field0;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxFee&&const DeepCollectionEquality().equals(other.field0, field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(field0));

@override
String toString() {
  return 'TxFee(field0: $field0)';
}


}

/// @nodoc
class $TxFeeCopyWith<$Res>  {
$TxFeeCopyWith(TxFee _, $Res Function(TxFee) __);
}


/// Adds pattern-matching-related methods to [TxFee].
extension TxFeePatterns on TxFee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TxFee_Absolute value)?  absolute,TResult Function( TxFee_Relative value)?  relative,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TxFee_Absolute() when absolute != null:
return absolute(_that);case TxFee_Relative() when relative != null:
return relative(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TxFee_Absolute value)  absolute,required TResult Function( TxFee_Relative value)  relative,}){
final _that = this;
switch (_that) {
case TxFee_Absolute():
return absolute(_that);case TxFee_Relative():
return relative(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TxFee_Absolute value)?  absolute,TResult? Function( TxFee_Relative value)?  relative,}){
final _that = this;
switch (_that) {
case TxFee_Absolute() when absolute != null:
return absolute(_that);case TxFee_Relative() when relative != null:
return relative(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BigInt field0)?  absolute,TResult Function( double field0)?  relative,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TxFee_Absolute() when absolute != null:
return absolute(_that.field0);case TxFee_Relative() when relative != null:
return relative(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BigInt field0)  absolute,required TResult Function( double field0)  relative,}) {final _that = this;
switch (_that) {
case TxFee_Absolute():
return absolute(_that.field0);case TxFee_Relative():
return relative(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BigInt field0)?  absolute,TResult? Function( double field0)?  relative,}) {final _that = this;
switch (_that) {
case TxFee_Absolute() when absolute != null:
return absolute(_that.field0);case TxFee_Relative() when relative != null:
return relative(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class TxFee_Absolute extends TxFee {
  const TxFee_Absolute(this.field0): super._();
  

@override final  BigInt field0;

/// Create a copy of TxFee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxFee_AbsoluteCopyWith<TxFee_Absolute> get copyWith => _$TxFee_AbsoluteCopyWithImpl<TxFee_Absolute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxFee_Absolute&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'TxFee.absolute(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $TxFee_AbsoluteCopyWith<$Res> implements $TxFeeCopyWith<$Res> {
  factory $TxFee_AbsoluteCopyWith(TxFee_Absolute value, $Res Function(TxFee_Absolute) _then) = _$TxFee_AbsoluteCopyWithImpl;
@useResult
$Res call({
 BigInt field0
});




}
/// @nodoc
class _$TxFee_AbsoluteCopyWithImpl<$Res>
    implements $TxFee_AbsoluteCopyWith<$Res> {
  _$TxFee_AbsoluteCopyWithImpl(this._self, this._then);

  final TxFee_Absolute _self;
  final $Res Function(TxFee_Absolute) _then;

/// Create a copy of TxFee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(TxFee_Absolute(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class TxFee_Relative extends TxFee {
  const TxFee_Relative(this.field0): super._();
  

@override final  double field0;

/// Create a copy of TxFee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxFee_RelativeCopyWith<TxFee_Relative> get copyWith => _$TxFee_RelativeCopyWithImpl<TxFee_Relative>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxFee_Relative&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'TxFee.relative(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $TxFee_RelativeCopyWith<$Res> implements $TxFeeCopyWith<$Res> {
  factory $TxFee_RelativeCopyWith(TxFee_Relative value, $Res Function(TxFee_Relative) _then) = _$TxFee_RelativeCopyWithImpl;
@useResult
$Res call({
 double field0
});




}
/// @nodoc
class _$TxFee_RelativeCopyWithImpl<$Res>
    implements $TxFee_RelativeCopyWith<$Res> {
  _$TxFee_RelativeCopyWithImpl(this._self, this._then);

  final TxFee_Relative _self;
  final $Res Function(TxFee_Relative) _then;

/// Create a copy of TxFee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(TxFee_Relative(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

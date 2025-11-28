// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      name: json['name'] as String,
      email: json['email'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      workingDaysPerMonth: (json['workingDaysPerMonth'] as num?)?.toInt() ?? 22,
      workingHoursPerDay: (json['workingHoursPerDay'] as num?)?.toInt() ?? 8,
      profilePicPath: json['profilePicPath'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'categories': instance.categories,
      'workingDaysPerMonth': instance.workingDaysPerMonth,
      'workingHoursPerDay': instance.workingHoursPerDay,
      'profilePicPath': instance.profilePicPath,
      'phoneNumber': instance.phoneNumber,
    };

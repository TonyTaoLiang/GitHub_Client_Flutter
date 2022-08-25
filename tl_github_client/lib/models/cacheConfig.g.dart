// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cacheConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheConfig _$CacheConfigFromJson(Map<String, dynamic> json) => CacheConfig()
  ..enable = json['enable'] ?? false // as bool
  ..maxAge = json['maxAge'] ?? 0 // as num
  ..maxCount = json['maxCount'] ?? 0; // as num;

Map<String, dynamic> _$CacheConfigToJson(CacheConfig instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'maxAge': instance.maxAge,
      'maxCount': instance.maxCount,
    };

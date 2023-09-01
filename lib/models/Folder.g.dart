// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Folder _$FolderFromJson(Map<String, dynamic> json) => Folder(
      id: json['id'] as int?,
      createTime: json['create_time'] == null
          ? null
          : DateTime.parse(json['create_time'] as String),
      updateTime: json['update_time'] == null
          ? null
          : DateTime.parse(json['update_time'] as String),
      name: json['name'] as String?,
      type: $enumDecodeNullable(_$FolderTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$FolderToJson(Folder instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('create_time', instance.createTime?.toIso8601String());
  writeNotNull('update_time', instance.updateTime?.toIso8601String());
  writeNotNull('name', instance.name);
  writeNotNull('type', _$FolderTypeEnumMap[instance.type]);
  return val;
}

const _$FolderTypeEnumMap = {
  FolderType.DEFAULT: 1,
  FolderType.DELETE: 2,
  FolderType.CUSTOMIZE: 3,
};

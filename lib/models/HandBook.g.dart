// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HandBook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandBook _$HandBookFromJson(Map<String, dynamic> json) => HandBook(
      id: json['id'] as int?,
      createTime: json['create_time'] == null
          ? null
          : DateTime.parse(json['create_time'] as String),
      updateTime: json['update_time'] == null
          ? null
          : DateTime.parse(json['update_time'] as String),
      title: json['title'] as String?,
      content: json['content'] as String?,
      alarmTime: json['alarm_time'] == null
          ? null
          : DateTime.parse(json['alarm_time'] as String),
      folderId: json['folder_id'] as int?,
    )
      ..deleteTime = json['delete_time'] == null
          ? null
          : DateTime.parse(json['delete_time'] as String)
      ..folder = json['folder'] == null
          ? null
          : Folder.fromJson(json['folder'] as Map<String, dynamic>);

Map<String, dynamic> _$HandBookToJson(HandBook instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('create_time', instance.createTime?.toIso8601String());
  writeNotNull('update_time', instance.updateTime?.toIso8601String());
  writeNotNull('title', instance.title);
  writeNotNull('content', instance.content);
  writeNotNull('alarm_time', instance.alarmTime?.toIso8601String());
  writeNotNull('delete_time', instance.deleteTime?.toIso8601String());
  writeNotNull('folder_id', instance.folderId);
  writeNotNull('folder', instance.folder);
  return val;
}

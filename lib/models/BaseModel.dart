import 'package:json_annotation/json_annotation.dart';

part "BaseModel.g.dart";

@JsonSerializable(includeIfNull: false)
class BaseModel {
  // static String columnId = "id";
  // static String columnCreateTime = "create_time";
  // static String columnUpdateTime = "update_time";

  @JsonKey(name: 'id', )
  int? id;

  @JsonKey(name: 'create_time', )
  DateTime? createTime;

  @JsonKey(name: 'update_time', )
  DateTime? updateTime;

  BaseModel({this.id, this.createTime, this.updateTime});
}

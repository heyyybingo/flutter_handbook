import 'package:flutter/material.dart';
import 'package:flutter_handbook/utils/db.dart';
import 'package:flutter_handbook/models/BaseModel.dart';
import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/utils/logger.dart';
import 'package:flutter_handbook/utils/notification.dart';
import 'package:json_annotation/json_annotation.dart';
part 'HandBook.g.dart';

enum HandBookType {
  @JsonValue(1)
  DEFAULT,
}

@JsonSerializable(includeIfNull: false)
class HandBook extends BaseModel {
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "content")
  String? content;
  @JsonKey(
    name: "alarm_time",
  )
  DateTime? alarmTime;
  @JsonKey(name: "delete_time")
  DateTime? deleteTime;
  @JsonKey(name: "folder_id")
  int? folderId;

  @JsonKey(name: "folder", includeIfNull: false)
  Folder? folder;

  HandBook(
      {super.id,
      super.createTime,
      super.updateTime,
      this.title,
      this.content,
      this.alarmTime,
      this.folderId});
  HandBook copyNewHandBook() {
    return HandBook(
        id: id,
        createTime: createTime,
        updateTime: DateTime.now(), // only give a new updateTime
        title: title,
        content: content,
        alarmTime: alarmTime,
        folderId: folderId);
  }

  toJson() => _$HandBookToJson(this);
  static HandBook fromJson(json) => _$HandBookFromJson(json);
}

class HandBookSerivce {
  static String table = "handbook";
  
  static Future<HandBook?> findHandBookById(int id) async {
    final db = await databaseHelper.database;
    final jsonMapList = await db.query(table, where: "id = ?", whereArgs: [id]);

    final handbooks = jsonMapList.map((e) => HandBook.fromJson(e)).toList();
    final handbook = handbooks[0];
    if (handbook != null) {
      final folder =
          await FolderService.findFolderById(handbook.folderId as int);
      handbook.folder = folder;
    }
    return handbook;
  }

  static Future<void> deleteHandBookById(int id) async {
    final db = await databaseHelper.database;
    await db.delete(table, where: "id = ?", whereArgs: [id]);
    await NotificationService().cancelNotification(id: id);
  }

  static Future<List<HandBook>> findHandBookByFolderIdOrderByUpdateTime(
      int folderId) async {
    final db = await databaseHelper.database;
    final jsonMapList = await db.query(table,
        where: "folder_id = ?",
        whereArgs: [folderId],
        orderBy: "update_time desc");

    final handbooks = jsonMapList.map((e) => HandBook.fromJson(e)).toList();

    return handbooks;
  }

  static Future<List<HandBook>> findHandBooksOrderByUpdateTime(
      {int? limit, int? offset}) async {
    final db = await databaseHelper.database;
    final jsonMapList = await db.query(table,
        limit: limit, offset: offset, orderBy: "update_time desc");

    final handbooks = jsonMapList.map((e) => HandBook.fromJson(e)).toList();

    return handbooks;
  }

  static Future<int> insertHandBook(HandBook handBook) async {
    final db = await databaseHelper.database;
    final id = await db.insert(table, handBook.copyNewHandBook().toJson());

    return id;
  }

  static Future<int> updateHandBook(HandBook handBook) async {
    final db = await databaseHelper.database;
    final id = await db.update(table, handBook.copyNewHandBook().toJson(),
        where: "id = ?", whereArgs: [handBook.id]);
    await scheduleHandBookAlarmById(id);
    return id;
  }

  static Future<int> clearHandBookAlarmById(int id) async {
    final db = await databaseHelper.database;
    return await db.update(table, {"alarm_time": null},
        where: "id = ?", whereArgs: [id]);
  }

  static Future<void> scheduleHandBookAlarmById(int id) async {
  

    final handBook = await findHandBookById(id);
    if(handBook==null){
      return;
    }
   
    if (handBook?.alarmTime != null) {
      NotificationService().scheduleNotification(
          id: id,
          title: handBook!.title!,
          body: handBook.folder?.name ?? "",
          notifyTime: handBook.alarmTime!,
          payload: NotificationPayload(type: NotificationType.handbook,value: handBook)
          );
    } else {
      NotificationService().cancelNotification(id: id);
    }
  }

  static Future<List<HandBook>> findFolderByTitleOrContent(String text) async {
    final db = await databaseHelper.database;
    final jsonMapList = await db.query(table,
        where: "title LIKE ? OR content LIKE ?",
        whereArgs: ['%$text%', '%$text%']);

    final handbooks = jsonMapList.map((e) => HandBook.fromJson(e)).toList();

    return handbooks;
  }
}

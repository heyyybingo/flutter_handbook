import 'package:flutter/material.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/utils/db.dart';
import 'package:flutter_handbook/models/BaseModel.dart';
import 'package:flutter_handbook/utils/logger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Folder.g.dart';

enum FolderType {
  @JsonValue(1)
  DEFAULT,
  @JsonValue(2)
  DELETE,
  @JsonValue(3)
  CUSTOMIZE,
}

@JsonSerializable(includeIfNull: false)
class Folder extends BaseModel {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "type")
  FolderType? type;

  get icon {
    switch (type) {
      case FolderType.DEFAULT:
        return Icons.book_outlined;

      case FolderType.DELETE:
        return Icons.delete_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Folder(
      {super.id,
      super.createTime,
      super.updateTime,
      required this.name,
      required this.type});

  toJson() => _$FolderToJson(this);
  static Folder fromJson(json) => _$FolderFromJson(json);

  Folder copyWith() {
    return Folder(
        id: id,
        createTime: createTime,
        updateTime: updateTime,
        name: name,
        type: type);
  }
}

class FolderService {
  static String table = "folder";

  static Future<Folder> findFolderById(int id) async {
    final db = await databaseHelper.database;
    final jsonMapList = await db.query(table, where: "id = ?", whereArgs: [id]);

    final folders = jsonMapList.map((e) => Folder.fromJson(e)).toList();

    return folders[0];
  }

  static Future<List<Folder>> findFolders({int? limit, int? offset}) async {
    final db = await databaseHelper.database;
    final jsonMapList = await db.query(table, limit: limit, offset: offset);

    final folders = jsonMapList.map((e) => Folder.fromJson(e)).toList();

    return folders;
  }

  static Future<List<Folder>> findFolderByName(String name) async {
    final db = await databaseHelper.database;
    final jsonMapList =
        await db.query(table, where: "name LIKE ?", whereArgs: ['%$name%']);

    final folders = jsonMapList.map((e) => Folder.fromJson(e)).toList();

    return folders;
  }

  static Future<int> insertCustomizeFolderByName(String name) async {
    final db = await databaseHelper.database;
    final id = await db.insert(
        table, Folder(name: name, type: FolderType.CUSTOMIZE).toJson());
    return id;
  }

  static Future<int> updateCustomizeFolder(Folder folder) async {
    final oldFolder = await findFolderById(folder.id!);
    if (oldFolder.type != FolderType.CUSTOMIZE) {
      throw Exception('不能修改内置目录');
    }
    final db = await databaseHelper.database;
    final id = await db.update(table, folder.toJson(),
        where: "id = ?", whereArgs: [folder.id]);
    return id;
  }

  static Future<int> deleteFolderById(int folderId) async {
    final oldFolder = await findFolderById(folderId);
    if (oldFolder.type != FolderType.CUSTOMIZE) {
      throw Exception('不能修改内置目录');
    }
    final db = await databaseHelper.database;
    final handbooksInFolder =
        await HandBookSerivce.findHandBookByFolderIdOrderByUpdateTime(folderId);
    if (handbooksInFolder.isNotEmpty) {
      throw Exception('目录中存在文件，请先清除文件后删除');
    }
    final id = await db.delete(table, where: "id = ?", whereArgs: [folderId]);
    return id;
  }
}

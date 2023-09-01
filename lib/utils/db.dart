import 'package:flutter_handbook/models/Folder.dart';
import 'package:flutter_handbook/models/HandBook.dart';
import 'package:flutter_handbook/utils/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database as Database;
    }
    _database = await _initDatabase();

    return _database as Database;
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String databaseName = 'handbook.db';

    String path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        logger.i("openDatabase creating");

        final batch = db.batch();

        batch.execute(
            'CREATE TABLE IF NOT EXISTS `folder` (`create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,`update_time` TIMESTAMP NULL,`id` INTEGER PRIMARY KEY AUTOINCREMENT,`name` VARCHAR(45) NOT NULL,`type` INTEGER NULL DEFAULT 1)');
        batch.execute('''
          CREATE TABLE IF NOT EXISTS `handbook` (
              `create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
              `update_time` TIMESTAMP NULL,
              `id` INTEGER PRIMARY KEY AUTOINCREMENT,
              `title` VARCHAR(45) NOT NULL,
              `type` INTEGER NULL DEFAULT 1,
              `folder_id` INTEGER NOT NULL,
              `content` TEXT NULL,
              `alarm_time` TIMESTAMP NULL,
              `delete_time` TIMESTAMP NULL, 
              FOREIGN KEY (`folder_id`) REFERENCES `folder` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
          )
      ''');

        final Folder defaultFolder =
            Folder(name: "备忘录", type: FolderType.DEFAULT);
        final Folder deleteFolder =
            Folder(name: "最近删除", type: FolderType.DELETE);
        batch.insert('folder', defaultFolder.toJson());
        batch.insert('folder', deleteFolder.toJson());

        final result = await batch.commit(exclusive: false);
        logger.i("openDatabase create success $result");
        final defaultFolderId = result[4] as int;
        final HandBook defaultHandBook = HandBook(
            title: "测试title", content: "介绍内容", folderId: defaultFolderId);
        await db.insert('handbook', defaultHandBook.toJson());

        logger.i("openDatabase insert default handbooks success");
      },
      // onUpgrade: (db, oldVersion, newVersion) {
      //   if (oldVersion < newVersion) {
      //     db.execute('ALTER TABLE table_name ADD COLUMN column3 TEXT');
      //   }
      // },
    );
  }
}

DatabaseHelper databaseHelper = DatabaseHelper();

import 'package:easy_localization/easy_localization.dart';
import 'package:fs_front/Core/Vars/enums.dart';
import 'package:fs_front/Core/Vars/globals.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'local_db_names.dart';

class LocalDB {
  static const String dbName = "fsf.db";
  static const int dbVersion = 5;

  LocalDB._();

  static final LocalDB db = LocalDB._();

  static Database? _database;

  Future<Database?> get database async {
    if (!isMobileDevice) return null;

    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String dbDirectory = await getDatabasesPath();
    String path = join(dbDirectory, dbName);
    return await openDatabase(path, version: dbVersion,

        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON'); //to allow secondary keys
        },

        onOpen: (db) {},

        onUpgrade: (db, int oldVersion, int newVersion) async {
          //deal with migration
          for (var i = oldVersion; i < newVersion; i++) {
            switch (i) {
              case 1: //this is very old DB V1 fro Android only for the App V<=2.0, no DB upgrade is available
                await deleteDatabase(path);
                await createDB5(db);
                i = newVersion;
                break;
              case 2:
                await updateDB2toDB3(db);
                break;
              case 3:
                await updateDB3toDB4(db);
                break;
              case 4:
                await updateDB4toDB5(db);
                break;
            }
          }
        },

        onCreate:
        //create Database if it does not exist
            (Database db, int version) async {
          await createDB5(db);
        }
    );
  }

  Future createDB5(Database db) async {
    //pre-process the script removing \n and # characters, creating tables one by one
    createDBv5Script.replaceAll("\n", "").split("#").forEach((cmd) async {
      await db.execute(cmd);
    });

    //insert root folder into Notes table with Id = -1
    db.rawInsert(
        "INSERT Into $Notes_Tbl ($NOTE_ID, $NOTE_TYPE, $LASTM, $NOTE_SUBFLDR, $NOTE_NAME, $DELETED)"
            " VALUES (?,?,datetime('now'),?,?,?)",
        [rootFolder, NoteType.folder.index, -1, rootFolderName.tr(), false]);
  }

  Future updateDB4toDB5(Database db) async {
    //TODO: to implement
    throw UnimplementedError;
  }

  Future updateDB3toDB4(Database db) async {
    //TODO: to implement
    throw UnimplementedError;
  }

  Future updateDB2toDB3(Database db) async {
    //TODO: to implement
    throw UnimplementedError;
  }

  redoDB(String script) async {
    final db = await database;

    if (db == null) return;

    var batch = db.batch();
    //preprocess the script removing \n and # characters, creating tables one by one
    script.replaceAll("\n", "").split("#").forEach((cmd) {
      batch.execute(cmd);
    });
    await batch.commit();
  }

}
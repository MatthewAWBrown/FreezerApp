import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  static const inven='inven';

  static Future<Database>database()async{

    final dbPath = await getDatabasesPath();

    return await openDatabase(

      join(dbPath, 'inven.db'),
      onCreate: (db, version) {
        db.execute("CREATE TABLE IF NOT EXISTS $inven(id TEXT PRIMARY KEY ,"
          " title TEXT,"
          " count INTEGER CHECK(count >= 0), "
          " date TEXT)");
      },

      version: 1,
    );
  }

  static Future<List<Map<String, dynamic>>>selectAll(String table)async{

    final db=await DBHelper.database();

    return db.query(table);
  }

  static Future<List<Map<String, dynamic>>>search(String table, String searchText) async {
    final db = await DBHelper.database();

    return db.query(table, where: 'title LIKE ?', whereArgs: ['%$searchText%']);
  }

  static Future insert(String table, Map<String, Object>data) async {

    final db = await DBHelper.database();

    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future update(
    String tableName,
    String columnName,
    String value,
    String id
  ) async {

    final db = await DBHelper.database();

    return db.update(
      tableName,
      {columnName:value},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  static Future deleteById(
      String tableName,
      String columnName,
      String id
      ) async {

    final db = await DBHelper.database();

    return db.delete(
      tableName,
      where: '$columnName = ?',
      whereArgs: [id],
    );
  }

  static Future deleteTable(String tableName) async {

    final db = await DBHelper.database();

    return db.rawQuery('DELETE FROM $tableName');

  }


}
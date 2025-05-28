import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _databaseName = 'inven.db';
  static const int _databaseVersion = 1;

  static const String tableInventory = 'inven';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnCount = 'count';
  static const String columnDate = 'date';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // This opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableInventory (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT,
        $columnCount INTEGER CHECK($columnCount >= 0),
        $columnDate TEXT
      )
    ''');
  }

  // --- Helper Methods ---
  Future<List<Map<String, dynamic>>> selectAll() async {
    final db = await instance.database;
    return db.query(tableInventory);
  }

  Future<List<Map<String, dynamic>>> search(String searchText) async {
    final db = await instance.database;
    return db.query(
      tableInventory,
      where: '$columnTitle LIKE ?',
      whereArgs: ['%$searchText%'],
    );
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await instance.database;
    return db.insert(
      tableInventory,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(String id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return db.update(
      tableInventory,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  // optional update a single column:
  Future<int> updateSingleColumn(String id, String columnName, dynamic value) async {
    final db = await instance.database;
    return db.update(
      tableInventory,
      {columnName: value},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteById(String id) async {
    final db = await instance.database;
    return db.delete(
      tableInventory,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTable() async {
    final db = await instance.database;
    return db.delete(tableInventory);
  }
}
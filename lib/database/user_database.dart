
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_database/model/user.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;
  static String userTable = '_userTable';

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const nameType = 'TEXT';
    const ageType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $userTable(
    ${UserFields.id} $idType,
    ${UserFields.name} $nameType,
    ${UserFields.age} $ageType
    )
    ''');
  }

  Future create(User user) async {
    final db = await instance.database;
    await db.insert(userTable, user.toJson());
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;

    final result = await db.query(userTable, columns: UserFields.values);
    return result.map((json) => User.fromJson(json)).toList();
  }

  Future deleteUser(int id) async {
    final db = await instance.database;
    await db.delete(userTable,where: '${UserFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
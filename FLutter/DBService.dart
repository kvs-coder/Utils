class DBService {
  static const int _version = 1000;
  static const String _databaseName = 'YOUR_DB_NAME';

  @required
  final String caller;

  const DBService({this.caller});
  
    Future<int> saveCore(int id, String userName) async {
    final Core core = Core(id, 'unknown');
    final int object = await _insertCore(core);
    return object;
  }
  
    Future<int> deleteCore(Core core) async {
    final int object = await _delete(CoreTable.name,
        where: '${CoreTableColumns.id} = ?', whereArgs: [core.id]);
    return object;
  }
  
  Future<Database> _database() async =>
      openDatabase(join(await getDatabasesPath(), _databaseName),
          onCreate: _create, version: _version);

  Future<int> _insert(String tableName, Map<String, dynamic> map) async {
    final Database db = await _database();
    return await db.insert(tableName, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _delete(String tableName,
      {String where, List<dynamic> whereArgs}) async {
    final Database db = await _database();
    return db.delete(tableName, where: where, whereArgs: whereArgs);
  }

  Future _create(Database db, int version) async {
    await db.execute(CoreTable.create());
  }
}

class CoreTable {
  static const name = 'core';

  static String create() {
    String command = 'CREATE TABLE ${CoreTable.name}';
    command += '(';
    command += '${CoreTableColumns.id} INTEGER PRIMARY KEY, ';
    command += '${CoreTableColumns.userName} TEXT NOT NULL, ';
    command += ')';
    return command;
  }
}

class CoreTableColumns {
  static const String id = 'id';
  static const String userName = 'user_name';
}

class Core {
  @required
  final int id;
  @required
  final String userName;
  
  const Core(this.id, this.userName);
}


extension on Core {
  Map<String, dynamic> toMap() {
    return {
      CoreTableColumns.id: id,
      CoreTableColumns.userName: userName,
    };
  }
}

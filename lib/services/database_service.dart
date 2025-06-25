import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/models/notification_message.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE notifications (
  id $idType,
  userName $textType,
  msg $textType,
  senderId $textType,
  receiverId $textType,
  title $textType,
  timestamp $textType,
  token $textType
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      db.execute("ALTER TABLE notifications ADD COLUMN userName TEXT NOT NULL DEFAULT ''");
    }
  }

  Future<void> insertNotification(NotificationMessage notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationMessage>> getNotifications() async {
    final db = await database;
    // This raw query selects the most recent notification from each sender.
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM notifications WHERE id IN (SELECT MAX(id) FROM notifications GROUP BY senderId) ORDER BY timestamp DESC'
    );
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) {
      return NotificationMessage.fromJson(maps[i]);
    });
  }

  /// Fetches all notifications from a specific sender.
  Future<List<NotificationMessage>> getChatHistory(String senderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'senderId = ?',
      whereArgs: [senderId],
      orderBy: 'timestamp ASC', // Order by time to show a proper chat sequence
    );
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) {
      return NotificationMessage.fromJson(maps[i]);
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

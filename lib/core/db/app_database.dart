import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'focus_timer.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE context(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          focus_minutes INTEGER,
          break_minutes INTEGER,
          bgm TEXT,
          daily_goal_min INTEGER
        );
        ''');
        await db.execute('''
        CREATE TABLE session(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          context_id INTEGER,
          type TEXT,
          planned_minutes INTEGER,
          actual_seconds INTEGER,
          completed INTEGER,
          start_at TEXT,
          end_at TEXT,
          interrupted_reason TEXT
        );
        ''');
      },
    );
    return _db!;
  }
}

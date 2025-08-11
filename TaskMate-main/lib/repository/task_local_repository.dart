import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:taskmate/models/task_model.dart';

class TaskLocalRepository {
  static const String tableName = "tasks";
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "tasks.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            uid TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            dueAt INTEGER NOT NULL,
            priority TEXT NOT NULL,
            contact TEXT,
            status TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            isSynced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Create task locally
  Future<void> createTask(TaskModel task) async {
    final db = await database;
    final taskData = task.toJson();
    taskData['isSynced'] = 0; // Mark as not synced

    await db.insert(
      tableName,
      taskData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all tasks for a specific user
  Future<List<TaskModel>> getAllTasksForUser(String userId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'uid = ?',
      whereArgs: [userId],
      orderBy: 'dueAt ASC',
    );

    return result.map((row) => _convertRowToTaskModel(row)).toList();
  }

  // Get tasks by date for a specific user
  Future<List<TaskModel>> getTasksByDateForUser(String userId, DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      tableName,
      where: 'uid = ? AND dueAt >= ? AND dueAt < ?',
      whereArgs: [
        userId,
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch
      ],
      orderBy: 'dueAt ASC',
    );

    return result.map((row) => _convertRowToTaskModel(row)).toList();
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    final db = await database;
    final taskData = task.toJson();
    taskData['isSynced'] = 0; // Mark as not synced

    await db.update(
      tableName,
      taskData,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Get unsynced tasks for a specific user
  Future<List<TaskModel>> getUnsyncedTasksForUser(String userId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'uid = ? AND isSynced = ?',
      whereArgs: [userId, 0],
    );

    return result.map((row) => _convertRowToTaskModel(row)).toList();
  }

  // Mark task as synced
  Future<void> markTaskAsSynced(String taskId) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Clear all tasks (for fresh sync)
  Future<void> clearAllTasks() async {
    final db = await database;
    await db.delete(tableName);
  }

  // Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [taskId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return _convertRowToTaskModel(result.first);
    }
    return null;
  }

  // Convert SQLite row to TaskModel
  TaskModel _convertRowToTaskModel(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id']?.toString() ?? '',
      uid: row['uid']?.toString() ?? '',
      name: row['name'] ?? '',
      description: row['description'] ?? '',
      priority: row['priority'] ?? '',
      contact: row['contact'] ?? '',
      status: row['status'] ?? 'pending',
      dueAt: DateTime.fromMillisecondsSinceEpoch(row['dueAt'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updatedAt'] ?? 0),
    );
  }
}

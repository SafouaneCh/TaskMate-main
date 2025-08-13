import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/task_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Sync queue for offline operations
  final List<Map<String, dynamic>> _syncQueue = [];
  bool _isOnline = false;
  Timer? _syncTimer;

  // Initialize sync service
  Future<void> initialize() async {
    await _checkConnectivity();
    _startPeriodicSync();
  }

  // Check if device is online
  Future<bool> _checkConnectivity() async {
    try {
      await _supabase.from('tasks').select('id').limit(1);
      _isOnline = true;
      return true;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  // Start periodic sync (every 5 seconds when online for faster response)
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (await _checkConnectivity()) {
        await _processSyncQueue();
        await _syncFromSupabase();
      }
    });
  }

  // Add operation to sync queue
  void _addToSyncQueue(String operation, Map<String, dynamic> data) {
    _syncQueue.add({
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Process sync queue
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) return;

    final operations = List<Map<String, dynamic>>.from(_syncQueue);
    _syncQueue.clear();

    for (final operation in operations) {
      try {
        switch (operation['operation']) {
          case 'create_task':
            await _createTaskOnSupabase(operation['data']);
            break;
          case 'update_task':
            await _updateTaskOnSupabase(operation['data']);
            break;
          case 'delete_task':
            await _deleteTaskOnSupabase(operation['data']);
            break;
        }
      } catch (e) {
        // Re-add failed operations to queue
        _syncQueue.add(operation);
        print('Sync operation failed: $e');
      }
    }
  }

  // Sync tasks from Supabase to local
  Future<List<TaskModel>> _syncFromSupabase() async {
    if (!_isOnline) return [];

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      // Avoid querying with empty UUID which causes 22P02 errors
      return [];
    }

    try {
      final response =
          await _supabase.from('tasks').select().eq('user_id', currentUser.id);

      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (e) {
      print('Error syncing from Supabase: $e');
      return [];
    }
  }

  // Create task on Supabase
  Future<void> _createTaskOnSupabase(Map<String, dynamic> taskData) async {
    await _supabase.from('tasks').insert(taskData);
  }

  // Update task on Supabase
  Future<void> _updateTaskOnSupabase(Map<String, dynamic> taskData) async {
    await _supabase.from('tasks').update(taskData).eq('id', taskData['id']);
  }

  // Delete task on Supabase
  Future<void> _deleteTaskOnSupabase(Map<String, dynamic> taskData) async {
    await _supabase.from('tasks').delete().eq('id', taskData['id']);
  }

  // Public methods for task operations
  Future<void> syncCreateTask(TaskModel task) async {
    final taskData = task.toJson();

    if (_isOnline) {
      try {
        await _createTaskOnSupabase(taskData);
      } catch (e) {
        _addToSyncQueue('create_task', taskData);
      }
    } else {
      _addToSyncQueue('create_task', taskData);
    }
  }

  Future<void> syncUpdateTask(TaskModel task) async {
    final taskData = task.toJson();

    if (_isOnline) {
      try {
        await _updateTaskOnSupabase(taskData);
      } catch (e) {
        _addToSyncQueue('update_task', taskData);
      }
    } else {
      _addToSyncQueue('update_task', taskData);
    }
  }

  Future<void> syncDeleteTask(String taskId) async {
    final taskData = {'id': taskId};

    if (_isOnline) {
      try {
        await _deleteTaskOnSupabase(taskData);
      } catch (e) {
        _addToSyncQueue('delete_task', taskData);
      }
    } else {
      _addToSyncQueue('delete_task', taskData);
    }
  }

  // Get sync status
  bool get isOnline => _isOnline;
  int get pendingSyncCount => _syncQueue.length;

  // Dispose
  void dispose() {
    _syncTimer?.cancel();
  }
}

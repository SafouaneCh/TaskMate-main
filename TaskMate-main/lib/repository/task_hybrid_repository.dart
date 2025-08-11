import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_local_repository.dart';
import 'package:taskmate/repository/task_remote_repository.dart';
import 'package:taskmate/services/sync_service.dart';
import 'package:taskmate/services/network_service.dart';

class TaskHybridRepository {
  final TaskLocalRepository _localRepository = TaskLocalRepository();
  final TaskRemoteRepository _remoteRepository = TaskRemoteRepository();
  final SyncService _syncService = SyncService();
  final NetworkService _networkService = NetworkService();

  // Create task (offline-first)
  Future<TaskModel> createTask({
    required String name,
    required String description,
    required String date,
    required String time,
    required String priority,
    required String contact,
    required String token,
    required String userId,
    String status = 'pending',
  }) async {
    try {
      // Generate local ID
      final localId = DateTime.now().millisecondsSinceEpoch.toString();
      final dueAt = DateTime.parse('$date $time');

      // Create task model
      final task = TaskModel(
        id: localId,
        uid: userId,
        name: name,
        description: description,
        dueAt: dueAt,
        priority: priority,
        contact: contact,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally first (offline-first)
      await _localRepository.createTask(task);

      // Try to sync if online
      if (_networkService.isConnected) {
        try {
          final remoteTask = await _remoteRepository.createTask(
            name: name,
            description: description,
            date: date,
            time: time,
            priority: priority,
            contact: contact,
            token: token,
            status: status,
          );

          // Update local task with remote data
          await _localRepository.updateTask(remoteTask);
          await _localRepository.markTaskAsSynced(remoteTask.id);

          return remoteTask;
        } catch (e) {
          // If remote fails, queue for sync
          await _syncService.syncCreateTask(task);
          return task;
        }
      } else {
        // Queue for sync when online
        await _syncService.syncCreateTask(task);
        return task;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get tasks (offline-first)
  Future<List<TaskModel>> getTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) async {
    try {
      // Always get from local first
      List<TaskModel> localTasks;

      if (date != null) {
        localTasks = await _localRepository.getTasksByDateForUser(userId, date);
      } else {
        localTasks = await _localRepository.getAllTasksForUser(userId);
      }

      // Try to sync from remote if online
      if (_networkService.isConnected) {
        try {
          final remoteTasks = await _remoteRepository.getTasks(
            token: token,
            date: date,
          );

          // Merge remote and local tasks instead of clearing
          final mergedTasks = <TaskModel>[];

          // Add remote tasks
          for (final task in remoteTasks) {
            await _localRepository.createTask(task);
            await _localRepository.markTaskAsSynced(task.id);
            mergedTasks.add(task);
          }

          // Add local unsynced tasks
          final unsyncedTasks = await _localRepository.getUnsyncedTasksForUser(userId);
          for (final task in unsyncedTasks) {
            if (!mergedTasks.any((t) => t.id == task.id)) {
              mergedTasks.add(task);
            }
          }

          return mergedTasks;
        } catch (e) {
          // If remote fails, return local data
          return localTasks;
        }
      }

      return localTasks;
    } catch (e) {
      rethrow;
    }
  }

  // Update task (offline-first)
  Future<TaskModel> updateTask({
    required String taskId,
    required String name,
    required String description,
    required String date,
    required String time,
    required String priority,
    required String contact,
    required String token,
    String? status,
  }) async {
    try {
      // Get current task
      final currentTask = await _localRepository.getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Task not found');
      }

      // Create updated task
      final dueAt = DateTime.parse('$date $time');
      final updatedTask = currentTask.copyWith(
        name: name,
        description: description,
        dueAt: dueAt,
        priority: priority,
        contact: contact,
        status: status ?? currentTask.status,
        updatedAt: DateTime.now(),
      );

      // Update locally first
      await _localRepository.updateTask(updatedTask);

      // Try to sync if online
      if (_networkService.isConnected) {
        try {
          final remoteTask = await _remoteRepository.updateTask(
            taskId: taskId,
            name: name,
            description: description,
            date: date,
            time: time,
            priority: priority,
            contact: contact,
            token: token,
            status: status,
          );

          // Update local with remote data
          await _localRepository.updateTask(remoteTask);
          await _localRepository.markTaskAsSynced(remoteTask.id);

          return remoteTask;
        } catch (e) {
          // If remote fails, queue for sync
          await _syncService.syncUpdateTask(updatedTask);
          return updatedTask;
        }
      } else {
        // Queue for sync when online
        await _syncService.syncUpdateTask(updatedTask);
        return updatedTask;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update task status (offline-first)
  Future<TaskModel> updateTaskStatus({
    required String taskId,
    required String status,
    required String token,
  }) async {
    try {
      // Get current task
      final currentTask = await _localRepository.getTaskById(taskId);
      if (currentTask == null) {
        throw Exception('Task not found');
      }

      // Update locally first
      final updatedTask = currentTask.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _localRepository.updateTask(updatedTask);

      // Try to sync if online
      if (_networkService.isConnected) {
        try {
          final remoteTask = await _remoteRepository.updateTaskStatus(
            taskId: taskId,
            status: status,
            token: token,
          );

          // Update local with remote data
          await _localRepository.updateTask(remoteTask);
          await _localRepository.markTaskAsSynced(remoteTask.id);

          return remoteTask;
        } catch (e) {
          // If remote fails, queue for sync
          await _syncService.syncUpdateTask(updatedTask);
          return updatedTask;
        }
      } else {
        // Queue for sync when online
        await _syncService.syncUpdateTask(updatedTask);
        return updatedTask;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete task (offline-first)
  Future<void> deleteTask({
    required String taskId,
    required String token,
  }) async {
    try {
      // Delete locally first
      await _localRepository.deleteTask(taskId);

      // Try to sync if online
      if (_networkService.isConnected) {
        try {
          await _remoteRepository.deleteTask(
            taskId: taskId,
            token: token,
          );
        } catch (e) {
          // If remote fails, queue for sync
          await _syncService.syncDeleteTask(taskId);
        }
      } else {
        // Queue for sync when online
        await _syncService.syncDeleteTask(taskId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get sync status
  bool get isOnline => _networkService.isConnected;
  int get pendingSyncCount => _syncService.pendingSyncCount;

  // Force sync all pending changes
  Future<void> forceSync(String userId) async {
    if (_networkService.isConnected) {
      final unsyncedTasks = await _localRepository.getUnsyncedTasksForUser(userId);
      for (final task in unsyncedTasks) {
        await _syncService.syncUpdateTask(task);
      }
    }
  }
}

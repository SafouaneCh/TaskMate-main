import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_remote_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TaskRemoteRepository _taskRepository = TaskRemoteRepository();

  TasksCubit() : super(TasksInitial());

  // Keep the old method name for compatibility
  Future<void> fetchTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) async {
    try {
      emit(TasksLoading());

      final tasks = await _taskRepository.getTasks(
        token: token,
        date: date,
      );

      // Sort tasks before emitting
      final sortedTasks = _sortTasks(tasks);
      emit(TasksLoaded(sortedTasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  // Add refresh method for compatibility
  void refreshTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) {
    fetchTasks(token: token, userId: userId, date: date);
  }

  // Keep the new method name as well
  Future<void> getTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) async {
    await fetchTasks(token: token, userId: userId, date: date);
  }

  // Sort tasks by priority, completion status, and creation time
  List<TaskModel> _sortTasks(List<TaskModel> tasks) {
    return List<TaskModel>.from(tasks)
      ..sort((a, b) {
        // First priority: completed tasks go to bottom
        if (a.status == 'completed' && b.status != 'completed') return 1;
        if (a.status != 'completed' && b.status == 'completed') return -1;

        // Second priority: sort by priority (High > Medium > Low)
        final priorityOrder = {
          'High priority': 3,
          'Medium priority': 2,
          'Low priority': 1
        };
        final aPriority = priorityOrder[a.priority] ?? 0;
        final bPriority = priorityOrder[b.priority] ?? 0;

        if (aPriority != bPriority) {
          return bPriority.compareTo(aPriority); // Higher priority first
        }

        // Third priority: sort by due time (earlier first)
        return a.dueAt.compareTo(b.dueAt);
      });
  }

  // Manual method to sort current tasks
  void sortCurrentTasks() {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final sortedTasks = _sortTasks(currentState.tasks);
      emit(TasksLoaded(sortedTasks));
    }
  }

  // Refresh and sort tasks
  Future<void> refreshAndSortTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) async {
    await fetchTasks(token: token, userId: userId, date: date);
  }

  // Get tasks with custom sorting
  Future<void> getTasksWithCustomSort({
    required String token,
    required String userId,
    DateTime? date,
    String? sortBy, // 'priority', 'dueDate', 'status', 'name'
  }) async {
    try {
      emit(TasksLoading());

      final tasks = await _taskRepository.getTasks(
        token: token,
        date: date,
      );

      List<TaskModel> sortedTasks;

      switch (sortBy) {
        case 'priority':
          sortedTasks = _sortTasksByPriority(tasks);
          break;
        case 'dueDate':
          sortedTasks = _sortTasksByDueDate(tasks);
          break;
        case 'status':
          sortedTasks = _sortTasksByStatus(tasks);
          break;
        case 'name':
          sortedTasks = _sortTasksByName(tasks);
          break;
        default:
          sortedTasks = _sortTasks(tasks); // Default sorting
      }

      emit(TasksLoaded(sortedTasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  // Custom sorting methods
  List<TaskModel> _sortTasksByPriority(List<TaskModel> tasks) {
    return List<TaskModel>.from(tasks)
      ..sort((a, b) {
        final priorityOrder = {
          'High priority': 3,
          'Medium priority': 2,
          'Low priority': 1
        };
        final aPriority = priorityOrder[a.priority] ?? 0;
        final bPriority = priorityOrder[b.priority] ?? 0;
        return bPriority.compareTo(aPriority); // Higher priority first
      });
  }

  List<TaskModel> _sortTasksByDueDate(List<TaskModel> tasks) {
    return List<TaskModel>.from(tasks)
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  List<TaskModel> _sortTasksByStatus(List<TaskModel> tasks) {
    return List<TaskModel>.from(tasks)
      ..sort((a, b) {
        // Completed tasks go to bottom
        if (a.status == 'completed' && b.status != 'completed') return 1;
        if (a.status != 'completed' && b.status == 'completed') return -1;
        return a.status.compareTo(b.status);
      });
  }

  List<TaskModel> _sortTasksByName(List<TaskModel> tasks) {
    return List<TaskModel>.from(tasks)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> updateTask({
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
    // Optimistic update - update UI immediately
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == taskId) {
          // Return the updated task with new values
          return task.copyWith(
            name: name,
            description: description,
            dueAt: DateTime.parse('$date $time'),
            priority: priority,
            contact: contact,
            status: status ?? task.status,
          );
        }
        return task;
      }).toList();

      emit(TasksLoaded(updatedTasks));
    }

    try {
      // Make API call in background
      await _taskRepository.updateTask(
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

      // API call succeeded, state is already updated
    } catch (e) {
      emit(TasksError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String status,
    required String token,
  }) async {
    // Optimistic update - update UI immediately
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == taskId) {
          // Return the updated task with new status
          return task.copyWith(status: status);
        }
        return task;
      }).toList();

      // Sort tasks before emitting
      final sortedUpdatedTasks = _sortTasks(updatedTasks);
      emit(TasksLoaded(sortedUpdatedTasks));
    }

    try {
      // Make API call in background
      await _taskRepository.updateTaskStatus(
        taskId: taskId,
        status: status,
        token: token,
      );

      // API call succeeded, state is already updated
    } catch (e) {
      emit(TasksError('Failed to update task status: ${e.toString()}'));
    }
  }

  Future<void> deleteTask({
    required String taskId,
    required String token,
  }) async {
    // Optimistic update - remove task from UI immediately
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final updatedTasks =
          currentState.tasks.where((task) => task.id != taskId).toList();

      // Sort tasks after deletion
      final sortedTasks = _sortTasks(updatedTasks);
      emit(TasksLoaded(sortedTasks));
    }

    try {
      // Make API call in background
      await _taskRepository.deleteTask(
        taskId: taskId,
        token: token,
      );

      // API call succeeded, state is already updated
    } catch (e) {
      // API call failed, revert the optimistic update
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        // Re-fetch tasks to restore the original state
        final tasks = await _taskRepository.getTasks(
          token: token,
          date: null, // Get all tasks to restore state
        );
        final sortedTasks = _sortTasks(tasks);
        emit(TasksLoaded(sortedTasks));
      }
      emit(TasksError('Failed to delete task: ${e.toString()}'));
    }
  }
}

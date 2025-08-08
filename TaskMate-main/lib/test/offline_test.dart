import 'package:flutter_test/flutter_test.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_local_repository.dart';
import 'package:taskmate/repository/task_hybrid_repository.dart';

void main() {
  group('Offline Functionality Tests', () {
    late TaskLocalRepository localRepository;
    late TaskHybridRepository hybridRepository;

    setUp(() {
      localRepository = TaskLocalRepository();
      hybridRepository = TaskHybridRepository();
    });

    test('Should create task locally when offline', () async {
      // Create a test task
      final task = TaskModel(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        uid: 'test-user',
        name: 'Test Task',
        description: 'Test Description',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        priority: 'Medium priority',
        contact: 'test@example.com',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save task locally
      await localRepository.createTask(task);

      // Verify task is saved locally
      final savedTasks = await localRepository.getAllTasks();
      expect(savedTasks.length, greaterThan(0));

      final savedTask = savedTasks.firstWhere((t) => t.name == 'Test Task');
      expect(savedTask.name, equals('Test Task'));
      expect(savedTask.description, equals('Test Description'));
    });

    test('Should retrieve tasks by date', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      // Create tasks for different dates
      final task1 = TaskModel(
        id: 'task1-${DateTime.now().millisecondsSinceEpoch}',
        uid: 'test-user',
        name: 'Today Task',
        description: 'Task for today',
        dueAt: today,
        priority: 'High priority',
        contact: 'test@example.com',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final task2 = TaskModel(
        id: 'task2-${DateTime.now().millisecondsSinceEpoch}',
        uid: 'test-user',
        name: 'Tomorrow Task',
        description: 'Task for tomorrow',
        dueAt: tomorrow,
        priority: 'Medium priority',
        contact: 'test@example.com',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save both tasks
      await localRepository.createTask(task1);
      await localRepository.createTask(task2);

      // Get tasks for today
      final todayTasks = await localRepository.getTasksByDate(today);
      expect(todayTasks.length, greaterThan(0));
      expect(todayTasks.any((task) => task.name == 'Today Task'), isTrue);

      // Get tasks for tomorrow
      final tomorrowTasks = await localRepository.getTasksByDate(tomorrow);
      expect(tomorrowTasks.length, greaterThan(0));
      expect(tomorrowTasks.any((task) => task.name == 'Tomorrow Task'), isTrue);
    });

    test('Should update task locally', () async {
      // Create a test task
      final task = TaskModel(
        id: 'update-test-${DateTime.now().millisecondsSinceEpoch}',
        uid: 'test-user',
        name: 'Original Name',
        description: 'Original Description',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        priority: 'Low priority',
        contact: 'test@example.com',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save task
      await localRepository.createTask(task);

      // Update task
      final updatedTask = task.copyWith(
        name: 'Updated Name',
        description: 'Updated Description',
        status: 'completed',
        updatedAt: DateTime.now(),
      );

      await localRepository.updateTask(updatedTask);

      // Verify update
      final savedTask = await localRepository.getTaskById(task.id);
      expect(savedTask, isNotNull);
      expect(savedTask!.name, equals('Updated Name'));
      expect(savedTask.description, equals('Updated Description'));
      expect(savedTask.status, equals('completed'));
    });

    test('Should delete task locally', () async {
      // Create a test task
      final task = TaskModel(
        id: 'delete-test-${DateTime.now().millisecondsSinceEpoch}',
        uid: 'test-user',
        name: 'Task to Delete',
        description: 'This task will be deleted',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        priority: 'Medium priority',
        contact: 'test@example.com',
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save task
      await localRepository.createTask(task);

      // Verify task exists
      final savedTask = await localRepository.getTaskById(task.id);
      expect(savedTask, isNotNull);

      // Delete task
      await localRepository.deleteTask(task.id);

      // Verify task is deleted
      final deletedTask = await localRepository.getTaskById(task.id);
      expect(deletedTask, isNull);
    });
  });
}

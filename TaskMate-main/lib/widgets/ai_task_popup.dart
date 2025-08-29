import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/cubit/tasks_cubit.dart';
import '../widgets/task_card.dart';
import '../services/ai_parsing_service.dart';
import 'package:taskmate/core/services/reminder_service.dart';
import 'package:taskmate/models/task_model.dart';
import 'dart:convert'; // Added for jsonEncode

class AITaskModal extends StatefulWidget {
  final void Function(TaskCard) onTaskAdded;
  final DateTime selectedDate;

  const AITaskModal({
    super.key,
    required this.onTaskAdded,
    required this.selectedDate,
  });

  @override
  _AITaskModalState createState() => _AITaskModalState();
}

class _AITaskModalState extends State<AITaskModal> {
  final TextEditingController _naturalLanguageController =
      TextEditingController();
  bool _isCreating = false;
  bool _showSuccess = false;
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _naturalLanguageController.dispose();
    super.dispose();
  }

  Future<void> _createTaskWithAI() async {
    if (_naturalLanguageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your task')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLoggedIn) {
        // Create task directly using AI
        final result = await AIParsingService.createAITask(
          _naturalLanguageController.text.trim(),
          authState.user.token,
        );

        setState(() {
          _isCreating = false;
          _showSuccess = true;
          _successMessage =
              'Task "${result['task']['name']}" created successfully!';
        });

        // Schedule reminder for the AI-created task
        try {
          print('=== Scheduling reminder for AI-created task ===');
          print('Task result: ${jsonEncode(result)}');

          // Create a TaskModel from the result to schedule reminder
          final taskData = result['task'];
          print('Task data: ${jsonEncode(taskData)}');

          final taskModel = TaskModel(
            id: taskData['id'],
            userId: taskData['uid'] ?? taskData['userId'],
            name: taskData['name'],
            description: taskData['description'],
            dueAt: DateTime.parse(taskData['dueAt']),
            priority: taskData['priority'],
            contact: taskData['contact'] ?? '',
            status: taskData['status'],
            createdAt: DateTime.parse(taskData['createdAt']),
            updatedAt: DateTime.parse(taskData['updatedAt']),
            hasReminder: true,
            reminderAt: DateTime.parse(taskData['dueAt']),
            reminderType: '1hour',
          );

          print(
              'Created TaskModel: ${taskModel.name}, dueAt: ${taskModel.dueAt}, hasReminder: ${taskModel.hasReminder}');

          // Schedule only ONE reminder to prevent duplicates
          final reminderTypes = ['1hour']; // Only 1 reminder to avoid spam
          await ReminderService.scheduleMultipleReminders(
              taskModel, reminderTypes);
          print(
              '✅ Single reminder scheduled successfully for AI-created task: ${taskModel.name}');
          print('📋 Reminder type: $reminderTypes (1 hour before due)');
        } catch (e) {
          print('❌ Failed to schedule reminder for AI task: $e');
          print('Error details: ${e.toString()}');
          // Don't fail the task creation if reminder scheduling fails
        }

        // Refresh tasks immediately and then close modal
        // Refresh tasks for the selected date
        context.read<TasksCubit>().refreshTasks(
              token: authState.user.token,
              userId: authState.user.id,
              date: widget.selectedDate,
            );

        // Close modal after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });

      // Show detailed error message
      String errorMessage = 'Failed to create task';
      if (e.toString().contains('Connection error')) {
        errorMessage =
            'Cannot connect to backend. Please check if the server is running.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _createTaskWithAI,
          ),
        ),
      );
    }
  }

  void _tryDemo() {
    _naturalLanguageController.text =
        "Meeting with John tomorrow at 2 PM to discuss project timeline";
    _createTaskWithAI();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.8, // Increased height to prevent overflow
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Header - Fixed height
            SizedBox(
              height: screenHeight * 0.08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Create Task with AI',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF073F5C),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: screenWidth * 0.1,
                      minHeight: screenWidth * 0.1,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Success message
            if (_showSuccess)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 24),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        _successMessage,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_showSuccess) ...[
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Instructions
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: Colors.blue.shade600, size: 20),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Text(
                                    'Just describe your task naturally',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'The AI will automatically create a task with the right name, description, date, time, priority, and status. You can specify priority (high/medium/low) and status (pending/in progress/completed) in your description.',
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Natural language input
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xEAECECBF),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                          border: Border.all(
                            color: const Color(0xFF073F5C),
                            width: 3.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Describe your task',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF073F5C),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextField(
                              controller: _naturalLanguageController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'e.g., "Meeting with John tomorrow at 2 PM to discuss project"',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenHeight * 0.01,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: const Color(0xFF073F5C),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isCreating ? null : _tryDemo,
                              icon: const Icon(Icons.lightbulb_outline,
                                  color: Color(0xFF073F5C)),
                              label: const Text(
                                'Try Demo',
                                style: TextStyle(color: Color(0xFF073F5C)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF073F5C)),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.05),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isCreating ? null : _createTaskWithAI,
                              icon: _isCreating
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.auto_awesome,
                                      color: Colors.white),
                              label: Text(
                                _isCreating ? 'Creating...' : 'Create Task',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF073F5C),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.05),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Examples
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Examples:',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              '• "Call Sarah on Friday at 10 AM to confirm appointment"\n'
                              '• "Send weekly report to team by Friday, high priority"\n'
                              '• "Don\'t forget to buy groceries tomorrow morning"\n'
                              '• "Review quarterly budget with finance team next Monday at 10 AM, urgent"\n'
                              '• "Meeting with John tomorrow at 2 PM, in progress"',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

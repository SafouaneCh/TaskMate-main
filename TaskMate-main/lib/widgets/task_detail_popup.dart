import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskDetailPopup extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const TaskDetailPopup({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.9,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF074361), Color(0xFF0E81BB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.04),
                  topRight: Radius.circular(screenWidth * 0.04),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                ],
              ),
            ),
            
            // Task content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task name
                    Text(
                      task.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Priority and time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            border: Border.all(
                              color: _getPriorityColor(task.priority),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            task.priority,
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              DateFormat('HH:mm').format(task.dueAt),
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Description
                    if (task.description.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                    
                    // Date and time details
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: screenWidth * 0.04,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(task.dueAt),
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Contacts section
                    if (task.contact.isNotEmpty) ...[
                      Text(
                        'Contacts',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Wrap(
                        spacing: screenWidth * 0.02,
                        runSpacing: screenHeight * 0.01,
                        children: task.contact.split(',').map((contact) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.008,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF074361).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              border: Border.all(
                                color: Color(0xFF074361),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              contact.trim(),
                              style: TextStyle(
                                color: Color(0xFF074361),
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                    
                    // Created and updated info
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created: ${DateFormat('MMM d, yyyy').format(task.createdAt)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'Last updated: ${DateFormat('MMM d, yyyy').format(task.updatedAt)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  // Edit button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit, size: screenWidth * 0.04),
                      label: Text(
                        'Edit',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF074361),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  // Delete button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      icon: Icon(Icons.delete, size: screenWidth * 0.04),
                      label: Text(
                        'Delete',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high priority':
        return Colors.red;
      case 'medium priority':
        return Colors.orange;
      case 'low priority':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
} 
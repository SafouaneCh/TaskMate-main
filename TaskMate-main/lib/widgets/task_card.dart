import 'package:flutter/material.dart';
// Import provider package
// Ensure Provider is imported
// Ensure contacts_service is imported
// Import this to use Uint8List

class TaskCard extends StatelessWidget {
  final String time;
  final String description;
  final String priority;
  final bool isCompleted;
  final String name; // Attribute for task name
  final String date; // Attribute for task date
  final List<String> contacts; // Attribute for task contacts

  const TaskCard({super.key, 
    required this.time,
    required this.description,
    required this.priority,
    this.isCompleted = false,
    required this.name,
    required this.date,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(11, 0, 13, 29),
      child: _CardContent(
        time: time,
        description: description,
        priority: priority,
        isCompleted: isCompleted,
        name: name,
        date: date,
        contacts: contacts,
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final String time;
  final String description;
  final String priority;
  final bool isCompleted;
  final String name;
  final String date;
  final List<String> contacts;

  const _CardContent({
    required this.time,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.name,
    required this.date,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE0E0E0) : const Color(0xFFFBF5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(31.4, 12, 31.5, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeAndPriority(time: time, priority: priority),
          const SizedBox(height: 9),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 26,
              height: 1.2,
              letterSpacing: -0.5,
              color: isCompleted ? Colors.grey : const Color(0xFF333333),
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 9),
          // Removed contact avatars section
        ],
      ),
    );
  }
}

class _TimeAndPriority extends StatelessWidget {
  final String time;
  final String priority;

  const _TimeAndPriority({
    required this.time,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor = _getPriorityColor(priority);

    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 1.2,
                  letterSpacing: -0.3,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            Flexible(
              child: Text(
                priority,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.2,
                  letterSpacing: -0.3,
                  color: priorityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get priority color
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high priority':
        return Colors.red;
      case 'medium priority':
        return Colors.orange;
      case 'low priority':
        return Colors.green;
      default:
        return Colors.grey; // Default color if priority is not recognized
    }
  }
}

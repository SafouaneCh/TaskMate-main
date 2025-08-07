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
  final String status; // Add status field
  final VoidCallback? onTap; // Add onTap callback
  final Function(String)? onStatusChanged; // Add status change callback

  const TaskCard({
    super.key,
    required this.time,
    required this.description,
    required this.priority,
    this.isCompleted = false,
    required this.name,
    required this.date,
    required this.contacts,
    required this.status,
    this.onTap, // Add onTap parameter
    this.onStatusChanged, // Add status change parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Add tap functionality
      child: Container(
        margin: const EdgeInsets.fromLTRB(11, 0, 13, 29),
        child: _CardContent(
          time: time,
          description: description,
          priority: priority,
          isCompleted: isCompleted,
          name: name,
          date: date,
          contacts: contacts,
          status: status,
          onStatusChanged: onStatusChanged,
        ),
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
  final String status;
  final Function(String)? onStatusChanged;

  const _CardContent({
    required this.time,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.name,
    required this.date,
    required this.contacts,
    required this.status,
    this.onStatusChanged,
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
          _TimeAndPriority(time: time, priority: priority, status: status),
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
          // Status indicator
          _StatusIndicator(status: status, onStatusChanged: onStatusChanged),
          // Removed contact avatars section
        ],
      ),
    );
  }
}

class _TimeAndPriority extends StatelessWidget {
  final String time;
  final String priority;
  final String status;

  const _TimeAndPriority({
    required this.time,
    required this.priority,
    required this.status,
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

class _StatusIndicator extends StatelessWidget {
  final String status;
  final Function(String)? onStatusChanged;

  const _StatusIndicator({
    required this.status,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(status);
    String statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

import 'package:flutter/material.dart';

class StatusSelectionWidget extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const StatusSelectionWidget({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'value': 'pending', 'label': 'Pending', 'color': Colors.orange},
      {'value': 'in_progress', 'label': 'In Progress', 'color': Colors.blue},
      {'value': 'completed', 'label': 'Completed', 'color': Colors.green},
      {'value': 'cancelled', 'label': 'Cancelled', 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statuses.map((status) {
            final isSelected = selectedStatus == status['value'];
            return GestureDetector(
              onTap: () => onStatusChanged(status['value'] as String),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (status['color'] as Color).withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? status['color'] as Color
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(status['value'] as String),
                      size: 16,
                      color: isSelected
                          ? status['color'] as Color
                          : Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      status['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? status['color'] as Color
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
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

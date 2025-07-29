import 'package:flutter/material.dart';

class TaskCategoryChip extends StatelessWidget {
  final String label;

  const TaskCategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue,
    );
  }
}

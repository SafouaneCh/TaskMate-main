import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:taskmate/cubit/tasks_cubit.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:intl/intl.dart';

class EditTaskModal extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onTaskUpdated;
  final DateTime? filterDate;

  const EditTaskModal({
    super.key,
    required this.task,
    this.onTaskUpdated,
    this.filterDate,
  });

  @override
  _EditTaskModalState createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _selectedPriority = 'Medium priority';
  String _selectedStatus = 'pending';
  final List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _fetchContacts();
  }

  void _initializeForm() {
    // Pre-populate form with task data
    _nameController.text = widget.task.name;
    _descriptionController.text = widget.task.description;
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;

    // Format date and time
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');
    _dateController.text = dateFormat.format(widget.task.dueAt);
    _timeController.text = timeFormat.format(widget.task.dueAt);

    // Parse existing contacts
    if (widget.task.contact.isNotEmpty && widget.task.contact != 'null') {
      // For now, we'll handle contacts as strings since we don't have contact objects
      // In a full implementation, you'd want to match contacts by name
    }
  }

  Future<void> _fetchContacts() async {
    // Contacts are optional for edit; we don't need to store them here
    try {
      await FlutterContacts.getContacts();
    } catch (_) {}
  }

  void _updateTask() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      String? token;
      if (authState is AuthLoggedIn) {
        token = authState.user.token;
      }

      if (token != null) {
        _performUpdate();
      }
    }
  }

  void _performUpdate() {
    final authState = context.read<AuthCubit>().state;
    String? token;
    if (authState is AuthLoggedIn) {
      token = authState.user.token;
    }

    if (token != null && authState is AuthLoggedIn) {
      context.read<TasksCubit>().updateTask(
            taskId: widget.task.id,
            name: _nameController.text,
            description: _descriptionController.text,
            date: _dateController.text,
            time: _timeController.text,
            priority: _selectedPriority,
            contact: _selectedContacts.map((c) => c.displayName).join(","),
            token: token,
            status: _selectedStatus,
          );

      Navigator.of(context).pop();
      widget.onTaskUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    IconData? prefixIcon,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.008),
      decoration: BoxDecoration(
        color: const Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: const Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.04, top: screenWidth * 0.02),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Icon(prefixIcon,
                      color: const Color(0xFF073F5C), size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.05,
                    color: Color(0xFF073F5C),
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Color(0xFFB7B7B7),
                fontFamily: 'Roboto',
                fontSize: screenWidth * 0.045,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.04),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field cannot be empty';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
    String label,
    String hint, {
    required TextEditingController controller,
    IconData? prefixIcon,
    required double screenWidth,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: () async {
        // Parse the current date from the controller or use task's due date
        DateTime initialDate = widget.task.dueAt;
        try {
          if (controller.text.isNotEmpty) {
            initialDate = DateTime.parse(controller.text);
          }
        } catch (e) {
          // If parsing fails, use task's due date
          initialDate = widget.task.dueAt;
        }

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            controller.text = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          label,
          hint,
          controller: controller,
          prefixIcon: prefixIcon,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
    String label,
    String hint, {
    required TextEditingController controller,
    IconData? prefixIcon,
    required double screenWidth,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: () async {
        // Parse the current time from the controller or use task's due time
        TimeOfDay initialTime = TimeOfDay.fromDateTime(widget.task.dueAt);
        try {
          if (controller.text.isNotEmpty) {
            final timeParts = controller.text.split(':');
            if (timeParts.length == 2) {
              initialTime = TimeOfDay(
                hour: int.parse(timeParts[0]),
                minute: int.parse(timeParts[1]),
              );
            }
          }
        } catch (e) {
          // If parsing fails, use task's due time
          initialTime = TimeOfDay.fromDateTime(widget.task.dueAt);
        }

        final pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );

        if (pickedTime != null) {
          setState(() {
            controller.text =
                '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          label,
          hint,
          controller: controller,
          prefixIcon: prefixIcon,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.008),
      decoration: BoxDecoration(
        color: const Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: const Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.04, top: screenWidth * 0.02),
            child: Row(
              children: [
                Icon(Icons.priority_high,
                    color: const Color(0xFF073F5C), size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Priority',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.05,
                    color: Color(0xFF073F5C),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.04),
            ),
            items: [
              'High priority',
              'Medium priority',
              'Low priority',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedPriority = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.008),
      decoration: BoxDecoration(
        color: const Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(
          color: const Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.04, top: screenWidth * 0.02),
            child: Row(
              children: [
                Icon(Icons.flag,
                    color: const Color(0xFF073F5C), size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.05,
                    color: Color(0xFF073F5C),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.04),
            ),
            items: [
              {'value': 'pending', 'label': 'Pending'},
              {'value': 'in_progress', 'label': 'In Progress'},
              {'value': 'completed', 'label': 'Completed'},
              {'value': 'cancelled', 'label': 'Cancelled'},
            ].map((Map<String, String> item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedStatus = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

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
            // Header
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
                    'Edit Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task name
                      _buildTextField(
                        'Task Name',
                        'Enter task name',
                        controller: _nameController,
                        prefixIcon: Icons.task,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Description
                      _buildTextField(
                        'Description',
                        'Enter task description',
                        controller: _descriptionController,
                        prefixIcon: Icons.description,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Date and Time row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePickerField(
                              'Date',
                              'Select date',
                              controller: _dateController,
                              prefixIcon: Icons.calendar_today,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: _buildTimePickerField(
                              'Time',
                              'Select time',
                              controller: _timeController,
                              prefixIcon: Icons.access_time,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Priority
                      _buildPriorityDropdown(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.02),

                      // Status
                      _buildStatusDropdown(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  // Update button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF074361),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(fontSize: screenWidth * 0.04),
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskmate/cubit/add_new_task_cubit.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import '../widgets/task_card.dart';

class AddTaskModal extends StatefulWidget {
  final void Function(TaskCard) onTaskAdded;
  final DateTime? selectedDate; // Add optional selected date parameter

  const AddTaskModal({
    super.key,
    required this.onTaskAdded,
    this.selectedDate, // Add this parameter
  });

  @override
  _AddTaskModalState createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _selectedPriority = 'Medium priority';
  String _selectedStatus = 'pending';
  final String _selectedReminderType = '1hour'; // Add reminder type selection
  final List<Contact> _selectedContacts = [];
  List<Contact> _allContacts = [];
  bool _contactsLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();

    // Pre-fill date field if selected date is provided
    if (widget.selectedDate != null) {
      _dateController.text =
          widget.selectedDate!.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() {
        _permissionDenied = true;
        _contactsLoading = false;
      });
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts();
      setState(() {
        _allContacts = contacts;
        _contactsLoading = false;
      });
    } catch (e) {
      setState(() {
        _contactsLoading = false;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      String? token;
      if (authState is AuthLoggedIn) {
        token = authState.user.token;
      }
      BlocProvider.of<AddNewTaskCubit>(context).createNewTask(
        name: _nameController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        time: _timeController.text,
        priority: _selectedPriority,
        status: _selectedStatus,
        contacts: _selectedContacts,
        token: token ?? '',
        reminderType: _selectedReminderType, // Add reminder type
      );
      // Don't pop immediately, wait for success/error state
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
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: const Color(0xFFE1E5E9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                top: screenWidth * 0.01,
                bottom: screenWidth * 0.02),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Icon(prefixIcon,
                      color: const Color(0xFF2C3E50),
                      size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.042,
                    color: Color(0xFF2C3E50),
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
                color: Color(0xFF95A5A6),
                fontFamily: 'Roboto',
                fontSize: screenWidth * 0.04,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.02),
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
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
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
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          setState(() {
            final hour = pickedTime.hour.toString().padLeft(2, '0');
            final minute = pickedTime.minute.toString().padLeft(2, '0');
            controller.text = '$hour:$minute:00';
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
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: const Color(0xFFE1E5E9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                top: screenWidth * 0.01,
                bottom: screenWidth * 0.02),
            child: Row(
              children: [
                Icon(Icons.star,
                    color: Color(0xFF2C3E50), size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'Priority',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.042,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.02),
              border: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Color(0xFF2C3E50),
            ),
            items: ['High priority', 'Medium priority', 'Low priority']
                .map((priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Text(
                  priority,
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: Color(0xFF2C3E50)),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: const Color(0xFFE1E5E9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                top: screenWidth * 0.01,
                bottom: screenWidth * 0.02),
            child: Row(
              children: [
                Icon(Icons.task_alt,
                    color: Color(0xFF2C3E50), size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.042,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.02),
              border: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Color(0xFF2C3E50),
            ),
            items: ['pending', 'in_progress'].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: Color(0xFF2C3E50)),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactField(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: const Color(0xFFE1E5E9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.02,
                top: screenWidth * 0.01,
                bottom: screenWidth * 0.02),
            child: Row(
              children: [
                Icon(Icons.contacts,
                    color: Color(0xFF2C3E50), size: screenWidth * 0.045),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    fontSize: screenWidth * 0.042,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          if (_permissionDenied)
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              child: TextButton(
                onPressed: () async {
                  await openAppSettings();
                  _fetchContacts();
                },
                child: Text(
                  'Permission denied. Tap to open settings',
                  style: TextStyle(
                      color: Colors.red, fontSize: screenWidth * 0.04),
                ),
              ),
            )
          else if (_contactsLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            DropdownButtonFormField<Contact>(
              value: null,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.02),
                border: InputBorder.none,
                hintText: 'Select contacts',
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Color(0xFF95A5A6),
                ),
              ),
              dropdownColor: Colors.white,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Color(0xFF2C3E50),
              ),
              items: _allContacts.map((contact) {
                return DropdownMenuItem<Contact>(
                  value: contact,
                  child: Text(
                    contact.displayName,
                    style: TextStyle(
                        fontSize: screenWidth * 0.04, color: Color(0xFF2C3E50)),
                  ),
                );
              }).toList(),
              onChanged: (selectedContact) {
                if (selectedContact != null &&
                    !_selectedContacts.contains(selectedContact)) {
                  setState(() {
                    _selectedContacts.add(selectedContact);
                  });
                }
              },
            ),
            if (_selectedContacts.isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: screenWidth * 0.02,
                  runSpacing: screenHeight * 0.01,
                  children: _selectedContacts.map((contact) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.25,
                      ),
                      child: Chip(
                        label: Text(
                          contact.displayName,
                          style: TextStyle(fontSize: screenWidth * 0.035),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedContacts.remove(contact);
                          });
                        },
                        deleteIcon: Icon(
                          Icons.close,
                          size: screenWidth * 0.04,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return BlocListener<AddNewTaskCubit, AddNewTaskState>(
      listener: (context, state) {
        if (state is AddNewTakSucess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Task added successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Notify parent component about the new task
          widget.onTaskAdded(TaskCard(
            time: '12:00', // Default time since we don't have exact time
            description: state.taskModel.description,
            priority: state.taskModel.priority,
            name: state.taskModel.name,
            date: state.taskModel.dueAt.toLocal().toString().split(' ')[0],
            contacts: state.taskModel.contact.isNotEmpty
                ? [state.taskModel.contact]
                : [],
            status: state.taskModel.status,
          ));

          // Close the popup
          Navigator.of(context).pop();
        } else if (state is AddNewTakError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Failed to add task: ${state.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AddNewTaskCubit, AddNewTaskState>(
        builder: (context, state) {
          return Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Center(
                  child: Container(
                    width: screenWidth * 0.92,
                    height: screenHeight * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth *
                              0.84, // Reduced to account for padding
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.02,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color(0xFF6C757D),
                                          fontFamily: 'Roboto',
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Add Task',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                        fontSize: screenWidth * 0.055,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _saveTask,
                                      child: Text(
                                        'Done',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Color(0xFF007BFF),
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              _buildTextField(
                                'Task name',
                                'Enter your Task name',
                                controller: _nameController,
                                prefixIcon: Icons.task,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                              SizedBox(height: screenHeight * 0.025),
                              _buildTextField(
                                'Task description',
                                'Enter your Task prompt',
                                controller: _descriptionController,
                                prefixIcon: Icons.notes,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                              SizedBox(height: screenHeight * 0.025),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDatePickerField(
                                      'Date',
                                      '2024-09-01',
                                      controller: _dateController,
                                      prefixIcon: Icons.calendar_today,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.025),
                                  Expanded(
                                    child: _buildTimePickerField(
                                      'Time',
                                      '14:00',
                                      controller: _timeController,
                                      prefixIcon: Icons.access_time,
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.025),
                              _buildPriorityDropdown(screenWidth, screenHeight),
                              SizedBox(height: screenHeight * 0.025),
                              _buildStatusDropdown(screenWidth, screenHeight),
                              SizedBox(height: screenHeight * 0.025),
                              _buildContactField(screenWidth, screenHeight),
                              SizedBox(height: screenHeight * 0.035),
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state is AddNewTakLoading
                                        ? null
                                        : _saveTask,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.02,
                                          horizontal: screenWidth * 0.05),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenWidth * 0.03),
                                      ),
                                      backgroundColor: const Color(0xFF007BFF),
                                      elevation: 3,
                                      shadowColor:
                                          Color(0xFF007BFF).withOpacity(0.3),
                                    ),
                                    child: state is AddNewTakLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.04,
                                                height: screenWidth * 0.04,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.03),
                                              Text(
                                                'Saving...',
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Save Task',
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.045,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}

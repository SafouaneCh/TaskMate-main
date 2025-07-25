import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/task_data.dart';
import '../widgets/task_card.dart';

class AddTaskModal extends StatefulWidget {
  final void Function(TaskCard) onTaskAdded;

  const AddTaskModal({required this.onTaskAdded});

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
  List<Contact> _selectedContacts = [];
  List<Contact> _allContacts = [];
  bool _contactsLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF4A5053),
                            fontFamily: 'Roboto',
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const Text(
                        'Add task',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: _saveTask,
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF009DFF),
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    'Task name',
                    'Enter your Task name',
                    controller: _nameController,
                    prefixIcon: Icons.task,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Task description',
                    'Enter your Task prompt',
                    controller: _descriptionController,
                    prefixIcon: Icons.notes,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          'Date',
                          '2024-09-01',
                          controller: _dateController,
                          prefixIcon: Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimePickerField(
                          'Time',
                          '14:00',
                          controller: _timeController,
                          prefixIcon: Icons.access_time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPriorityDropdown(),
                  const SizedBox(height: 20),
                  _buildContactField(),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: const Color(0xFF074666),
                      ),
                      child: const Text(
                        'Save task',
                        style: TextStyle(
                            fontSize: 18, color: Colors.yellowAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = TaskCard(
        time: _timeController.text,
        description: _descriptionController.text,
        priority: _selectedPriority,
        isCompleted: false,
        name: _nameController.text,
        date: _dateController.text,
        contacts: _selectedContacts
            .map((contact) => contact.displayName)
            .toList(),
      );
      widget.onTaskAdded(newTask);
      Navigator.of(context).pop();
    }
  }

  Widget _buildTextField(
      String label,
      String hint, {
        required TextEditingController controller,
        IconData? prefixIcon,
      }) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 8.0),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Icon(prefixIcon, color: const Color(0xFF073F5C)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 20,
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
              hintStyle: const TextStyle(
                color: Color(0xFFB7B7B7),
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
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
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
      String label,
      String hint, {
        required TextEditingController controller,
        IconData? prefixIcon,
      }) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          setState(() {
            controller.text = pickedTime.format(context);
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          label,
          hint,
          controller: controller,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF073F5C)),
                const SizedBox(width: 8),
                const Text(
                  'Priority',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    color: Color(0xFF073F5C),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: const InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              border: InputBorder.none,
            ),
            items: ['High priority', 'Medium priority', 'Low priority']
                .map((priority) {
              return DropdownMenuItem<String>(
                value: priority,
                child: Text(priority),
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

  Widget _buildContactField() {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.contacts, color: Color(0xFF073F5C)),
                const SizedBox(width: 8),
                const Text(
                  'Contacts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    color: Color(0xFF073F5C),
                  ),
                ),
              ],
            ),
          ),
          if (_permissionDenied)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () async {
                  await openAppSettings();
                  _fetchContacts();
                },
                child: const Text(
                  'Permission denied. Tap to open settings',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (_contactsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
              DropdownButtonFormField<Contact>(
                value: null,
                decoration: const InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  border: InputBorder.none,
                  hintText: 'Select contacts',
                ),
                items: _allContacts.map((contact) {
                  return DropdownMenuItem<Contact>(
                    value: contact,
                    child: Text(contact.displayName),
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: _selectedContacts.map((contact) {
                    return Chip(
                      label: Text(contact.displayName),
                      onDeleted: () {
                        setState(() {
                          _selectedContacts.remove(contact);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
        ],
      ),
    );
  }
}
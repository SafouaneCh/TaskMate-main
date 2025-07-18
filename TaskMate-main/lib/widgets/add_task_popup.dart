import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart'; // Make sure contacts_service is imported
import '../widgets/task_data.dart';
import '../widgets/task_card.dart';
import '../widgets/ContactProvider.dart';

class AddTaskModal extends StatefulWidget {
  final void Function(TaskCard) onTaskAdded;

  AddTaskModal({required this.onTaskAdded});

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
  List<Contact> _allContacts = []; // To store all contacts

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    // Fetch contacts from the device
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _allContacts = contacts.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF4A5053),
                            fontFamily: 'Roboto',
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Text(
                        'Add task',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newTask = TaskCard(
                              time: _timeController.text,
                              description: _descriptionController.text,
                              priority: _selectedPriority,
                              isCompleted: false,
                              name: _nameController.text,
                              date: _dateController.text,
                              contacts: _selectedContacts.map((contact) => contact.displayName ?? '').toList(),
                            );
                            TaskManager.addTask(newTask);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Done',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFF009DFF),
                              fontSize: 22,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  _buildTextField('Task name', 'Enter your Task name', controller: _nameController, prefixIcon: Icons.task),
                  SizedBox(height: 20),
                  _buildTextField('Task description', 'Enter your Task prompt', controller: _descriptionController, prefixIcon: Icons.notes),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField('Date', '2024-09-01', controller: _dateController, prefixIcon: Icons.calendar_today),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildTimePickerField('Time', '14:00', controller: _timeController, prefixIcon: Icons.access_time),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildPriorityDropdown(),
                  SizedBox(height: 20),
                  _buildContactField('Contacts'),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newTask = TaskCard(
                            time: _timeController.text,
                            description: _descriptionController.text,
                            priority: _selectedPriority,
                            isCompleted: false,
                            name: _nameController.text,
                            date: _dateController.text,
                            contacts: _selectedContacts.map((contact) => contact.displayName ?? '').toList(),
                          );
                          TaskManager.addTask(newTask);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Color(0xFF074666),
                      ),
                      child: Text(
                        'Save task',
                        style: TextStyle(fontSize: 18, color: Colors.yellowAccent),
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

  Widget _buildTextField(String label, String hint, {required TextEditingController controller, IconData? prefixIcon, String? Function(String?)? validator}) {
    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 8.0),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Icon(prefixIcon, color: Color(0xFF073F5C)),
                SizedBox(width: 8),
                Text(
                  label,
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
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Color(0xFFB7B7B7),
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            ),
            validator: validator ?? (value) {
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

  Widget _buildDatePickerField(String label, String hint, {required TextEditingController controller, IconData? prefixIcon}) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
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
        child: _buildTextField(label, hint, controller: controller, prefixIcon: prefixIcon),
      ),
    );
  }

  Widget _buildTimePickerField(String label, String hint, {required TextEditingController controller, IconData? prefixIcon}) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
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
        child: _buildTextField(label, hint, controller: controller, prefixIcon: prefixIcon),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 8.0),
            child: Row(
              children: [
                Icon(Icons.star, color: Color(0xFF073F5C)),
                SizedBox(width: 8),
                Text(
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
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              border: InputBorder.none,
            ),
            items: ['High priority', 'Medium priority', 'Low priority'].map((priority) {
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

  Widget _buildContactField(String label) {
    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Color(0xEAECECBF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF073F5C),
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 8.0),
            child: Row(
              children: [
                Icon(Icons.contacts, color: Color(0xFF073F5C)),
                SizedBox(width: 8),
                Text(
                  label,
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
          DropdownButtonFormField<Contact>(
            value: _selectedContacts.isEmpty ? null : _selectedContacts.first,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              border: InputBorder.none,
            ),
            items: _allContacts.map((contact) {
              return DropdownMenuItem<Contact>(
                value: contact,
                child: Text(contact.displayName ?? 'Unknown'),
              );
            }).toList(),
            onChanged: (selectedContact) {
              setState(() {
                if (selectedContact != null && !_selectedContacts.contains(selectedContact)) {
                  _selectedContacts.add(selectedContact);
                }
              });
            },
            hint: Text('Select contacts'),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            children: _selectedContacts.map((contact) {
              return Chip(
                label: Text(contact.displayName ?? 'Unknown'),
                onDeleted: () {
                  setState(() {
                    _selectedContacts.remove(contact);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

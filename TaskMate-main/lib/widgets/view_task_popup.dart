import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:taskmate/widgets/task_data.dart';
import 'task_card.dart'; // Import your TaskCard class
import 'add_task_popup.dart';// Import the utility file for getTasks

class ViewTasksPopup extends StatefulWidget {
  final VoidCallback onAddTask;

  ViewTasksPopup({required this.onAddTask});

  @override
  _ViewTasksPopupState createState() => _ViewTasksPopupState();
}

class _ViewTasksPopupState extends State<ViewTasksPopup> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    // Format the current date
    String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    List<TaskCard> _tasks = TaskManager.getTasks(); // Use the getTasks function

    List<TaskCard> _filteredTasks = _tasks.where((task) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Completed') return task.isCompleted;
      return !task.isCompleted;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 1.0,
      builder: (BuildContext context, ScrollController scrollController) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 30),
                    SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(thickness: 1),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the chips
                  children: [
                    Wrap(
                      spacing: 30.0, // Adjust spacing between chips
                      children: [
                        ChoiceChip(
                          label: Text('All', style: TextStyle(fontSize: 16),),
                          selected: _selectedCategory == 'All',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded corners
                          ),
                          visualDensity: VisualDensity.compact, // Reduce inner padding
                        ),
                        ChoiceChip(
                          label: Text('Completed', style: TextStyle(fontSize: 16),),
                          selected: _selectedCategory == 'Completed',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = 'Completed';
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded corners
                          ),
                          visualDensity: VisualDensity.compact, // Reduce inner padding
                        ),
                        ChoiceChip(
                          label: Text('In progress', style: TextStyle(fontSize: 16),),
                          selected: _selectedCategory == 'In progress',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = 'Others';
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded corners
                          ),
                          visualDensity: VisualDensity.compact, // Reduce inner padding
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: _filteredTasks,
                  ),
                ),
                SizedBox(height: 16),

                Container(
                  width: 220,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF073F5C), Color(0xFF0F85C2)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: widget.onAddTask,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Color(0xFFFFF0B6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Add task',
                        style: TextStyle(
                            fontSize: 23,
                            fontFamily: 'Roboto'
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

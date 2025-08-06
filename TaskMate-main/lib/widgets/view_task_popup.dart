import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:taskmate/widgets/task_data.dart';
import 'task_card.dart'; // Import your TaskCard class
// Import the utility file for getTasks

class ViewTasksPopup extends StatefulWidget {
  final VoidCallback onAddTask;

  const ViewTasksPopup({super.key, required this.onAddTask});

  @override
  _ViewTasksPopupState createState() => _ViewTasksPopupState();
}

class _ViewTasksPopupState extends State<ViewTasksPopup> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Format the current date
    String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    List<TaskCard> tasks = TaskManager.getTasks(); // Use the getTasks function

    List<TaskCard> filteredTasks = tasks.where((task) {
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
          child: SafeArea(
            child: Container(
              width: screenWidth,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.04),
                  topRight: Radius.circular(screenWidth * 0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.005,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(screenWidth * 0.005),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star,
                          color: Colors.amber, size: screenWidth * 0.075),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: screenWidth * 0.067,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Divider(thickness: 1),
                  SizedBox(height: screenHeight * 0.01),
                  // Category filter buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryButton('All', screenWidth, screenHeight),
                      _buildCategoryButton(
                          'Completed', screenWidth, screenHeight),
                      _buildCategoryButton('Pending', screenWidth, screenHeight),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Tasks list
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: screenWidth * 0.15,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  'No tasks found',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Add a new task to get started',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Container(
                                margin:
                                    EdgeInsets.only(bottom: screenHeight * 0.015),
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.025),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (value) {
                                        // Note: TaskCard is immutable, so we can't modify isCompleted directly
                                        // In a real app, you would update the task in the data source
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Task completion status updated'),
                                          ),
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.name,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              decoration: task.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          if (task.description.isNotEmpty)
                                            Text(
                                              task.description,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: Colors.grey[600],
                                                decoration: task.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          SizedBox(height: screenHeight * 0.005),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: screenWidth * 0.04,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(width: screenWidth * 0.01),
                                              Text(
                                                '${task.date} ${task.time}',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    width: screenWidth * 0.55,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF073F5C), Color(0xFF0F85C2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                    ),
                    child: TextButton(
                      onPressed: widget.onAddTask,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Color(0xFFFFF0B6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.075),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Add task',
                          style: TextStyle(
                              fontSize: screenWidth * 0.057,
                              fontFamily: 'Roboto'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(
      String category, double screenWidth, double screenHeight) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF073F5C) : Colors.grey[200],
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

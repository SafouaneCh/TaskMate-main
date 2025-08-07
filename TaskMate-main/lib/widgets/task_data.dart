import 'task_card.dart'; // Ensure this import matches the location of your TaskCard widget

class TaskManager {
  static final List<TaskCard> _tasks = [
    TaskCard(
      time: '8 am',
      description: 'Visiting the doctor',
      priority: 'Medium priority',
      isCompleted: true,
      name: 'Doctor Appointment',
      date: '2024-09-01',
      contacts: [], // No contacts for this task
      status: 'completed',
    ),
    TaskCard(
      time: '10 am',
      description: 'Grocery shopping',
      priority: 'High priority',
      isCompleted: false,
      name: 'Grocery Shopping',
      date: '2024-09-01',
      contacts: ['Achraf', 'Emily'],
      status: 'pending',
    ),
    TaskCard(
      time: '11 am',
      description: 'Training with Aimad',
      priority: 'High priority',
      isCompleted: false,
      name: 'Training Session',
      date: '2024-09-01',
      contacts: ['Aimad', 'Akram'],
      status: 'pending',
    ),
    TaskCard(
      time: '3 pm',
      description: 'Working with Salma on the project',
      priority: 'Medium priority',
      isCompleted: false,
      name: 'Project Work',
      date: '2024-09-01',
      contacts: ['Salma', 'Emily'],
      status: 'in_progress',
    ),
    TaskCard(
      time: '5 pm',
      description: 'Meeting my friends',
      priority: 'Low priority',
      isCompleted: false,
      name: 'Friends Meetup',
      date: '2024-09-01',
      contacts: ['Badr', 'Chihab'],
      status: 'pending',
    ),
    TaskCard(
      time: '6 pm',
      description: 'Dinner with family',
      priority: 'Medium priority',
      isCompleted: true,
      name: 'Family Dinner',
      date: '2024-09-01',
      contacts: ['Chihab', 'Emily'],
      status: 'completed',
    ),
  ];

  // Getter for the list of tasks
  static List<TaskCard> getTasks() {
    return _tasks;
  }

  // Method to add a new task
  static void addTask(TaskCard task) {
    _tasks.add(task);
  }

  // Method to remove a task by index
  static void removeTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
    }
  }

  // Method to update an existing task by index
  static void updateTask(int index, TaskCard updatedTask) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index] = updatedTask;
    }
  }

  // Method to clear all tasks
  static void clearAllTasks() {
    _tasks.clear();
  }
}

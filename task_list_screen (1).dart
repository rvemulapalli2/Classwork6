// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_item_widget.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  // Add task to Firebase
  Future<void> _addTask(String taskName, String priority) async {
    await _firestore.collection('tasks').add({
      'name': taskName,
      'isCompleted': false,
      'priority': priority,
      'userId': _auth.currentUser?.uid,
    });
    _taskController.clear();
    _priorityController.clear();
  }

  // Toggle completion status
  Future<void> _toggleComplete(String taskId, bool currentStatus) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  // Delete task from Firebase
  Future<void> _deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                TextField(
                  controller: _priorityController,
                  decoration: InputDecoration(labelText: 'Priority (High, Medium, Low)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty &&
                        _priorityController.text.isNotEmpty) {
                      _addTask(_taskController.text, _priorityController.text);
                    }
                  },
                  child: Text('Add Task'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .where('userId', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskItemWidget(
                      taskName: task['name'],
                      isCompleted: task['isCompleted'],
                      priority: task['priority'],
                      onToggleComplete: () => _toggleComplete(
                        task.id,
                        task['isCompleted'],
                      ),
                      onDelete: () => _deleteTask(task.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

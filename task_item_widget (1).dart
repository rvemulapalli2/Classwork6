// lib/widgets/task_item_widget.dart

import 'package:flutter/material.dart';

class TaskItemWidget extends StatelessWidget {
  final String taskName;
  final bool isCompleted;
  final String priority; // High, Medium, or Low
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  TaskItemWidget({
    required this.taskName,
    required this.isCompleted,
    required this.priority,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;

    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.yellow;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return ListTile(
      title: Text(
        taskName,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: isCompleted,
        onChanged: (_) => onToggleComplete(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

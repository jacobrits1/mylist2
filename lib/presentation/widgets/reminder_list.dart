import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reminder_model.dart';
import '../bloc/reminder_bloc.dart';
import 'reminder_dialog.dart';

/// Widget to display a list of reminders
class ReminderList extends StatelessWidget {
  final int noteId;
  final List<ReminderModel> reminders;

  const ReminderList({
    super.key,
    required this.noteId,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reminders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReminderDialog(noteId: noteId),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Dismissible(
                key: Key('reminder_${reminder.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) {
                  if (reminder.id != null) {
                    context.read<ReminderBloc>().add(DeleteReminder(reminder.id!));
                  }
                },
                child: ListTile(
                  leading: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) {
                      if (reminder.id != null && value != null && value) {
                        context.read<ReminderBloc>().add(MarkReminderCompleted(reminder.id!));
                      }
                    },
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reminder.description.isNotEmpty)
                        Text(
                          reminder.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        'Due: ${reminder.reminderTime.toLocal()}'.split('.')[0],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReminderDialog(
                          noteId: noteId,
                          reminder: reminder,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 
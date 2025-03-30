import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reminder_model.dart';
import '../bloc/reminder_bloc.dart';

/// Dialog for creating or editing a reminder
class ReminderDialog extends StatefulWidget {
  final int noteId;
  final ReminderModel? reminder;

  const ReminderDialog({
    super.key,
    required this.noteId,
    this.reminder,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');
    _descriptionController = TextEditingController(text: widget.reminder?.description ?? '');
    _selectedDateTime = widget.reminder?.reminderTime ?? DateTime.now().add(const Duration(minutes: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final reminder = ReminderModel(
      id: widget.reminder?.id,
      noteId: widget.noteId,
      title: _titleController.text,
      description: _descriptionController.text,
      reminderTime: _selectedDateTime,
      isCompleted: widget.reminder?.isCompleted ?? false,
    );

    if (widget.reminder != null) {
      context.read<ReminderBloc>().add(UpdateReminder(reminder));
    } else {
      context.read<ReminderBloc>().add(AddReminder(reminder));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder != null ? 'Edit Reminder' : 'Add Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter reminder title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter reminder description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(
                '${_selectedDateTime.toLocal()}'.split('.')[0],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveReminder,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 
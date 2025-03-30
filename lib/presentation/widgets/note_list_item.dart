import 'package:flutter/material.dart';
import 'package:mylist2/data/models/note.dart';
import 'package:intl/intl.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;

  const NoteListItem({
    super.key,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('MMM d, yyyy').format(note.updatedAt);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content != null && note.content!.isNotEmpty)
              Text(
                note.content!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (note.noteType == 'checklist')
              const Text(
                'Checklist',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 4),
                Text(
                  note.categoryId != null ? 'Category $note.categoryId' : 'Uncategorized', 
                  style: const TextStyle(fontSize: 12)
                ),
                const Spacer(),
                Text(
                  'Last edited: $formattedDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            if (note.dueDate != null)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM d, yyyy').format(note.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: note.dueDate!.isBefore(DateTime.now())
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
        onTap: onTap ?? () {
          // Navigate to edit page with note ID
          Navigator.pushNamed(
            context,
            '/note/edit',
            arguments: note.id,
          );
        },
      ),
    );
  }
} 
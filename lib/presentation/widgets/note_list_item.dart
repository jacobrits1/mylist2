import 'package:flutter/material.dart';

class NoteListItem extends StatelessWidget {
  const NoteListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: const Text(
          'Note Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Note preview text...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 4),
                const Text('Category', style: TextStyle(fontSize: 12)),
                const Spacer(),
                Text(
                  'Last edited: Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/note/edit');
        },
      ),
    );
  }
} 
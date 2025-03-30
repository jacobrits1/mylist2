import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:mylist2/data/models/note.dart';
import 'package:mylist2/data/models/checklist_item.dart';

/// A service to handle sharing note content through various platforms
class ShareService {
  /// Share a note via WhatsApp specifically
  Future<void> shareNoteViaWhatsApp(BuildContext context, Note note, List<ChecklistItem>? checklistItems) async {
    final String content = _formatNoteContent(note, checklistItems);
    
    try {
      // Using the share method with a specific WhatsApp package name
      await Share.shareWithResult(
        content,
        subject: note.title,
        sharePositionOrigin: _getSharePosition(context),
      ).then((result) {
        // Analyze the result to see if WhatsApp was selected
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shared successfully!')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: ${e.toString()}')),
      );
    }
  }
  
  /// Format the note content for sharing
  String _formatNoteContent(Note note, List<ChecklistItem>? checklistItems) {
    final StringBuffer buffer = StringBuffer();
    
    // Add title
    buffer.writeln('${note.title}');
    buffer.writeln('-' * note.title.length);
    buffer.writeln();
    
    // Handle different note types
    if (note.noteType == 'text') {
      // For text notes, just add the content
      if (note.content != null && note.content!.isNotEmpty) {
        buffer.writeln(note.content);
      }
    } else if (note.noteType == 'checklist' && checklistItems != null) {
      // For checklist notes, format each item
      for (var item in checklistItems) {
        buffer.writeln('${item.isChecked ? '✓' : '☐'} ${item.text}');
      }
    }
    
    // Add footer with shared from information
    buffer.writeln();
    buffer.writeln('Shared from MyList2');
    
    return buffer.toString();
  }
  
  /// Get the position for the share sheet
  Rect? _getSharePosition(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    
    return box.localToGlobal(Offset.zero) & box.size;
  }
  
  /// Share a note via any available app
  Future<void> shareNote(BuildContext context, Note note, List<ChecklistItem>? checklistItems) async {
    final String content = _formatNoteContent(note, checklistItems);
    
    try {
      await Share.share(
        content,
        subject: note.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: ${e.toString()}')),
      );
    }
  }
} 
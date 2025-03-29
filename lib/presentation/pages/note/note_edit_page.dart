import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NoteEditPage extends StatefulWidget {
  const NoteEditPage({super.key});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<ChecklistItem> _checklistItems = [];
  String _selectedCategory = 'Personal';
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechInitialized = false;
  String _lastError = '';

  final List<String> _categories = ['Personal', 'Work', 'Shopping', 'Ideas'];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // Initialize speech recognition
  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) => setState(() => _lastError = error.errorMsg),
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
      );
      setState(() => _speechInitialized = available);
    } catch (e) {
      setState(() => _lastError = e.toString());
    }
  }

  // Toggle speech recognition
  void _toggleListening() async {
    if (!_speechInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (!_isListening) {
      try {
        setState(() {
          _isListening = true;
          _lastError = '';
        });
        
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _contentController.text += result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        setState(() {
          _lastError = e.toString();
          _isListening = false;
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addChecklistItem() {
    setState(() {
      _checklistItems.add(ChecklistItem(text: '', isChecked: false));
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
    });
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty || _checklistItems.isNotEmpty) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('DISCARD'),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Note'),
                    content: const Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement delete functionality
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // TODO: Implement save functionality
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Content field with voice input button
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isListening)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : null),
                        onPressed: _toggleListening,
                      ),
                    ],
                  ),
                ),
              ),
              if (_lastError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _lastError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Checklist section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Checklist',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addChecklistItem,
                          ),
                        ],
                      ),
                      ..._checklistItems.asMap().entries.map((entry) => Dismissible(
                        key: ValueKey(entry.key),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeChecklistItem(entry.key),
                        child: ChecklistItemWidget(
                          item: entry.value,
                          onChanged: (bool? value) {
                            setState(() {
                              entry.value.isChecked = value ?? false;
                            });
                          },
                          onTextChanged: (String value) {
                            entry.value.text = value;
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Checklist item model
class ChecklistItem {
  String text;
  bool isChecked;

  ChecklistItem({required this.text, required this.isChecked});
}

// Checklist item widget
class ChecklistItemWidget extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<String> onTextChanged;

  const ChecklistItemWidget({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: item.isChecked,
          onChanged: onChanged,
        ),
        Expanded(
          child: TextField(
            onChanged: onTextChanged,
            decoration: const InputDecoration(
              hintText: 'Enter item',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
} 
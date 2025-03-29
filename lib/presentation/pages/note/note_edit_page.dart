import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mylist2/data/models/checklist_item.dart';

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
  String _noteType = 'text'; // 'text' or 'checklist'
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechInitialized = false;
  String _lastError = '';
  bool _continuousMode = false;
  double _confidence = 0.0;
  TextSelection? _lastSelection;
  bool _isVoiceCommand = false;

  final List<String> _categories = ['Personal', 'Work', 'Shopping', 'Ideas'];
  final List<String> _voiceCommands = [
    'make this a checklist',
    'make this a text note',
    'add checklist item',
    'remove last item',
    'check item',
    'uncheck item',
    'change category to'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // Process voice commands
  void _processVoiceCommand(String text) {
    final lowerText = text.toLowerCase();
    
    // Note type commands
    if (lowerText.contains('make this a checklist')) {
      setState(() {
        _noteType = 'checklist';
        _isVoiceCommand = true;
      });
      _showFeedback('Changed to checklist mode');
    } else if (lowerText.contains('make this a text note')) {
      setState(() {
        _noteType = 'text';
        _isVoiceCommand = true;
      });
      _showFeedback('Changed to text mode');
    }
    
    // Checklist commands
    else if (lowerText.contains('add checklist item')) {
      if (_noteType == 'checklist') {
        _addChecklistItem();
        _isVoiceCommand = true;
        _showFeedback('Added checklist item');
      } else {
        _showFeedback('Please switch to checklist mode first');
      }
    } else if (lowerText.contains('remove last item')) {
      if (_checklistItems.isNotEmpty) {
        _removeChecklistItem(_checklistItems.length - 1);
        _isVoiceCommand = true;
        _showFeedback('Removed last item');
      }
    } else if (lowerText.contains('check item')) {
      // Extract item number if provided
      final RegExp numberRegex = RegExp(r'item (\d+)');
      final match = numberRegex.firstMatch(lowerText);
      if (match != null) {
        final itemIndex = int.parse(match.group(1)!) - 1;
        if (itemIndex >= 0 && itemIndex < _checklistItems.length) {
          setState(() {
            _checklistItems[itemIndex] = _checklistItems[itemIndex].copyWith(
              isChecked: true,
              updatedAt: DateTime.now(),
            );
          });
          _isVoiceCommand = true;
          _showFeedback('Checked item ${itemIndex + 1}');
        }
      }
    } else if (lowerText.contains('uncheck item')) {
      final RegExp numberRegex = RegExp(r'item (\d+)');
      final match = numberRegex.firstMatch(lowerText);
      if (match != null) {
        final itemIndex = int.parse(match.group(1)!) - 1;
        if (itemIndex >= 0 && itemIndex < _checklistItems.length) {
          setState(() {
            _checklistItems[itemIndex] = _checklistItems[itemIndex].copyWith(
              isChecked: false,
              updatedAt: DateTime.now(),
            );
          });
          _isVoiceCommand = true;
          _showFeedback('Unchecked item ${itemIndex + 1}');
        }
      }
    }
    
    // Category commands
    else if (lowerText.contains('change category to')) {
      for (final category in _categories) {
        if (lowerText.contains(category.toLowerCase())) {
          setState(() {
            _selectedCategory = category;
            _isVoiceCommand = true;
          });
          _showFeedback('Changed category to $category');
          break;
        }
      }
    }

    // If no command was recognized and not in continuous mode, add as content
    if (!_isVoiceCommand && !_continuousMode) {
      if (_noteType == 'checklist') {
        _addChecklistItemWithText(text);
      } else {
        _addTextContent(text);
      }
    }

    _isVoiceCommand = false;
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addChecklistItemWithText(String text) {
    setState(() {
      _checklistItems.add(ChecklistItem(
        text: text,
        isChecked: false,
        position: _checklistItems.length,
      ));
    });
  }

  void _addTextContent(String text) {
    final selection = _lastSelection ?? TextSelection.collapsed(offset: _contentController.text.length);
    final newText = _contentController.text.replaceRange(
      selection.start,
      selection.end,
      text + ' ',
    );
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length + 1,
      ),
    );
    _lastSelection = _contentController.selection;
  }

  // Initialize speech recognition
  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) => setState(() {
          _lastError = error.errorMsg;
          _isListening = false;
          _showErrorSnackBar(error.errorMsg);
        }),
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' && _continuousMode && _isListening) {
            _startListening(); // Restart listening in continuous mode
          } else if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        finalTimeout: const Duration(seconds: 5),
      );
      setState(() => _speechInitialized = available);
    } catch (e) {
      setState(() => _lastError = e.toString());
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Toggle speech recognition
  Future<void> _toggleListening() async {
    if (!_speechInitialized) {
      _showErrorSnackBar('Speech recognition not available');
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _isListening = true;
        _lastError = '';
      });
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _confidence = result.confidence;
            final text = result.recognizedWords;
            if (text.isNotEmpty) {
              _processVoiceCommand(text);
            }
          });
        },
        listenMode: _continuousMode ? stt.ListenMode.dictation : stt.ListenMode.confirmation,
        pauseFor: _continuousMode ? const Duration(seconds: 2) : const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(minutes: 5),
      );
    } catch (e) {
      setState(() {
        _lastError = e.toString();
        _isListening = false;
      });
      _showErrorSnackBar(e.toString());
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
      _checklistItems.add(ChecklistItem(
        text: '',
        isChecked: false,
        position: _checklistItems.length,
      ));
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
      // Update positions for remaining items
      for (int i = index; i < _checklistItems.length; i++) {
        _checklistItems[i] = _checklistItems[i].copyWith(position: i);
      }
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
            // Note type toggle
            IconButton(
              icon: Icon(
                _noteType == 'checklist' ? Icons.checklist : Icons.subject,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _noteType = _noteType == 'checklist' ? 'text' : 'checklist';
                });
              },
              tooltip: _noteType == 'checklist' ? 'Switch to text note' : 'Switch to checklist',
            ),
            // Voice dictation toggle
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: _toggleListening,
              tooltip: _isListening ? 'Stop dictation' : 'Start dictation',
            ),
            // Continuous mode toggle
            IconButton(
              icon: Icon(
                _continuousMode ? Icons.record_voice_over : Icons.voice_over_off,
                color: _continuousMode ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () {
                setState(() {
                  _continuousMode = !_continuousMode;
                  if (_isListening) {
                    _toggleListening(); // Restart listening with new mode
                  }
                });
              },
              tooltip: _continuousMode ? 'Disable continuous mode' : 'Enable continuous mode',
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Voice Commands'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Available voice commands:'),
                          const SizedBox(height: 8),
                          ..._voiceCommands.map((command) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('• $command'),
                          )),
                          const SizedBox(height: 16),
                          const Text('Examples:'),
                          const Text('• "Make this a checklist"'),
                          const Text('• "Add checklist item"'),
                          const Text('• "Check item 1"'),
                          const Text('• "Change category to Work"'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Voice command help',
            ),
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

              // Content based on note type
              if (_noteType == 'text')
                Stack(
                  children: [
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: const OutlineInputBorder(),
                        suffixIcon: _isListening
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _buildConfidenceIndicator(),
                              )
                            : null,
                      ),
                      maxLines: 8,
                    ),
                    if (_isListening)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Listening...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Checklist'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addChecklistItem,
                              tooltip: 'Add checklist item',
                            ),
                          ],
                        ),
                        if (_isListening)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                _buildConfidenceIndicator(),
                                const SizedBox(width: 8),
                                Text(
                                  'Listening for checklist items...',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
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
                                _checklistItems[entry.key] = entry.value.copyWith(
                                  isChecked: value ?? false,
                                  updatedAt: DateTime.now(),
                                );
                              });
                            },
                            onTextChanged: (String value) {
                              setState(() {
                                _checklistItems[entry.key] = entry.value.copyWith(
                                  text: value,
                                  updatedAt: DateTime.now(),
                                );
                              });
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

  Widget _buildConfidenceIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        value: _confidence,
        backgroundColor: Colors.grey.withOpacity(0.3),
        strokeWidth: 2,
      ),
    );
  }
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
            controller: TextEditingController(text: item.text)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: item.text.length),
              ),
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
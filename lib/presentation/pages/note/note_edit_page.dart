import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mylist2/data/models/checklist_item.dart';
import '../../bloc/reminder_bloc.dart';
import '../../bloc/note_bloc.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/note.dart';
import '../../../services/share_service.dart';
import '../../../core/di/dependency_injection.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteEditPage extends StatefulWidget {
  final int? noteId;
  
  const NoteEditPage({super.key, this.noteId});

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
  DateTime? _dueDate;
  int? _noteId;
  bool _isEditing = false;
  bool _isDirty = false;
  DateTime? _createdAt;

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
    _noteId = widget.noteId;
    _isEditing = _noteId != null;
    
    // If editing an existing note, load the note data
    if (_isEditing) {
      _loadNote();
    }
    
    // Add listeners to detect changes
    _titleController.addListener(_markDirty);
    _contentController.addListener(_markDirty);
  }
  
  void _loadNote() {
    if (_noteId != null) {
      context.read<NoteBloc>().add(LoadNote(_noteId!));
    }
  }
  
  void _markDirty() {
    setState(() {
      _isDirty = true;
    });
  }
  
  void _saveNote() {
    final note = Note(
      id: _noteId,
      title: _titleController.text.isEmpty ? 'Untitled Note' : _titleController.text,
      content: _noteType == 'text' ? _contentController.text : null,
      categoryId: _categories.indexOf(_selectedCategory) + 1,
      noteType: _noteType,
      createdAt: _createdAt,
      dueDate: _dueDate,
    );
    
    if (_isEditing) {
      context.read<NoteBloc>().add(UpdateNote(note, _checklistItems));
    } else {
      context.read<NoteBloc>().add(CreateNote(note, _checklistItems));
    }
    
    setState(() {
      _isDirty = false;
    });
  }

  @override
  void dispose() {
    // Remove listeners
    _titleController.removeListener(_markDirty);
    _contentController.removeListener(_markDirty);
    
    // Save note if changes were made
    if (_isDirty) {
      _saveNote();
    }
    
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    _speechInitialized = await _speech.initialize(
      onError: (val) => setState(() {
        _lastError = val.errorMsg;
        _isListening = false;
      }),
      onStatus: (val) {
        if (val == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
  }

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    if (!_speechInitialized) {
      _initializeSpeech();
      return;
    }

    _startListening();
  }

  void _startListening() {
    _lastSelection ??= _contentController.selection;
    setState(() {
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _confidence = result.confidence;

          if (result.recognizedWords.isNotEmpty) {
            // Check if this is a voice command
            _isVoiceCommand = _checkVoiceCommand(result.recognizedWords);

            if (!_isVoiceCommand) {
              final currentText = _contentController.text;
              final selection = _lastSelection ?? const TextSelection.collapsed(offset: 0);
              final newText =
                  currentText.replaceRange(selection.start, selection.end, result.recognizedWords);

              _contentController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: selection.start + result.recognizedWords.length,
                ),
              );

              _lastSelection = TextSelection.collapsed(
                offset: selection.start + result.recognizedWords.length,
              );
            }
          }
        });
      },
      localeId: 'en_US',
      listenMode: _continuousMode ? stt.ListenMode.dictation : stt.ListenMode.confirmation,
    );
  }

  bool _checkVoiceCommand(String text) {
    // Check if the spoken text matches a voice command
    final lowerText = text.toLowerCase();

    for (final command in _voiceCommands) {
      if (lowerText.contains(command)) {
        _executeVoiceCommand(command, lowerText);
        return true;
      }
    }

    return false;
  }

  void _executeVoiceCommand(String command, String fullText) {
    setState(() {
      _isDirty = true;
      switch (command) {
        case 'make this a checklist':
          _noteType = 'checklist';
          break;
        case 'make this a text note':
          _noteType = 'text';
          break;
        case 'add checklist item':
          if (_noteType == 'checklist') {
            _checklistItems.add(
              ChecklistItem(
                text: 'New item',
                isChecked: false,
                position: _checklistItems.length,
              ),
            );
          } else {
            _noteType = 'checklist';
            _checklistItems.add(
              ChecklistItem(
                text: 'New item',
                isChecked: false,
                position: 0,
              ),
            );
          }
          break;
        case 'remove last item':
          if (_checklistItems.isNotEmpty) {
            _checklistItems.removeLast();
          }
          break;
        case 'check item':
          // Try to check the most recently added item
          if (_checklistItems.isNotEmpty) {
            final lastUncheckedIndex = _checklistItems.lastIndexWhere((item) => !item.isChecked);
            if (lastUncheckedIndex >= 0) {
              _checklistItems[lastUncheckedIndex] = _checklistItems[lastUncheckedIndex].copyWith(
                isChecked: true,
              );
            }
          }
          break;
        case 'uncheck item':
          // Try to uncheck the most recently checked item
          if (_checklistItems.isNotEmpty) {
            final lastCheckedIndex = _checklistItems.lastIndexWhere((item) => item.isChecked);
            if (lastCheckedIndex >= 0) {
              _checklistItems[lastCheckedIndex] = _checklistItems[lastCheckedIndex].copyWith(
                isChecked: false,
              );
            }
          }
          break;
        case 'change category to':
          // Extract the category from the command
          for (final category in _categories) {
            if (fullText.toLowerCase().contains('change category to $category'.toLowerCase())) {
              _selectedCategory = category;
              break;
            }
          }
          break;
      }
    });
  }

  void _addChecklistItem() {
    setState(() {
      _isDirty = true;
      _checklistItems.add(
        ChecklistItem(
          text: '',
          isChecked: false,
          position: _checklistItems.length,
        ),
      );
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _isDirty = true;
      if (index >= 0 && index < _checklistItems.length) {
        _checklistItems.removeAt(index);
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_isDirty) {
      // Save changes automatically
      _saveNote();
      return true;
    }
    return true;
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now().add(const Duration(hours: 1))),
      );

      if (time != null) {
        setState(() {
          _isDirty = true;
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });

        // Create or update reminder when due date is set
        if (_dueDate != null) {
          BlocProvider.of<ReminderBloc>(context).add(AddReminder(
            ReminderModel(
              noteId: _noteId ?? 1, // Use the actual note ID if available
              title: _titleController.text.isNotEmpty ? _titleController.text : 'Untitled Note',
              description: _contentController.text.isNotEmpty ? _contentController.text : 'No description',
              reminderTime: _dueDate!,
            ),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteLoaded) {
            // Populate the form with note data
            setState(() {
              _titleController.text = state.note.title;
              if (state.note.noteType == 'text' && state.note.content != null) {
                _contentController.text = state.note.content!;
              }
              _noteType = state.note.noteType;
              _dueDate = state.note.dueDate;
              _createdAt = state.note.createdAt;
              _noteId = state.note.id;
              
              if (state.note.categoryId != null && 
                  state.note.categoryId! > 0 && 
                  state.note.categoryId! <= _categories.length) {
                _selectedCategory = _categories[state.note.categoryId! - 1];
              }
              
              // If it's a checklist, load the checklist items
              if (state.note.noteType == 'checklist') {
                _checklistItems.clear();
                _checklistItems.addAll(state.checklistItems);
              }
              
              _isDirty = false;
            });
          } else if (state is NoteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is NoteLoading && _isEditing) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          return Scaffold(
            appBar: AppBar(
              title: Text(_isEditing ? 'Edit Note' : 'New Note'),
              actions: [
                // Note type toggle
                IconButton(
                  icon: Icon(
                    _noteType == 'checklist' ? Icons.checklist : Icons.subject,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDirty = true;
                      _noteType = _noteType == 'checklist' ? 'text' : 'checklist';
                    });
                  },
                  tooltip: _noteType == 'checklist' ? 'Switch to text note' : 'Switch to checklist',
                ),
                // Share button with WhatsApp option
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share note',
                  onPressed: () {
                    _showShareOptions(context);
                  },
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
                    });
                  },
                  tooltip: _continuousMode ? 'Disable continuous mode' : 'Enable continuous mode',
                ),
                if (_isEditing)
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
                                if (_noteId != null) {
                                  context.read<NoteBloc>().add(DeleteNote(_noteId!));
                                }
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
                    _saveNote();
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

                  // Due date field
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(
                      _dueDate != null
                          ? '${_dueDate!.toLocal()}'.split('.')[0]
                          : 'No due date set',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() {
                              _isDirty = true;
                              _dueDate = null;
                            }),
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDueDate,
                        ),
                      ],
                    ),
                    onTap: _selectDueDate,
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
                          _isDirty = true;
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Checklist',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addChecklistItem,
                              tooltip: 'Add item',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
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
                                          _isDirty = true;
                                          _checklistItems[entry.key] = entry.value.copyWith(
                                            isChecked: value ?? false,
                                            updatedAt: DateTime.now(),
                                          );
                                        });
                                      },
                                      onTextChanged: (String value) {
                                        setState(() {
                                          _isDirty = true;
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
                      ],
                    ),
                ],
              ),
            ),
          );
        },
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

  // Share options dialog
  void _showShareOptions(BuildContext context) {
    final shareService = getIt<ShareService>();
    
    // Create a Note object from the current state
    final note = Note(
      id: _noteId,
      title: _titleController.text.isEmpty ? 'Untitled Note' : _titleController.text,
      content: _contentController.text,
      categoryId: _categories.indexOf(_selectedCategory) + 1, // Assuming categories start from ID 1
      noteType: _noteType,
      dueDate: _dueDate,
    );
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Share options'),
              tileColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Color(0xFF25D366)), // WhatsApp green color
              title: const Text('Share via WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                shareService.shareNoteViaWhatsApp(context, note, _checklistItems);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share via other apps'),
              onTap: () {
                Navigator.pop(context);
                shareService.shareNote(context, note, _checklistItems);
              },
            ),
          ],
        ),
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
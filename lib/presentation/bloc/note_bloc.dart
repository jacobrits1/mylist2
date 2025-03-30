import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/note.dart';
import '../../data/models/checklist_item.dart';
import '../../data/repositories/note_repository.dart';

// Events
abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNote extends NoteEvent {
  final int id;

  const LoadNote(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadAllNotes extends NoteEvent {}

class CreateNote extends NoteEvent {
  final Note note;
  final List<ChecklistItem> checklistItems;

  const CreateNote(this.note, [this.checklistItems = const []]);

  @override
  List<Object?> get props => [note, checklistItems];
}

class UpdateNote extends NoteEvent {
  final Note note;
  final List<ChecklistItem> checklistItems;

  const UpdateNote(this.note, [this.checklistItems = const []]);

  @override
  List<Object?> get props => [note, checklistItems];
}

class DeleteNote extends NoteEvent {
  final int id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final Note note;
  final List<ChecklistItem> checklistItems;

  const NoteLoaded(this.note, [this.checklistItems = const []]);

  @override
  List<Object?> get props => [note, checklistItems];
}

class NotesLoaded extends NoteState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository _repository;

  NoteBloc(this._repository) : super(NoteInitial()) {
    on<LoadNote>(_onLoadNote);
    on<LoadAllNotes>(_onLoadAllNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNote(LoadNote event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final note = await _repository.getNoteById(event.id);
      if (note != null) {
        final checklistItems = note.noteType == 'checklist' 
            ? await _repository.getChecklistItemsByNoteId(note.id!)
            : const <ChecklistItem>[];
        emit(NoteLoaded(note, checklistItems));
      } else {
        emit(const NoteError('Note not found'));
      }
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onLoadAllNotes(LoadAllNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await _repository.getAllNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NoteState> emit) async {
    try {
      final noteId = await _repository.insertNote(event.note);
      
      // Save checklist items if it's a checklist note
      if (event.note.noteType == 'checklist' && event.checklistItems.isNotEmpty) {
        // Update checklist items with the new note ID and save them
        final items = event.checklistItems.map((item) => 
          item.copyWith(noteId: noteId)).toList();
        await _repository.saveChecklistItems(noteId, items);
      }
      
      // Load the created note with updated ID
      final createdNote = await _repository.getNoteById(noteId);
      if (createdNote != null) {
        final checklistItems = createdNote.noteType == 'checklist' 
            ? await _repository.getChecklistItemsByNoteId(noteId)
            : const <ChecklistItem>[];
        emit(NoteLoaded(createdNote, checklistItems));
      }
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    try {
      // Update the note
      await _repository.updateNote(event.note.copyWith(
        updatedAt: DateTime.now()
      ));
      
      // Handle checklist items if it's a checklist note
      if (event.note.noteType == 'checklist' && event.note.id != null) {
        await _repository.saveChecklistItems(event.note.id!, event.checklistItems);
      }
      
      // Reload the updated note
      final updatedNote = await _repository.getNoteById(event.note.id!);
      if (updatedNote != null) {
        final checklistItems = updatedNote.noteType == 'checklist' 
            ? await _repository.getChecklistItemsByNoteId(updatedNote.id!)
            : const <ChecklistItem>[];
        emit(NoteLoaded(updatedNote, checklistItems));
      }
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await _repository.deleteNote(event.id);
      
      // Load all notes after deletion
      final notes = await _repository.getAllNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
} 
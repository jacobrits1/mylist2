import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../services/notification_service.dart';

// Events
abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddReminder extends ReminderEvent {
  final ReminderModel reminder;

  const AddReminder(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class UpdateReminder extends ReminderEvent {
  final ReminderModel reminder;

  const UpdateReminder(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class DeleteReminder extends ReminderEvent {
  final int id;

  const DeleteReminder(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkReminderCompleted extends ReminderEvent {
  final int id;

  const MarkReminderCompleted(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class RemindersLoaded extends ReminderState {
  final List<ReminderModel> reminders;

  const RemindersLoaded(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  ReminderBloc(this._repository, this._notificationService) : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<MarkReminderCompleted>(_onMarkReminderCompleted);
  }

  Future<void> _onLoadReminders(LoadReminders event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading());
    try {
      final reminders = await _repository.getAllReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(AddReminder event, Emitter<ReminderState> emit) async {
    try {
      final id = await _repository.addReminder(event.reminder);
      final updatedReminder = event.reminder.copyWith(id: id);
      await _notificationService.scheduleReminderNotification(updatedReminder);
      
      final reminders = await _repository.getAllReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdateReminder(UpdateReminder event, Emitter<ReminderState> emit) async {
    try {
      await _repository.updateReminder(event.reminder);
      if (event.reminder.id != null) {
        await _notificationService.cancelNotification(event.reminder.id!);
        await _notificationService.scheduleReminderNotification(event.reminder);
      }
      
      final reminders = await _repository.getAllReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(DeleteReminder event, Emitter<ReminderState> emit) async {
    try {
      await _repository.deleteReminder(event.id);
      await _notificationService.cancelNotification(event.id);
      
      final reminders = await _repository.getAllReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onMarkReminderCompleted(MarkReminderCompleted event, Emitter<ReminderState> emit) async {
    try {
      await _repository.markReminderAsCompleted(event.id);
      await _notificationService.cancelNotification(event.id);
      
      final reminders = await _repository.getAllReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
} 
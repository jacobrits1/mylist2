import 'package:get_it/get_it.dart';
import '../../data/sources/local/database_helper.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/note_repository.dart';
import '../../services/notification_service.dart';
import '../../services/share_service.dart';
import '../../presentation/blocs/category/category_bloc.dart';
import '../../presentation/bloc/reminder_bloc.dart';
import '../../presentation/bloc/note_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Database
  final databaseHelper = DatabaseHelper();
  final database = await databaseHelper.database;
  getIt.registerSingleton(database);
  getIt.registerSingleton(databaseHelper);

  // Repositories
  getIt.registerLazySingleton(() => CategoryRepository(databaseHelper: getIt()));
  getIt.registerLazySingleton(() => ReminderRepository(getIt()));
  getIt.registerLazySingleton(() => NoteRepository(getIt()));

  // Services
  final notificationService = NotificationService();
  await notificationService.initialize();
  getIt.registerSingleton(notificationService);
  getIt.registerLazySingleton(() => ShareService());

  // Blocs
  getIt.registerFactory(() => CategoryBloc(categoryRepository: getIt()));
  getIt.registerFactory(() => ReminderBloc(getIt(), getIt()));
  getIt.registerFactory(() => NoteBloc(getIt()));
} 
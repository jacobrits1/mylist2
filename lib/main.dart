import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mylist2/data/repositories/category_repository.dart';
import 'package:mylist2/data/sources/local/database_helper.dart';
import 'package:mylist2/presentation/blocs/category/category_bloc.dart';
import 'package:mylist2/presentation/blocs/category/category_event.dart';
import 'package:mylist2/presentation/pages/home/home_page.dart';
import 'package:mylist2/presentation/pages/note/note_edit_page.dart';
import 'package:mylist2/core/themes/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await setupDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetIt.I<CategoryBloc>()..add(LoadCategories()),
        ),
      ],
      child: MaterialApp(
        title: 'MyList2',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/note/edit': (context) => const NoteEditPage(),
        },
      ),
    );
  }
}

Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  
  // Register database helper
  getIt.registerLazySingleton(() => DatabaseHelper());
  
  // Register repositories
  getIt.registerLazySingleton(() => CategoryRepository(
    databaseHelper: getIt<DatabaseHelper>(),
  ));
  
  // Register blocs
  getIt.registerFactory(() => CategoryBloc(
    categoryRepository: getIt<CategoryRepository>(),
  ));
}

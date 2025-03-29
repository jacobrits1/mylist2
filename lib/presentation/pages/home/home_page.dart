import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylist2/data/models/category.dart';
import 'package:mylist2/presentation/blocs/category/category_bloc.dart';
import 'package:mylist2/presentation/blocs/category/category_event.dart';
import 'package:mylist2/presentation/blocs/category/category_state.dart';
import 'package:mylist2/presentation/widgets/note_list_item.dart';
import 'package:mylist2/presentation/widgets/search_bar.dart';
import 'package:mylist2/presentation/widgets/category_dialog.dart';

// HomeScreen widget that displays the list of notes with category filtering
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController? _tabController;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    // Load categories when the page is initialized
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabController(List<Category> categories) {
    _tabController?.dispose();
    _tabController = TabController(
      length: categories.length + 1, // +1 for "All" tab
      vsync: this,
    );
    _categories = categories;
  }

  void _showCategoryDialog([Category? category]) async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => CategoryDialog(category: category),
    );

    if (result != null) {
      if (!mounted) return;
      
      if (category == null) {
        context.read<CategoryBloc>().add(AddCategory(result));
      } else {
        context.read<CategoryBloc>().add(UpdateCategory(result));
      }
    }
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? Notes in this category will be uncategorized.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CategoryBloc>().add(DeleteCategory(category.id!));
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          _updateTabController(state.categories);
        }
      },
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoryError) {
          return Scaffold(
            body: Center(child: Text('Error: ${state.message}')),
          );
        }

        if (_tabController == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('MyList'),
            actions: [
              IconButton(
                icon: const Icon(Icons.category),
                onPressed: () => _showCategoryDialog(),
                tooltip: 'Add Category',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                const Tab(text: 'All'),
                ..._categories.map((category) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.name),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _showCategoryDialog(category),
                          child: const Icon(Icons.edit, size: 16),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _deleteCategory(category),
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search bar with Material 3 design
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MySearchBar(
                  onSearch: (query) {
                    // TODO: Implement search functionality
                  },
                ),
              ),
              // Tab view for different categories
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const NotesListView(category: null), // All notes
                    ..._categories.map((category) {
                      return NotesListView(category: category);
                    }),
                  ],
                ),
              ),
            ],
          ),
          // FAB for adding new notes
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/note/edit');
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// NotesListView widget to display the list of notes
class NotesListView extends StatelessWidget {
  final Category? category;

  const NotesListView({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 10, // TODO: Replace with actual notes count
      itemBuilder: (context, index) {
        return const NoteListItem(); // TODO: Pass actual note data
      },
    );
  }
} 
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

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Category? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    // Load categories when the page is initialized
    context.read<CategoryBloc>().add(LoadCategories());
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

  void _showCategoriesMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add New Category'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryDialog();
              },
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pop(context);
                            _showCategoryDialog(category);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteCategory(category);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        // Show categories menu
        _showCategoriesMenu(context);
      } else {
        _selectedIndex = index;
        if (index == 0) {
          _selectedCategory = null;
        } else if (index == 2) {
          Navigator.pushNamed(context, '/note/edit');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          setState(() {
            _categories = state.categories;
          });
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

        return Scaffold(
          appBar: AppBar(
            title: Text(_selectedCategory?.name ?? 'All Notes'),
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
              // Notes list view for selected category
              Expanded(
                child: NotesListView(category: _selectedCategory),
              ),
            ],
          ),
          // Bottom Navigation Bar
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.notes),
                label: 'All Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.category),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                label: 'Quick Add',
              ),
            ],
          ),
          // FAB for adding new notes (hidden when on Quick Add tab)
          floatingActionButton: _selectedIndex != 2 ? FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/note/edit');
            },
            child: const Icon(Icons.add),
          ) : null,
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
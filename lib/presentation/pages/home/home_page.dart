import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylist2/data/models/category.dart';
import 'package:mylist2/data/models/note.dart';
import 'package:mylist2/presentation/blocs/category/category_bloc.dart';
import 'package:mylist2/presentation/blocs/category/category_event.dart';
import 'package:mylist2/presentation/blocs/category/category_state.dart';
import 'package:mylist2/presentation/bloc/note_bloc.dart';
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
  List<Note> _notes = [];
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // Load categories when the page is initialized
    context.read<CategoryBloc>().add(LoadCategories());
    // Load all notes
    context.read<NoteBloc>().add(LoadAllNotes());
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

  void _deleteCategoryAlert(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (category.id != null) {
                context.read<CategoryBloc>().add(DeleteCategory(category.id!));
              }
              Navigator.of(context).pop();
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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Categories',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pop(context);
                _showCategoryDialog();
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: category.description != null
                      ? Text(
                          category.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
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
                          _deleteCategoryAlert(category);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedCategory = category;
                      _selectedIndex = 0; // Keep on home tab, but filter by category
                    });
                    // Filter notes by the selected category
                    _filterNotes();
                  },
                );
              },
            ),
          ),
        ],
      ),
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
          // Reload all notes when clearing the category filter
          context.read<NoteBloc>().add(LoadAllNotes());
        } else if (index == 2) {
          Navigator.pushNamed(context, '/note/edit').then((_) {
            // Reload notes when returning from the note edit page
            context.read<NoteBloc>().add(LoadAllNotes());
          });
        }
      }
    });
  }

  void _filterNotes() {
    if (_selectedCategory != null && _selectedCategory!.id != null) {
      // This is a placeholder since we don't have a method to filter by category in the NoteBloc yet
      // Ideally, you would add a FilterNotesByCategory event to the NoteBloc
      context.read<NoteBloc>().add(LoadAllNotes());
    } else {
      context.read<NoteBloc>().add(LoadAllNotes());
    }
  }

  void _onSearchChanged(String? query) {
    setState(() {
      _searchQuery = query;
    });
    // Implement search functionality (would need to add a SearchNotes event to NoteBloc)
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

        return BlocConsumer<NoteBloc, NoteState>(
          listener: (context, noteState) {
            if (noteState is NotesLoaded) {
              setState(() {
                _notes = noteState.notes;
                
                // Filter by category if one is selected
                if (_selectedCategory != null && _selectedCategory!.id != null) {
                  _notes = _notes.where((note) => 
                    note.categoryId == _selectedCategory!.id).toList();
                }
                
                // Filter by search query if one is present
                if (_searchQuery != null && _searchQuery!.isNotEmpty) {
                  _notes = _notes.where((note) => 
                    note.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
                    (note.content != null && 
                      note.content!.toLowerCase().contains(_searchQuery!.toLowerCase()))
                  ).toList();
                }
              });
            }
          },
          builder: (context, noteState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(_selectedCategory == null
                    ? 'All Notes'
                    : '${_selectedCategory!.name} Notes'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: AppSearchDelegate(
                          onSearchChanged: _onSearchChanged,
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: noteState is NoteLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.note_alt_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notes found',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Create Note'),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/note/edit')
                                    .then((_) {
                                      // Reload notes when returning
                                      context.read<NoteBloc>().add(LoadAllNotes());
                                    });
                                },
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            return NoteListItem(
                              note: _notes[index],
                              onTap: () {
                                // Navigate to edit page with note ID
                                Navigator.pushNamed(
                                  context,
                                  '/note/edit',
                                  arguments: _notes[index].id,
                                ).then((_) {
                                  // Reload notes when returning
                                  context.read<NoteBloc>().add(LoadAllNotes());
                                });
                              },
                            );
                          },
                        ),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: 'Categories',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline),
                    label: 'Add',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            );
          },
        );
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylist2/presentation/widgets/note_list_item.dart';
import 'package:mylist2/presentation/widgets/search_bar.dart';

// HomeScreen widget that displays the list of notes with category filtering
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Personal', 'Work', 'Shopping', 'Ideas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyList'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
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
              children: _categories.map((category) {
                return NotesListView(category: category);
              }).toList(),
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
  }
}

// NotesListView widget to display the list of notes
class NotesListView extends StatelessWidget {
  final String category;

  const NotesListView({super.key, required this.category});

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
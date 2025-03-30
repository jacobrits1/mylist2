import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const MySearchBar({super.key, required this.onSearch});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  bool _showFilters = false;
  final Set<String> _selectedFilters = {'All'};
  final List<String> _filters = ['All', 'Title', 'Content', 'Checklist'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _showFilters ? 0.5 : 0,
                child: const Icon(Icons.filter_list),
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ],
          hintText: 'Search notes...',
          onChanged: widget.onSearch,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          elevation: const MaterialStatePropertyAll<double>(0),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showFilters ? 50.0 : 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilters.contains(filter);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    onSelected: (bool selected) {
                      setState(() {
                        if (filter == 'All') {
                          _selectedFilters.clear();
                          if (selected) {
                            _selectedFilters.add('All');
                          }
                        } else {
                          if (selected) {
                            _selectedFilters.remove('All');
                            _selectedFilters.add(filter);
                          } else {
                            _selectedFilters.remove(filter);
                            if (_selectedFilters.isEmpty) {
                              _selectedFilters.add('All');
                            }
                          }
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// A search delegate for searching notes
class AppSearchDelegate extends SearchDelegate<String> {
  final Function(String?) onSearchChanged;

  AppSearchDelegate({required this.onSearchChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged(null);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchChanged(query);
    return Container(); // The actual results will be shown in the main page
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      onSearchChanged(query);
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.search,
          size: 64,
          color: Colors.grey.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          query.isEmpty ? 'Enter search term' : 'Searching for "$query"...',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
} 
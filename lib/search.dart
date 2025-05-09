import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await supabase
        .from('post')
        .select(
          'id, item_name, item_image_url, post_description, status, created_at, category:cat_id(cat_name)',
        )
        .ilike('item_name', '%$query%')
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'We Can\'t find the data';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _searchResults = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildResultItem(Map<String, dynamic> post) {
    final category = post['category'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading:
            post['item_image_url'] != null &&
                    (post['item_image_url'] as String).isNotEmpty
                ? Image.network(
                  post['item_image_url'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
        title: Text(post['item_name'] ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post['post_description'] != null)
              Text(post['post_description']),
            if (category != null && category['cat_name'] != null)
              Text('Category: ${category['cat_name']}'),
            if (post['status'] != null)
              Text('Status: ${post['status'].toString().toUpperCase()}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Posts'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by item name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _performSearch(_searchController.text.trim());
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) {
                _performSearch(value.trim());
              },
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_searchResults.isEmpty)
              const Text('No results found')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildResultItem(_searchResults[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

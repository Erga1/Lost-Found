import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in.');
      }

      final response = await supabase
          .from('post')
          .select(
            'id, created_at, status, item_name, item_image_url, post_description, category:cat_id(cat_name)',
          )
          .eq('user_id', user.id) // Filter by current user's ID
          .order('created_at', ascending: false); // Order by creation time

      setState(() {
        _userPosts.addAll(response.cast<Map<String, dynamic>>());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching posts: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching posts: $e');
    }
  }

  Future<void> _updatePost(Map<String, dynamic> post) async {
    print('Attempting to update post with ID: ${post['id']}');

    // Example: Navigate to an update screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
    );

    if (result == true) {
      // If the edit screen indicates a successful update, refresh the list
      _fetchUserPosts();
    }
  }

  Future<void> _deletePost(int postId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                try {
                  await supabase.from('post').delete().eq('id', postId);
                  _fetchUserPosts(); // Refresh the list after deletion
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Error deleting post: ${e.toString()}';
                    _isLoading = false;
                  });
                  print('Error deleting post: $e');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posts')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchUserPosts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : _userPosts.isEmpty
              ? const Center(child: Text('You have no posts yet.'))
              : ListView.builder(
                itemCount: _userPosts.length,
                itemBuilder: (context, index) {
                  final post = _userPosts[index];
                  final Map<String, dynamic>? category =
                      post['category'] as Map<String, dynamic>?;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Action Buttons (Update & Delete) on the most left
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _updatePost(post),
                                tooltip: 'Edit Post',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deletePost(post['id']),
                                tooltip: 'Delete Post',
                              ),
                            ],
                          ),
                          const SizedBox(width: 10), // Spacing
                          // Post Image
                          if (post['item_image_url'] != null &&
                              post['item_image_url'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                post['item_image_url'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 100,
                                  );
                                },
                              ),
                            )
                          else
                            const Icon(Icons.image_not_supported, size: 100),
                          const SizedBox(width: 10), // Spacing
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['item_name'] ?? 'No Item Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Status: ${post['status'] ?? 'N/A'}'),
                                const SizedBox(height: 4),
                                Text(
                                  post['post_description'] ?? 'No description',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                if (category != null &&
                                    category['cat_name'] != null)
                                  Text(
                                    'Category: ${category['cat_name'] ?? 'N/A'}',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class EditPostScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _itemNameController;
  late TextEditingController _postDescriptionController;
  late TextEditingController _itemImageUrlController;
  String? _selectedStatus;
  int? _selectedCategoryId; // For foreign key

  bool _isSaving = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _categories =
      []; // To fetch categories for dropdown

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.post['item_name']);
    _postDescriptionController = TextEditingController(
      text: widget.post['post_description'],
    );
    _itemImageUrlController = TextEditingController(
      text: widget.post['item_image_url'],
    );
    _selectedStatus = widget.post['status'];
    _selectedCategoryId = widget.post['cat_id'];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await supabase.from('category').select('id, cat_name');
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _errorMessage = 'Error loading categories.';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedPost = {
        'item_name': _itemNameController.text,
        'post_description': _postDescriptionController.text,
        'item_image_url': _itemImageUrlController.text,
        'status': _selectedStatus,
        'cat_id': _selectedCategoryId,
      };

      await supabase
          .from('post')
          .update(updatedPost)
          .eq('id', widget.post['id']);

      if (mounted) {
        Navigator.of(context).pop(true); // Indicate successful update
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating post: ${e.toString()}';
        _isSaving = false;
      });
      print('Error updating post: $e');
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _postDescriptionController.dispose();
    _itemImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Post Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter post description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemImageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items:
                    <String>['lost', 'found'].map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_categories.isEmpty && _errorMessage == null)
                const CircularProgressIndicator()
              else if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red))
              else
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      _categories.map<DropdownMenuItem<int>>((
                        Map<String, dynamic> category,
                      ) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['cat_name']),
                        );
                      }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
                  ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

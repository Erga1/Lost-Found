import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  String? _status; // 'lost' or 'found'
  String? _itemName;
  String? _postDescription;
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  File? _pickedImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await supabase.from('category').select('id, cat_name');
    if (response.isEmpty) {
      debugPrint('Failed to load categories');
      return;
    }
    setState(() {
      _categories = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    final fileName =
        'posts/${DateTime.now().millisecondsSinceEpoch}_${_pickedImage!.path.split('/').last}';

    try {
      final response = await supabase.storage
          .from('image')
          .upload(fileName, _pickedImage!);

      final publicUrl = supabase.storage.from('image').getPublicUrl(fileName);
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('StorageException during image upload: ${e.message}');
      setState(() {
        _errorMessage = 'Image upload failed: ${e.message}';
      });
      return null; // Return null to indicate failure
    } catch (e) {
      debugPrint('An unexpected error occurred during image upload: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred during image upload.';
      });
      return null; // Return null for any other unexpected errors
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_status == null) {
      setState(() {
        _errorMessage = 'Please select status (lost/found).';
      });
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Please select a category.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    _formKey.currentState!.save();

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage();
        // Only show error if an image was picked but failed to upload
        if (imageUrl == null) {
          setState(() {
            _errorMessage = 'Image upload failed. Please try again.';
            _isSubmitting = false;
          });
          return; // Stop submission if upload failed
        }
      }

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _errorMessage = 'User is not logged in.';
          _isSubmitting = false;
        });
        return;
      }

      try {
        await supabase.from('post').insert({
          'status': _status,
          'item_name': _itemName,
          'item_image_url':
              imageUrl, // This will be null if no image was picked
          'post_description': _postDescription,
          'user_id': userId,
          'cat_id': _selectedCategoryId,
        });

        // If no exception is thrown, the insert was successful
        setState(() {
          _isSubmitting = false;
        });

        // On success, go back
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPostPage()),
        );
      } on PostgrestException catch (e) {
        debugPrint('PostgrestException during post insert: ${e.message}');
        setState(() {
          _errorMessage = 'Failed to create post: ${e.message}';
          _isSubmitting = false;
        });
        return; // Stop execution here as the post failed
      }
    } catch (e) {
      debugPrint('Unexpected error in _submitForm: $e');
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Post')),
      body:
          _categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'lost', child: Text('Lost')),
                          DropdownMenuItem(
                            value: 'found',
                            child: Text('Found'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value;
                          });
                        },
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please select lost or found'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) => _itemName = value?.trim(),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter item name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Post Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        onSaved: (value) => _postDescription = value?.trim(),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter post description'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat['id'] as int,
                                child: Text(cat['cat_name'].toString()),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a category'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child:
                              _pickedImage == null
                                  ? const Center(
                                    child: Text('Tap to select an image'),
                                  )
                                  : Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Submit Post'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

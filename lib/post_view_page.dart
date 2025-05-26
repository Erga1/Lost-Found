import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  final int _fetchLimit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchPosts();
      }
    });
  }

  Future<void> _fetchPosts() async {
    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final from = _page * _fetchLimit;
    final to = from + _fetchLimit - 1;

    final response = await supabase
        .from('post')
        .select(
          'id, created_at, status, item_name, item_image_url, post_description, category:cat_id(cat_name)',
        )
        .order('created_at', ascending: false)
        .range(from, to);

    if (response.isEmpty) {
      debugPrint('Error loading posts');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final List<dynamic> data = List<dynamic>.from(response);

    setState(() {
      if (data.length < _fetchLimit) {
        _hasMore = false;
      }
      _posts.addAll(data.cast<Map<String, dynamic>>());
      _page++;
      _isLoading = false;
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
      _page = 0;
      _hasMore = true;
    });
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body:
          _posts.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _refreshPosts,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _posts.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final post = _posts[index];
                    final Map<String, dynamic>? category =
                        post['category'] as Map<String, dynamic>?;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post['item_image_url'] != null &&
                                (post['item_image_url'] as String).isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post['item_image_url'],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              post['item_name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              post['post_description'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        post['status'] == 'lost'
                                            ? Colors.red[100]
                                            : Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    post['status']?.toString().toUpperCase() ??
                                        '',
                                    style: TextStyle(
                                      color:
                                          post['status'] == 'lost'
                                              ? Colors.red[800]
                                              : Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (category != null &&
                                    category['cat_name'] != null)
                                  Chip(
                                    label: Text(category['cat_name']),
                                    backgroundColor: Colors.blue[100],
                                  ),
                                const Spacer(),
                                Text(
                                  _formatDate(post['created_at']),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

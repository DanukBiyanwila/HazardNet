import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:frontend/pages/add_social_post_page.dart';
import 'package:frontend/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocialPostManagementPage extends StatefulWidget {
  const SocialPostManagementPage({super.key});

  @override
  State<SocialPostManagementPage> createState() => _SocialPostManagementPageState();
}

class _SocialPostManagementPageState extends State<SocialPostManagementPage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      debugPrint('Fetching posts from: ${AppConstants.baseUrl}/api/media_report/');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/media_report/'),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching posts: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(int id) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/api/media_report/$id'),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
        _fetchPosts(); // Refresh list
      } else {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Post Management'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('No posts found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final uploadTime = DateTime.tryParse(post['upload_time'] ?? '');
                    final formattedTime = uploadTime != null 
                        ? DateFormat('yyyy-MM-dd HH:mm').format(uploadTime)
                        : 'Unknown time';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              if (post['media_url'] != null && post['media_url'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.network(
                                    post['media_url'].toString().startsWith('http') 
                                      ? post['media_url'] 
                                      : '${AppConstants.baseUrl}/uploads/reports/${post['media_url']}',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                                          const SizedBox(height: 8),
                                          const Text('Image not available', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _confirmDelete(post['id']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post['title'] ?? 'No Title',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _getHazardColor(post['hazard_type']),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        post['hazard_type'] ?? 'UNKNOWN',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post['dis'] ?? 'No description provided.',
                                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Time: $formattedTime',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    Text(
                                      'Status: ${post['status']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: post['status'] == 'PENDING' ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSocialPostPage()),
          );
          if (result == true) {
            _fetchPosts();
          }
        },
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getHazardColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'FLOOD': return Colors.blue;
      case 'FIRE': return Colors.red;
      case 'EARTHQUAKE': return Colors.brown;
      case 'LANDSLIDE': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }
}

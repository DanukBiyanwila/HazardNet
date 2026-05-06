import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/home_safety_page.dart';
import 'package:frontend/pages/new_home_register_page.dart';

class HomeListPage extends StatefulWidget {
  const HomeListPage({super.key});

  @override
  State<HomeListPage> createState() => _HomeListPageState();
}

class _HomeListPageState extends State<HomeListPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _homes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHomes();
  }

  Future<void> _fetchHomes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) {
        setState(() {
          _error = 'User not authenticated. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse('${AppConstants.baseUrl}/api/home/by_user/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _homes = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load homes: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHome(int id) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/home/$id');

      final response = await http.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          setState(() {
            _homes.removeWhere((home) => home['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Home deleted successfully')),
          );
        }
      } else {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting home: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete home')),
        );
        _fetchHomes(); // Refresh on error to restore state
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homes'),
        actions: [
          IconButton(
            onPressed: _fetchHomes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewHomeRegisterPage()),
          );
          _fetchHomes(); // Refresh list after adding a new home
        },
        label: const Text('Add New Home'),
        icon: const Icon(Icons.add_home_work_outlined),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchHomes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _homes.isEmpty
                  ? const Center(
                      child: Text('No homes registered yet. Add one to get started!'),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchHomes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _homes.length,
                        itemBuilder: (context, index) {
                          final home = _homes[index];
                          final String address = home['address'] ?? 'No Address';
                          final String imageUrl = home['imageUrl'] != null && home['imageUrl'] != ""
                              ? '${AppConstants.baseUrl}/uploads/homes/${home['imageUrl']}'
                              : 'https://picsum.photos/seed/home${home['id']}/800/600';

                          return Dismissible(
                            key: Key(home['id'].toString()),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this home?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              _deleteHome(home['id']);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeSafetyPage(
                                        home: home,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      imageUrl,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 150,
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.home_work, size: 64, color: Colors.grey),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  address,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Added: ${home['created_at']}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Family: ${home['family_count']} | River: ${home['near_river_km']} km',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios, size: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

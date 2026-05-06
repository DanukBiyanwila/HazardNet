import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/sos_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _trustedPersons = [];
  List<dynamic> _communityPosts = [];
  final Map<int, Map<String, dynamic>> _userCache = {};
  bool _isLoadingContacts = true;
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _fetchTrustedContacts();
    _fetchCommunityPosts();
  }

  Future<void> _fetchTrustedContacts() async {
    setState(() => _isLoadingContacts = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/trusted_contacts/by_user/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _trustedPersons = jsonDecode(response.body);
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      setState(() => _isLoadingContacts = false);
    }
  }

  Future<void> _fetchCommunityPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/media_report/');
      
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> posts = jsonDecode(response.body);
        
        // Fetch user data for all unique user IDs
        Set<int> userIds = posts.map((p) => p['userId'] as int).toSet();
        for (int id in userIds) {
          if (!_userCache.containsKey(id)) {
            await _fetchUserData(id, token);
          }
        }

        setState(() {
          _communityPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _fetchUserData(int userId, String? token) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/api/user/$userId');
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _userCache[userId] = {
          'name': userData['name'] ?? 'Unknown User',
          'imageUrl': userData['imageUrl'],
        };
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:${phoneNumber.trim()}');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Call Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _fetchTrustedContacts();
              _fetchCommunityPosts();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrustedPersonsSection(),
              const SizedBox(height: 24),
              _buildCommunityPostsSection(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SOSPage()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos, size: 36, color: Colors.white),
      ),
    );
  }

  Widget _buildCommunityPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Community Posts',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _isLoadingPosts
            ? const Center(child: CircularProgressIndicator())
            : _communityPosts.isEmpty
                ? const Text('No community posts found.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _communityPosts.length,
                    itemBuilder: (context, index) {
                      final post = _communityPosts[index];
                      final int userId = post['userId'];
                      final user = _userCache[userId];
                      final String userName = user?['name'] ?? 'User $userId';
                      final String? authorImageUrl = user?['imageUrl'];
                      
                      final uploadTime = DateTime.tryParse(post['upload_time'] ?? '');
                      final String timeStr = uploadTime != null 
                          ? DateFormat('yyyy-MM-dd HH:mm').format(uploadTime)
                          : 'Unknown time';

                      final String? mediaUrl = post['media_url'];
                      final String fullImageUrl = (mediaUrl != null && mediaUrl.isNotEmpty)
                          ? (mediaUrl.startsWith('http') ? mediaUrl : '${AppConstants.baseUrl}/uploads/reports/$mediaUrl')
                          : 'https://picsum.photos/seed/post/400/300';

                      return _buildPostCard(
                        name: userName,
                        time: timeStr,
                        text: post['dis'] ?? '',
                        postImageUrl: fullImageUrl,
                        authorImageUrl: authorImageUrl,
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildPostCard({
    required String name,
    required String time,
    required String text,
    required String postImageUrl,
    String? authorImageUrl,
  }) {
    final String? profileUrl = (authorImageUrl != null && authorImageUrl.isNotEmpty)
        ? '${AppConstants.baseUrl}/uploads/users/$authorImageUrl'
        : null;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
              child: profileUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(time),
          ),
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(text),
            ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
            child: Image.network(
              postImageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedPersonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trusted Persons',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _isLoadingContacts
            ? const Center(child: CircularProgressIndicator())
            : _trustedPersons.isEmpty
                ? const Text('No trusted persons found.')
                : Column(
                    children: _trustedPersons.map((person) => _buildPersonCard(
                      name: person['name'] ?? 'No Name',
                      email: person['contact_email'] ?? 'No Email',
                      phone: person['contact_phone'] ?? 'No Phone',
                    )).toList(),
                  ),
      ],
    );
  }

  Widget _buildPersonCard({
    required String name,
    required String email,
    required String phone,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            'https://picsum.photos/seed/person/200',
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$email\n$phone'),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () => _makePhoneCall(phone),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/admin_choice_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  String _name = 'Loading...';
  String _email = 'Loading...';
  String? _imageUrl;
  bool _isAdmin = false;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _trustedContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchTrustedContacts();
  }

  Future<void> _fetchUserDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) {
        if (mounted) {
          setState(() {
            _error = 'User not authenticated';
            _isLoading = false;
          });
        }
        return;
      }

      final url = Uri.parse('${AppConstants.baseUrl}/api/user/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        final Map<String, dynamic> userData = responseData.containsKey('user') 
            ? responseData['user'] 
            : responseData;

        if (mounted) {
          setState(() {
            _name = userData['name'] ?? userData['username'] ?? 'No Name';
            _email = userData['email'] ?? 'No Email';
            _imageUrl = userData['imageUrl'];
            
            if (userData['role'] != null && userData['role']['name'] == 'admin') {
              _isAdmin = true;
            } else {
              _isAdmin = false;
            }
            
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load profile: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTrustedContacts() async {
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
        if (mounted) {
          setState(() {
            _trustedContacts = jsonDecode(response.body);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
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

  Future<void> _logout() async {
    await _storage.deleteAll();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _fetchUserDetails();
              _fetchTrustedContacts();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 30),
                      if (_isAdmin) ...[
                        _buildAdminPanelButton(),
                        const SizedBox(height: 20),
                      ],
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildEmergencyContacts(),
                      const SizedBox(height: 30),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final String? profileImageUrl = (_imageUrl != null && _imageUrl!.isNotEmpty)
        ? '${AppConstants.baseUrl}/uploads/users/$_imageUrl'
        : null;

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
          child: profileImageUrl == null
              ? const Icon(Icons.person, size: 60, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 15),
        Text(
          _name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          _email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        if (_isAdmin)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent),
            ),
            child: const Text(
              'ADMINISTRATOR',
              style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildAdminPanelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminChoicePage()),
          );
        },
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('GO TO ADMIN PANEL',
            style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoRow(icon: Icons.person_outline, label: 'Full Name', value: _name),
            const Divider(height: 30),
            _buildInfoRow(icon: Icons.email_outlined, label: 'Email', value: _email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _showAddContactDialog,
              icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _trustedContacts.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No emergency contacts found.'),
              ))
            : Column(
                children: _trustedContacts.map((contact) => _buildContactCard(contact)).toList(),
              ),
      ],
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Contact Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Contact Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addTrustedContact(
                nameController.text,
                phoneController.text,
                emailController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTrustedContact(String name, String phone, String email) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/trusted_contacts/create');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'contact_phone': phone,
          'contact_email': email,
          'userId': int.tryParse(userId) ?? userId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact added successfully')),
          );
        }
        _fetchTrustedContacts();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add contact: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error adding contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }

  Future<void> _deleteTrustedContact(dynamic id) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      if (token == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/trusted_contacts/$id');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact deleted successfully')),
          );
        }
        _fetchTrustedContacts();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete contact: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while deleting')),
        );
      }
    }
  }

  Widget _buildContactCard(dynamic contact) {
    final String name = contact['name'] ?? 'No Name';
    final String email = contact['contact_email'] ?? 'No Email';
    final String phone = contact['contact_phone'] ?? 'No Phone';
    final dynamic id = contact['id'];

    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this contact?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteTrustedContact(id);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.contact_phone_outlined, color: Colors.redAccent, size: 35),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$email\n$phone'),
          trailing: IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () => _makePhoneCall(phone),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout),
      label: const Text('LOGOUT'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.redAccent, backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.redAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
    );
  }
}

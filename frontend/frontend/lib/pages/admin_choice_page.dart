import 'package:flutter/material.dart';
import 'package:frontend/pages/admin_panel_page.dart';
import 'package:frontend/pages/disaster_management_page.dart';
import 'package:frontend/pages/donation_management_page.dart';
import 'package:frontend/pages/sos_management_page.dart';
import 'package:frontend/pages/social_post_management_page.dart';

class AdminChoicePage extends StatelessWidget {
  const AdminChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Selection'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChoiceCard(
                context,
                title: 'Camp Management',
                icon: Icons.home_work,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanelPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildChoiceCard(
                context,
                title: 'Disaster Management',
                icon: Icons.warning_amber_rounded,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DisasterManagementPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildChoiceCard(
                context,
                title: 'Donation Management',
                icon: Icons.volunteer_activism,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DonationManagementPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildChoiceCard(
                context,
                title: 'SOS Management',
                icon: Icons.sos,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SosManagementPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildChoiceCard(
                context,
                title: 'Social Post Management',
                icon: Icons.dynamic_feed,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SocialPostManagementPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Simulated login state — replace with real auth later
  static const _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // User info / login prompt
          _isLoggedIn ? _buildUserInfo(textTheme, colorScheme) : _buildLoginPrompt(context, colorScheme, textTheme),
          const Divider(),
          // Menu entries
          _buildMenuItem(context, Icons.receipt_long, 'My Orders'),
          _buildMenuItem(context, Icons.location_on_outlined, 'Addresses'),
          _buildMenuItem(context, Icons.confirmation_number_outlined, 'Coupons'),
          _buildMenuItem(context, Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildUserInfo(TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(radius: 32, backgroundColor: colorScheme.primaryContainer, child: Icon(Icons.person, size: 32, color: colorScheme.onPrimaryContainer)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Gold Member', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.account_circle, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Sign in to your account', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Access orders, addresses, and more', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () {}, child: const Text('Sign In')),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Push within tab navigator
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)))),
        );
      },
    );
  }
}

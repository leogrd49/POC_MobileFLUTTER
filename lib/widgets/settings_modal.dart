import 'package:flutter/material.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    title: 'Général',
                    children: [
                      _buildSettingTile(
                        icon: Icons.language,
                        title: 'Langue',
                        subtitle: 'Français',
                        onTap: () {},
                      ),
                      _buildSettingTile(
                        icon: Icons.dark_mode,
                        title: 'Thème',
                        subtitle: 'Clair',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Notifications',
                    children: [
                      _buildSettingTile(
                        icon: Icons.notifications_active,
                        title: 'Notifications push',
                        subtitle: 'Activées',
                        onTap: () {},
                      ),
                      _buildSettingTile(
                        icon: Icons.email,
                        title: 'Notifications par email',
                        subtitle: 'Désactivées',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'À propos',
                    children: [
                      _buildSettingTile(
                        icon: Icons.info,
                        title: 'Version',
                        subtitle: '1.0.0',
                        onTap: () {},
                      ),
                      _buildSettingTile(
                        icon: Icons.policy,
                        title: 'Politique de confidentialité',
                        onTap: () {},
                      ),
                      _buildSettingTile(
                        icon: Icons.description,
                        title: "Conditions d'utilisation",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
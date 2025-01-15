import 'package:flutter/material.dart';

enum DrawerSide { left, right }

class DrawerContent extends StatelessWidget {
  final DrawerSide side;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;

  const DrawerContent({
    super.key,
    required this.side,
    this.onSettingsTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Text(
                side == DrawerSide.left ? 'Menu' : 'Actions rapides',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          if (side == DrawerSide.left) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil - Bientôt disponible')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                onSettingsTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aide - Bientôt disponible')),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Ajouter la logique de déconnexion ici
                        },
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                onNotificationsTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Réglages rapides'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Réglages rapides - Bientôt disponible'),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
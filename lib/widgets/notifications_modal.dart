import 'package:flutter/material.dart';

class NotificationsModal extends StatelessWidget {
  const NotificationsModal({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de notifications (à remplacer par de vraies données)
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Nouvelle espèce ajoutée',
        'message': 'L\'espèce "Panthera leo" a été ajoutée avec succès.',
        'time': '2 min',
        'read': false,
      },
      {
        'title': 'Synchronisation terminée',
        'message': 'Toutes les données ont été synchronisées avec succès.',
        'time': '1h',
        'read': true,
      },
    ];

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Ajouter la logique pour marquer toutes les notifications comme lues
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Toutes les notifications ont été marquées comme lues'),
                        ),
                      );
                    },
                    child: const Text('Tout marquer comme lu'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucune notification',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: notification['read']
                                  ? Colors.grey[200]
                                  : Theme.of(context).primaryColor,
                              child: Icon(
                                Icons.notifications,
                                color: notification['read']
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                            title: Text(
                              notification['title'],
                              style: TextStyle(
                                fontWeight: notification['read']
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notification['message']),
                                const SizedBox(height: 4),
                                Text(
                                  'Il y a ${notification['time']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              // Ajouter la logique de gestion des notifications
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Notification: ${notification['title']}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
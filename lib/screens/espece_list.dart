import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/network_service.dart';
import '../models/espece.dart';

class EspeceList extends StatefulWidget {
  const EspeceList({super.key});

  @override
  State<EspeceList> createState() => _EspeceListState();
}

class _EspeceListState extends State<EspeceList> {
  static const String getEspecesQuery = r'''
    query GetEspeces {
      especes {
        items {
          id
          nom
        }
      }
    }
  ''';

  @override
  void initState() {
    super.initState();
    NetworkService.addConnectionListener(_onConnectionChanged);
  }

  @override
  void dispose() {
    NetworkService.removeConnectionListener(_onConnectionChanged);
    super.dispose();
  }

  void _onConnectionChanged(bool isConnected) {
    if (isConnected && mounted) {
      debugPrint('🔄 Connexion rétablie - Rafraîchissement de la liste');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getEspecesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
        pollInterval: const Duration(seconds: 30),
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${result.exception.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      refetch?.call();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (result.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement des espèces...'),
              ],
            ),
          );
        }

        final especes = (result.data?['especes']['items'] as List?)
            ?.map((item) => Espece.fromMap(item))
            .toList() ?? [];

        if (especes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pets,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune espèce trouvée',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    refetch?.call();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rafraîchir'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            refetch?.call();
            return Future.value();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: especes.length,
            itemBuilder: (context, index) {
              final espece = especes[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      espece.nom.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    espece.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${espece.id}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
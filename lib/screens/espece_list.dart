import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/espece.dart';

class EspeceList extends StatelessWidget {
  const EspeceList({super.key});

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
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getEspecesQuery),
        fetchPolicy: FetchPolicy.noCache,
      ),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
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
                  ElevatedButton(
                    onPressed: refetch,
                    child: const Text('Réessayer'),
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
          return const Center(
            child: Text('Aucune espèce trouvée'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            refetch?.call();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: especes.length,
            itemBuilder: (context, index) {
              final espece = especes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(espece.nom[0]),
                  ),
                  title: Text(espece.nom),
                  subtitle: Text('ID: ${espece.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
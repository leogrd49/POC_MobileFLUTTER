import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/espece.dart';
import '../services/database_service.dart';

class SyncService {
  static final DatabaseService _databaseService = DatabaseService();
  static bool _isSyncing = false;

  static const String addEspeceMutation = '''
    mutation AddEspece(\$id: Int!, \$nom: String!) {
      addEspece(id: \$id, nom: \$nom) {
        id
        nom
      }
    }
  ''';

  static Future<void> syncPendingData() async {
    if (_isSyncing) {
      debugPrint('🔒 Synchronisation déjà en cours');
      return;
    }

    _isSyncing = true;
    debugPrint('🚀 Début de la synchronisation');

    try {
      final pendingEspeces = await _databaseService.getPendingEspeces();
      debugPrint('📦 Nombre d\'espèces à synchroniser: ${pendingEspeces.length}');

      if (pendingEspeces.isEmpty) {
        debugPrint('✅ Aucune espèce à synchroniser');
        return;
      }

      // Création du client GraphQL avec des options spécifiques
      final client = GraphQLClient(
        cache: GraphQLCache(),
        link: HttpLink(
          'http://172.16.10.64:5220/graphql',
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      for (final espece in pendingEspeces) {
        try {
          debugPrint('🔄 Tentative de synchronisation de l\'espèce: ${espece.id} (${espece.nom})');

          // Préparer les variables de la mutation
          final variables = {
            'id': espece.id,
            'nom': espece.nom,
          };

          debugPrint('📤 Envoi de la mutation avec les variables: $variables');

          final result = await client.mutate(
            MutationOptions(
              document: gql(addEspeceMutation),
              variables: variables,
              fetchPolicy: FetchPolicy.noCache,
            ),
          );

          if (result.hasException) {
            debugPrint('❌ Erreur GraphQL: ${result.exception.toString()}');
            throw Exception(result.exception?.graphqlErrors.first.message ?? 'Erreur inconnue');
          }

          // Vérifier la réponse de l'API
          final data = result.data;
          debugPrint('📥 Réponse reçue: $data');

          if (data != null && data['addEspece'] != null) {
            debugPrint('✅ Espèce ajoutée avec succès sur l\'API');
            
            // Mise à jour du statut local
            await _databaseService.updateSyncStatus(espece.id, 'synced');
            debugPrint('✅ Statut local mis à jour pour l\'espèce ${espece.id}');
          } else {
            debugPrint('⚠️ Réponse API invalide pour l\'espèce ${espece.id}');
            throw Exception('Réponse API invalide');
          }

        } catch (e) {
          debugPrint('❌ Erreur lors de la synchronisation de l\'espèce ${espece.id}: $e');
          // On continue avec la prochaine espèce même en cas d'erreur
        }
      }

      // Vérification finale
      final remainingEspeces = await _databaseService.getPendingEspeces();
      debugPrint('📊 Espèces restantes en attente: ${remainingEspeces.length}');

    } catch (e) {
      debugPrint('❌ Erreur générale de synchronisation: $e');
    } finally {
      _isSyncing = false;
      debugPrint('🏁 Fin de la synchronisation');
    }
  }
}
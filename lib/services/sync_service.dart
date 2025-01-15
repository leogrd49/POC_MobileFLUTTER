import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/espece.dart';
import '../config/graphql_config.dart';
import '../services/database_service.dart';
import '../services/network_service.dart';

class SyncService {
  static final DatabaseService _databaseService = DatabaseService();
  static bool _isSyncing = false;
  static Timer? _syncTimer;

  static const String addEspeceMutation = r'''
    mutation AddEspece($id: Int!, $nom: String!) {
      addEspece(id: $id, nom: $nom) {
        id
        nom
      }
    }
  ''';

  static void initialize() {
    debugPrint('🚀 Initialisation du SyncService');
    
    NetworkService.connectivityStream.listen((isConnected) {
      debugPrint('🌐 Changement de connectivité détecté: ${isConnected ? "Connecté" : "Déconnecté"}');
      if (isConnected) {
        debugPrint('📡 Connexion disponible - Lancement de la synchronisation');
        syncPendingData();
      }
    });

    // Vérification périodique
    _syncTimer?.cancel(); // Annuler le timer existant si présent
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      debugPrint('⏰ Vérification périodique de synchronisation');
      final isConnected = await NetworkService.checkConnectivity();
      if (isConnected) {
        syncPendingData();
      }
    });
  }

  static Future<void> syncPendingData() async {
    if (_isSyncing) {
      debugPrint('⚠️ Synchronisation déjà en cours - Ignoré');
      return;
    }

    _isSyncing = true;
    debugPrint('🔄 Début du processus de synchronisation');

    try {
      final isConnected = await NetworkService.checkConnectivity();
      if (!isConnected) {
        debugPrint('❌ Pas de connexion - Synchronisation annulée');
        _isSyncing = false;
        return;
      }

      final pendingEspeces = await _databaseService.getPendingEspeces();
      debugPrint('📦 Espèces à synchroniser: ${pendingEspeces.length}');

      for (final espece in pendingEspeces) {
        try {
          debugPrint('🔄 Synchronisation de l\'espèce ${espece.id} (${espece.nom})');

          // Création du client GraphQL
          final client = GraphQLClient(
            cache: GraphQLCache(),
            link: HttpLink('http://172.16.10.64:5220/graphql'),
          );

          // Exécution de la mutation
          final MutationOptions options = MutationOptions(
            document: gql(addEspeceMutation),
            variables: {
              'id': espece.id,
              'nom': espece.nom,
            },
          );

          debugPrint('📤 Envoi de la mutation pour ${espece.nom}');
          final result = await client.mutate(options);

          // Vérification du résultat
          if (result.hasException) {
            debugPrint('❌ Erreur GraphQL pour ${espece.nom}: ${result.exception}');
            continue;
          }

          // Mise à jour du statut local
          await _databaseService.updateSyncStatus(espece.id, 'synced');
          debugPrint('✅ Espèce ${espece.nom} synchronisée avec succès');

          // Vérification de la mise à jour
          final updatedEspeces = await _databaseService.getPendingEspeces();
          debugPrint('📊 Espèces encore en attente: ${updatedEspeces.length}');

        } catch (e) {
          debugPrint('❌ Erreur lors de la synchronisation de ${espece.nom}: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur générale de synchronisation: $e');
    } finally {
      _isSyncing = false;
      debugPrint('🏁 Fin du processus de synchronisation');
    }
  }

  static void dispose() {
    debugPrint('🛑 Arrêt du SyncService');
    _syncTimer?.cancel();
  }

  // Méthode de test pour forcer une synchronisation
  static Future<void> forceSyncForTesting() async {
    debugPrint('🔬 Test forcé de synchronisation');
    await syncPendingData();
  }
}
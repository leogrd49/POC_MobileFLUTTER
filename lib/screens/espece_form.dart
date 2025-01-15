import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';
import '../services/network_service.dart';
import '../services/database_service.dart';
import '../models/espece.dart';
import '../services/sync_service.dart';

class EspeceForm extends StatefulWidget {
  const EspeceForm({super.key});

  @override
  State<EspeceForm> createState() => _EspeceFormState();
}

class _EspeceFormState extends State<EspeceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _databaseService = DatabaseService();
  String? _errorMessage;
  bool _isLoading = false;

  static const String addEspeceMutation = r'''
    mutation AddEspece($id: Int!, $nom: String!) {
      addEspece(id: $id, nom: $nom) {
        id
        nom
      }
    }
  ''';

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final especeId = Random().nextInt(1000000);
    final nom = _nomController.text.trim();

    debugPrint('⭐ Début de la soumission du formulaire');
    debugPrint('📝 ID généré: $especeId, Nom: $nom');

    try {
      final isConnected = await NetworkService.checkConnectivity();
      debugPrint(
          '🌐 État de la connexion: ${isConnected ? "Connecté" : "Déconnecté"}');

      if (isConnected) {
        debugPrint('📡 Mode en ligne - Tentative d\'envoi à l\'API');
        final result = await GraphQLProvider.of(context).value.mutate(
              MutationOptions(
                document: gql(addEspeceMutation),
                variables: {
                  'id': especeId,
                  'nom': nom,
                },
              ),
            );

        if (result.hasException) {
          debugPrint('❌ Erreur GraphQL: ${result.exception.toString()}');
          throw Exception(result.exception?.graphqlErrors.first.message);
        }

        debugPrint('✅ Mutation GraphQL réussie');
        _nomController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Espèce ajoutée avec succès')),
          );
        }
      } else {
        debugPrint('💾 Mode hors ligne - Sauvegarde locale');
        final espece = Espece(id: especeId, nom: nom);
        await _databaseService.insertEspece(espece);

        // Vérification immédiate de la sauvegarde
        final pendingEspeces = await _databaseService.getPendingEspeces();
        debugPrint(
            '📊 Nombre d\'espèces en attente après sauvegarde: ${pendingEspeces.length}');
        debugPrint(
            '🔍 Dernière espèce sauvegardée: ID=${espece.id}, Nom=${espece.nom}');

        // Tentative de synchronisation immédiate
        debugPrint('🔄 Tentative de synchronisation immédiate');
        await SyncService.syncPendingData();

        _nomController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Données sauvegardées localement. Synchronisation automatique lors de la reconnexion.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la soumission: $e');
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      debugPrint('🏁 Fin de la soumission du formulaire');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: "Nom de l'espèce",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Le nom ne peut pas être vide";
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Ajouter l'espèce"),
            ),
            const SizedBox(height: 8),
            // Bouton de test pour vérifier les espèces en attente
            TextButton(
              onPressed: () async {
                final pendingEspeces =
                    await _databaseService.getPendingEspeces();
                debugPrint('📊 Espèces en attente: ${pendingEspeces.length}');
                pendingEspeces.forEach((espece) {
                  debugPrint(
                      '🔍 ID: ${espece.id}, Nom: ${espece.nom}, Status: ${espece.syncStatus}');
                });
              },
              child: const Text('Vérifier les espèces en attente'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                debugPrint('🔄 Tentative de synchronisation forcée');
                await SyncService.forceSyncForTesting();
              },
              child: const Text('Forcer la synchronisation'),
            ),
          ],
        ),
      ),
    );
  }
}

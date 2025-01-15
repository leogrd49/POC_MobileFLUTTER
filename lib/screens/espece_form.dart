import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';
import '../services/network_service.dart';
import '../services/database_service.dart';
import '../models/espece.dart';

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

    debugPrint('📝 Tentative de soumission - ID: $especeId, Nom: $nom');

    try {
      final isConnected = await NetworkService.checkConnectivity();
      debugPrint(
          '🌐 État de la connexion: ${isConnected ? "En ligne" : "Hors ligne"}');

      if (isConnected) {
        debugPrint('📡 Mode en ligne - Envoi à l\'API');

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
          debugPrint('❌ Erreur API: ${result.exception.toString()}');
          throw Exception(result.exception?.graphqlErrors.first.message ??
              'Erreur inconnue');
        }

        debugPrint('✅ Espèce ajoutée avec succès en ligne');
        _showSuccessMessage('Espèce ajoutée avec succès');
      } else {
        debugPrint('💾 Mode hors ligne - Sauvegarde locale');

        await _databaseService.insertEspece(
          Espece(id: especeId, nom: nom),
        );

        debugPrint('✅ Espèce sauvegardée localement');
        _showSuccessMessage(
          'Données sauvegardées localement.\nSynchronisation automatique lors de la reconnexion.',
          duration: 4,
        );
      }

      _nomController.clear();
    } catch (e) {
      debugPrint('❌ Erreur: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      _showErrorMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message, {int duration = 2}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: duration),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _checkPendingEspeces() async {
    final pendingEspeces = await _databaseService.getPendingEspeces();
    debugPrint('📊 Espèces en attente: ${pendingEspeces.length}');

    if (pendingEspeces.isEmpty) {
      _showSuccessMessage('Aucune espèce en attente de synchronisation');
      return;
    }

    for (var espece in pendingEspeces) {
      debugPrint(
          '🔍 ID: ${espece.id}, Nom: ${espece.nom}, Status: ${espece.syncStatus}');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${pendingEspeces.length} espèce(s) en attente de synchronisation'),
          backgroundColor: Colors.orange,
        ),
      );
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
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Ajouter une nouvelle espèce",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: "Nom de l'espèce",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
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
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading
                          ? "Ajout en cours..."
                          : "Ajouter l'espèce"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _checkPendingEspeces,
              icon: const Icon(Icons.sync),
              label: const Text('Vérifier les espèces en attente'),
            ),
          ],
        ),
      ),
    );
  }
}

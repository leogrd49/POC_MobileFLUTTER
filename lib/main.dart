import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'config/graphql_config.dart';
import 'screens/home_screen.dart';
import 'services/network_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  
  // Initialiser NetworkService
  NetworkService.initialize();
  
  // Ajouter l'écouteur pour la synchronisation
  NetworkService.addConnectionListener((isConnected) {
    if (isConnected) {
      debugPrint('🔄 Connexion détectée - Lancement synchronisation');
      SyncService.syncPendingData();
    }
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.initializeClient(),
      child: MaterialApp(
        title: 'Gestion des Espèces',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
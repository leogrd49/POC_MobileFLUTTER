import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'config/graphql_config.dart';
import 'screens/home_screen.dart';
import 'services/sync_service.dart';

void main() async {
  // Assurez-vous que les plugins Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive pour GraphQL Flutter
  await initHiveForFlutter();
  
  // Initialiser le service de synchronisation
  SyncService.initialize();
  
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
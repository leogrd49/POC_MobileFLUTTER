import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  static bool _previousConnectionStatus = false;
  static final List<Function(bool)> _connectionListeners = [];
  
  static void initialize() {
    debugPrint('🌐 Initialisation NetworkService');
    
    // Vérification initiale
    _checkInitialConnection();
    
    // Écoute des changements
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  static void _handleConnectivityChange(ConnectivityResult result) async {
    final isConnected = result != ConnectivityResult.none;
    
    // Ne notifier que si l'état a changé
    if (_previousConnectionStatus != isConnected) {
      debugPrint('🔌 Changement connexion: ${isConnected ? "Connecté" : "Déconnecté"}');
      _previousConnectionStatus = isConnected;
      
      // Notifier tous les listeners
      for (var listener in _connectionListeners) {
        listener(isConnected);
      }
    }
  }

  static Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _handleConnectivityChange(result);
  }

  static void addConnectionListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  static void removeConnectionListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  static Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
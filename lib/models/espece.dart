class Espece {
  final int id;
  final String nom;
  final String syncStatus;

  Espece({
    required this.id,
    required this.nom,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'syncStatus': syncStatus,
    };
  }

  factory Espece.fromMap(Map<String, dynamic> map) {
    return Espece(
      id: map['id'],
      nom: map['nom'],
      syncStatus: map['syncStatus'] ?? 'pending',
    );
  }
}
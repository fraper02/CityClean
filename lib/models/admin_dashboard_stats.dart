class AdminDashboardStats {
  final int totalUsers;
  final int totalConferimenti;
  final int totalSegnalazioni;
  final int totalMissioniCompletate;
  final int puntiGuadagnati;
  final int puntiSpesi;
  final double totalCo2;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalConferimenti,
    required this.totalSegnalazioni,
    required this.totalMissioniCompletate,
    required this.puntiGuadagnati,
    required this.puntiSpesi,
    required this.totalCo2,
  });

  // Factory per creare un'istanza dal JSON restituito dalla funzione SQL
  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: (json['totalUsers'] as num? ?? 0).toInt(),
      totalConferimenti: (json['totalConferimenti'] as num? ?? 0).toInt(),
      totalSegnalazioni: (json['totalSegnalazioni'] as num? ?? 0).toInt(),
      totalMissioniCompletate: (json['totalMissioniCompletate'] as num? ?? 0).toInt(),
      puntiGuadagnati: (json['puntiGuadagnati'] as num? ?? 0).toInt(),
      puntiSpesi: (json['puntiSpesi'] as num? ?? 0).toInt(),
      totalCo2: (json['totalCo2'] as num? ?? 0).toDouble(),
    );
  }

  // Costruttore per stato iniziale o di errore
  factory AdminDashboardStats.zero() {
    return AdminDashboardStats(
      totalUsers: 0,
      totalConferimenti: 0,
      totalSegnalazioni: 0,
      totalMissioniCompletate: 0,
      puntiGuadagnati: 0,
      puntiSpesi: 0,
      totalCo2: 0.0,
    );
  }
}

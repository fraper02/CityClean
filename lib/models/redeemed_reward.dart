// lib/models/redeemed_reward.dart

/// Modello di dati che rappresenta un premio riscattato per la UI.
/// Combina informazioni dal possesso e dal premio stesso.
class RedeemedReward {
  final String title;
  final int points;
  final DateTime date;

  const RedeemedReward({
    required this.title,
    required this.points,
    required this.date,
  });
}

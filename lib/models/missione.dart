import 'package:cityclean/models/badge.dart';

enum MissionStatus { non_iniziata, in_corso, completata, scaduta }

class Missione {
  // Dati dalla tabella `missione`
  final String id;
  final String titolo;
  final String descrizione;
  final String tipoAzione;
  final int obiettivoTarget;
  final DateTime? dataScadenza;
  final Badge badgePremio;

  // Dati dalla tabella `partecipazione_missione` (possono essere null)
  final int progressoAttuale;
  final MissionStatus stato;

  Missione({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.tipoAzione,
    required this.obiettivoTarget,
    this.dataScadenza,
    required this.badgePremio,
    this.progressoAttuale = 0,
    required this.stato,
  });

  factory Missione.fromJson(Map<String, dynamic> json) {
    final partecipazione = (json['partecipazione_missione'] as List<dynamic>?)?.firstOrNull as Map<String, dynamic>?;
    final badgeData = json['id_badge_premio'];

    MissionStatus currentStatus = MissionStatus.non_iniziata;
    int currentProgress = 0;

    if (partecipazione != null) {
      currentProgress = partecipazione['progresso_attuale'] ?? 0;
      String statoDb = partecipazione['stato'] ?? 'IN_CORSO';
      
      if (statoDb == 'COMPLETATA') {
        currentStatus = MissionStatus.completata;
      } else if (DateTime.tryParse(json['data_scadenza'] ?? '')?.isBefore(DateTime.now()) ?? false) {
        currentStatus = MissionStatus.scaduta;
      } else {
        currentStatus = MissionStatus.in_corso;
      }
    } else {
       if (DateTime.tryParse(json['data_scadenza'] ?? '')?.isBefore(DateTime.now()) ?? false) {
        currentStatus = MissionStatus.scaduta;
      }
    }

    return Missione(
      id: json['id_missione'] as String,
      titolo: json['titolo'] as String,
      descrizione: json['descrizione'] as String,
      tipoAzione: json['tipo_azione'] as String,
      obiettivoTarget: json['obiettivo_target'] as int,
      dataScadenza: json['data_scadenza'] != null ? DateTime.parse(json['data_scadenza']) : null,
      badgePremio: Badge.fromJson(badgeData as Map<String, dynamic>),
      progressoAttuale: currentProgress,
      stato: currentStatus,
    );
  }
}

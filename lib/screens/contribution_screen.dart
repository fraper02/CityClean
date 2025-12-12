import 'package:cityclean/models/sessione_raccolta.dart';
import 'package:cityclean/screens/home_screen.dart';
import 'package:cityclean/services/contribution_service.dart';
import 'package:cityclean/models/aggiungi_punti.dart';
import 'package:cityclean/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ContributionScreen extends StatefulWidget {
  final String ecopointId;

  const ContributionScreen({super.key, required this.ecopointId});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final supabase = Supabase.instance.client;
  final RecyclingService _recyclingService = RecyclingService();
  final Uuid _uuid = const Uuid();

  // Stato per i dati dinamici
  List<ValoreRifiuto> _valoriRifiuti = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers per gli input
  final _plasticaController = TextEditingController();
  final _vetroController = TextEditingController();
  final _alluminioController = TextEditingController();
  final _cartaController = TextEditingController();

  double _totalePunti = 0;
  double _totaleCo2 = 0;

  @override
  void initState() {
    super.initState();
    _fetchWasteValues();

    // Listener: ricalcola ogni volta che l'utente scrive qualcosa
    _plasticaController.addListener(_calcolaTotale);
    _vetroController.addListener(_calcolaTotale);
    _alluminioController.addListener(_calcolaTotale);
    _cartaController.addListener(_calcolaTotale);
  }

  @override
  void dispose() {
    _plasticaController.dispose();
    _vetroController.dispose();
    _alluminioController.dispose();
    _cartaController.dispose();
    super.dispose();
  }

  Future<void> _fetchWasteValues() async {
    try {
      final response = await supabase.from('valore_rifiuto').select();

      if (!mounted) return;

      setState(() {
        _valoriRifiuti =
            List<ValoreRifiuto>.from(response.map((item) => ValoreRifiuto.fromJson(item)));
        _isLoading = false;
      });

      _calcolaTotale();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Errore caricamento valori: $e";
        _isLoading = false;
      });
    }
  }

  ValoreRifiuto? _getRifiutoPerTipo(String tipo) {
    if (_valoriRifiuti.isEmpty) return null;
    try {
      return _valoriRifiuti.firstWhere(
        (element) => element.tipoRifiuto.toLowerCase() == tipo.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  void _calcolaTotale() {
    if (_valoriRifiuti.isEmpty) return;

    final int qtaPlastica = int.tryParse(_plasticaController.text) ?? 0;
    final int qtaVetro = int.tryParse(_vetroController.text) ?? 0;
    final int qtaAlluminio = int.tryParse(_alluminioController.text) ?? 0;
    final int qtaCarta = int.tryParse(_cartaController.text) ?? 0;

    final plastica = _getRifiutoPerTipo('Plastica');
    final vetro = _getRifiutoPerTipo('Vetro');
    final alluminio = _getRifiutoPerTipo('Alluminio');
    final carta = _getRifiutoPerTipo('Carta');

    setState(() {
      _totalePunti =
          (qtaPlastica * (plastica?.valoreRifiuto ?? 0.0)) +
              (qtaVetro * (vetro?.valoreRifiuto ?? 0.0)) +
              (qtaAlluminio * (alluminio?.valoreRifiuto ?? 0.0)) +
              (qtaCarta * (carta?.valoreRifiuto ?? 0.0));

      _totaleCo2 =
          (qtaPlastica * (plastica?.pesoCo2 ?? 0.0)) +
              (qtaVetro * (vetro?.pesoCo2 ?? 0.0)) +
              (qtaAlluminio * (alluminio?.pesoCo2 ?? 0.0)) +
              (qtaCarta * (carta?.pesoCo2 ?? 0.0));
    });
  }

  Future<void> _confermaOperazione() async {
    if (_totalePunti == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci almeno un rifiuto per continuare.")),
      );
      return;
    }

    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Conferma Conferimento", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Guadagnerai:", style: TextStyle(color: Colors.grey)),
            Text(
              "${_totalePunti.toStringAsFixed(0)} Punti",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 15),
            const Text("Impatto Ambientale:", style: TextStyle(color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 5),
                Text(
                  "- ${_totaleCo2.toStringAsFixed(2)} Kg CO₂",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("CONFERMA"),
          ),
        ],
      ),
    );

    if (conferma == true) {
      setState(() => _isLoading = true);

      final result = await ContributionService.submitContribution(
          widget.ecopointId,
          _totalePunti.toInt(),
          _totaleCo2
      );

      if (result['success'] == true) {
        String userId = supabase.auth.currentUser!.id;
        Duration sessionDuration = await _recyclingService.stopRecycling();

        final sessione = SessioneRaccolta(
          idsessione: _uuid.v4(),
          idutente: userId,
          idpuntoraccolta: widget.ecopointId,
          timestamp: DateTime.now(),
          puntiguadagnati: _totalePunti.toInt(),
          dettaglirifiuto: _buildWasteDetails(),
          durataSessione: sessionDuration,
        );

        try {
          await _recyclingService.createSessioneRaccolta(sessione);
          if (!mounted) return;

          // Clear the navigation stack and navigate to a new HomeScreen instance
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']!),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Errore nel salvataggio della sessione: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']!),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _buildWasteDetails() {
    List<String> details = [];
    if (_plasticaController.text.isNotEmpty && _plasticaController.text != '0') {
      details.add("Plastica: ${_plasticaController.text}");
    }
    if (_vetroController.text.isNotEmpty && _vetroController.text != '0') {
      details.add("Vetro: ${_vetroController.text}");
    }
    if (_alluminioController.text.isNotEmpty && _alluminioController.text != '0') {
      details.add("Alluminio: ${_alluminioController.text}");
    }
    if (_cartaController.text.isNotEmpty && _cartaController.text != '0') {
      details.add("Carta: ${_cartaController.text}");
    }
    return details.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inserisci Rifiuti"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(child: Text("Ecopoint: ${widget.ecopointId}", style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildInputRow("Plastica", Icons.local_drink, 'Plastica', _plasticaController, Colors.blue),
            const SizedBox(height: 15),
            _buildInputRow("Vetro", Icons.wine_bar, 'Vetro', _vetroController, Colors.green),
            const SizedBox(height: 15),
            _buildInputRow("Alluminio", Icons.takeout_dining, 'Alluminio', _alluminioController, Colors.grey),
            const SizedBox(height: 15),
            _buildInputRow("Carta", Icons.newspaper, 'Carta', _cartaController, Colors.amber[800]!),

            const SizedBox(height: 30),

            Card(
              color: Colors.green[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("STIMA GUADAGNO", style: TextStyle(color: Colors.white70)),
                    Text("${_totalePunti.toStringAsFixed(0)} PUNTI", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24),
                    Text("CO₂ Risparmiata: ${_totaleCo2.toStringAsFixed(2)} Kg", style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confermaOperazione,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16)
              ),
              child: const Text("CALCOLA E CONFERMA", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, IconData icon, String tipoKey, TextEditingController controller, Color color) {
    final item = _getRifiutoPerTipo(tipoKey);
    final pti = item?.valoreRifiuto ?? 0;
    final co2 = item?.pesoCo2 ?? 0;

    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("$pti pti/pz | -$co2 kg CO₂", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "0",
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

class ValoreRifiuto {
  final String tipoRifiuto;
  final double valoreRifiuto;
  final double pesoCo2;

  ValoreRifiuto({
    required this.tipoRifiuto,
    required this.valoreRifiuto,
    required this.pesoCo2,
  });

  factory ValoreRifiuto.fromJson(Map<String, dynamic> json) {
    return ValoreRifiuto(
      tipoRifiuto: json['tipo_rifiuto'] ?? '',
      valoreRifiuto: (json['valore_rifiuto'] ?? 0).toDouble(),
      pesoCo2: (json['peso_co2'] ?? 0).toDouble(),
    );
  }
}

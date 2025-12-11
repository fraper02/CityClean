import 'package:cityclean/services/contribution_service.dart'; // Importa il service (dal vecchio file)
import 'package:cityclean/models/valore_rifiuto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContributionScreen extends StatefulWidget {
  final String ecopointId;

  const ContributionScreen({super.key, required this.ecopointId});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final supabase = Supabase.instance.client;

  // Stato per i dati dinamici
  List<ValoreRifiuto> _valoriRifiuti = [];
  bool _isLoading = true; // Gestisce sia il caricamento iniziale che il salvataggio
  String? _errorMessage;

  // Controllers per gli input
  final _cartaController = TextEditingController();
  final _plasticaController = TextEditingController();
  final _vetroController = TextEditingController();
  final _alluminioController = TextEditingController();

  double _totalePunti = 0; // Double per gestire i valori dal DB

  @override
  void initState() {
    super.initState();
    _fetchWasteValues();
    _cartaController.addListener(_calcolaTotale);
    _plasticaController.addListener(_calcolaTotale);
    _vetroController.addListener(_calcolaTotale);
    _alluminioController.addListener(_calcolaTotale);
  }

  Future<void> _fetchWasteValues() async {
    try {
      final response = await supabase
          .from('valore_rifiuto')
          .select();

      if (!mounted) return;

      setState(() {
        _valoriRifiuti = List<ValoreRifiuto>.from(
            response.map((item) => ValoreRifiuto.fromJson(item)));
        _isLoading = false;
      });

      // Ricalcola subito nel caso ci siano valori precompilati
      _calcolaTotale();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Errore caricamento valori: $e";
        _isLoading = false;
      });
    }
  }

  // Helper per ottenere il valore dal DB in base al nome
  double _getValorePerTipo(String tipo) {
    if (_valoriRifiuti.isEmpty) return 0;

    final valore = _valoriRifiuti.firstWhere(
          (element) => element.tipoRifiuto.toLowerCase() == tipo.toLowerCase(),
      orElse: () => ValoreRifiuto(id: 0, tipoRifiuto: '', valoreRifiuto: 0),
    );
    return valore.valoreRifiuto;
  }

  void _calcolaTotale() {
    if (_valoriRifiuti.isEmpty) return;
    final int qtaCarta = int.tryParse(_cartaController.text) ?? 0;
    final int qtaPlastica = int.tryParse(_plasticaController.text) ?? 0;
    final int qtaVetro = int.tryParse(_vetroController.text) ?? 0;
    final int qtaAlluminio = int.tryParse(_alluminioController.text) ?? 0;

    // CORREZIONE: Recupera anche il valore della carta
    double valCarta = _getValorePerTipo('Carta');
    double valPlastica = _getValorePerTipo('Plastica');
    double valVetro = _getValorePerTipo('Vetro');
    double valAlluminio = _getValorePerTipo('Alluminio');

    setState(() {
      // CORREZIONE: Aggiunge la carta al calcolo totale
      _totalePunti = (qtaCarta * valCarta) +
          (qtaPlastica * valPlastica) +
          (qtaVetro * valVetro) +
          (qtaAlluminio * valAlluminio);
    });
  }

  @override
  void dispose() {
    _cartaController.dispose();
    _plasticaController.dispose();
    _vetroController.dispose();
    _alluminioController.dispose();
    super.dispose();
  }

  // LOGICA MERGIATA: Logica del vecchio file adattata al nuovo contesto
  Future<void> _confermaOperazione() async {
    if (_totalePunti == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci almeno un rifiuto per continuare.")),
      );
      return;
    }

    // Mostra Dialog di Conferma
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma Conferimento"),
        content: Text(
            "Stai per guadagnare ${_totalePunti.toStringAsFixed(0)} punti!\n\n"
                "Ecopoint: ${widget.ecopointId}"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Conferma"),
          ),
        ],
      ),
    );

    if (conferma == true) {
      setState(() => _isLoading = true);

      // Chiamata al Service (preso dal vecchio file)
      // Nota: Convertiamo _totalePunti in int per compatibilità col vecchio service
      final result = await ContributionService.submitContribution(
          widget.ecopointId,
          _totalePunti.toInt()
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // SUCCESSO
        Navigator.pop(context); // Torna alla home
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // ERRORE
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore: ${result['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            // --- Info Ecopoint ---
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
                  Expanded(
                    child: Text(
                      "Ecopoint Rilevato:\n${widget.ecopointId}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("Cosa stai riciclando?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- Input Dinamici ---
            _buildInputRow(
                "Carta",
                "Fogli, giornale...",
                Icons.newspaper,
                _getValorePerTipo('Carta'),
                _cartaController,
                Colors.blue
            ),
            const SizedBox(height: 15),
            _buildInputRow(
                "Plastica",
                "Bottiglie, flaconi...",
                Icons.local_drink,
                _getValorePerTipo('Plastica'),
                _plasticaController,
                Colors.blue
            ),
            const SizedBox(height: 15),

            _buildInputRow(
                "Vetro",
                "Bottiglie, vasetti...",
                Icons.wine_bar,
                _getValorePerTipo('Vetro'),
                _vetroController,
                Colors.green
            ),
            const SizedBox(height: 15),

            _buildInputRow(
                "Alluminio",
                "Lattine, fogli...",
                Icons.takeout_dining,
                _getValorePerTipo('Alluminio'),
                _alluminioController,
                Colors.grey
            ),

            const SizedBox(height: 40),

            // --- Card Totale ---
            Card(
              elevation: 4,
              color: Colors.green[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("TOTALE PUNTI STIMATI", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2)),
                    const SizedBox(height: 5),
                    Text(
                      _totalePunti.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _confermaOperazione, // Chiama la funzione mergiata
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("CALCOLA E CONFERMA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, String sub, IconData icon, double multiplier, TextEditingController controller, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                  "Valore: ${multiplier.toStringAsFixed(1)} pti/pz",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])
              ),
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

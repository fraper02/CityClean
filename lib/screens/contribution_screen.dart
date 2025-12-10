import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityclean/models/valore_rifiuto.dart'; // Assicurati di avere questo import

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
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers per gli input
  // Nota: Manteniamo i controller specifici per le categorie principali per semplicità di UI,
  // ma potresti anche generare i controller dinamicamente se la lista cambia spesso.
  final _plasticaController = TextEditingController();
  final _vetroController = TextEditingController();
  final _alluminioController = TextEditingController();

  double _totalePunti = 0; // Cambiato a double perché i valori nel DB possono essere decimali

  @override
  void initState() {
    super.initState();
    _fetchWasteValues();

    _plasticaController.addListener(_calcolaTotale);
    _vetroController.addListener(_calcolaTotale);
    _alluminioController.addListener(_calcolaTotale);
  }

  Future<void> _fetchWasteValues() async {
    try {
      final response = await supabase
          .from('valore_rifiuto')
          .select();

      setState(() {
        _valoriRifiuti = List<ValoreRifiuto>.from(
            response.map((item) => ValoreRifiuto.fromJson(item)));
        _isLoading = false;
      });

      // Ricalcola subito nel caso ci siano valori di default (opzionale)
      _calcolaTotale();

    } catch (e) {
      setState(() {
        _errorMessage = "Errore caricamento valori: $e";
        _isLoading = false;
      });
    }
  }

  // Helper per ottenere il valore dal DB in base al nome (case-insensitive per sicurezza)
  double _getValorePerTipo(String tipo) {
    // Cerca nella lista scaricata un elemento che corrisponda al nome
    final valore = _valoriRifiuti.firstWhere(
          (element) => element.tipoRifiuto.toLowerCase() == tipo.toLowerCase(),
      orElse: () => ValoreRifiuto(id: 0, tipoRifiuto: '', valoreRifiuto: 0), // Fallback a 0
    );
    return valore.valoreRifiuto;
  }

  void _calcolaTotale() {
    // Se i dati non sono ancora caricati, non calcolare
    if (_valoriRifiuti.isEmpty) return;

    final int qtaPlastica = int.tryParse(_plasticaController.text) ?? 0;
    final int qtaVetro = int.tryParse(_vetroController.text) ?? 0;
    final int qtaAlluminio = int.tryParse(_alluminioController.text) ?? 0;

    // Recuperiamo i moltiplicatori dinamici
    double valPlastica = _getValorePerTipo('Plastica');
    double valVetro = _getValorePerTipo('Vetro');
    double valAlluminio = _getValorePerTipo('Alluminio');

    setState(() {
      _totalePunti = (qtaPlastica * valPlastica) +
          (qtaVetro * valVetro) +
          (qtaAlluminio * valAlluminio);
    });
  }

  @override
  void dispose() {
    _plasticaController.dispose();
    _vetroController.dispose();
    _alluminioController.dispose();
    super.dispose();
  }

  void _confermaOperazione() {
    if (_totalePunti == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci almeno un rifiuto per continuare.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma Conferimento"),
        content: Text(
            "Stai per guadagnare ${_totalePunti.toStringAsFixed(0)} punti!\n\n" // Arrotonda per pulizia
                "Ecopoint: ${widget.ecopointId}"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // TODO: Salva su Supabase nella tabella 'transazioni' o 'storico'
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Punti accreditati con successo!")),
              );
            },
            child: const Text("Conferma"),
          ),
        ],
      ),
    );
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
            // Passiamo il valore recuperato dal DB alla funzione di build
            _buildInputRow(
                "Plastica",
                "Bottiglie, flaconi...",
                Icons.local_drink,
                _getValorePerTipo('Plastica'), // Valore da DB
                _plasticaController,
                Colors.blue
            ),
            const SizedBox(height: 15),

            _buildInputRow(
                "Vetro",
                "Bottiglie, vasetti...",
                Icons.wine_bar,
                _getValorePerTipo('Vetro'), // Valore da DB
                _vetroController,
                Colors.green
            ),
            const SizedBox(height: 15),

            _buildInputRow(
                "Alluminio",
                "Lattine, fogli...",
                Icons.takeout_dining,
                _getValorePerTipo('Alluminio'), // Valore da DB
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
                      _totalePunti.toStringAsFixed(0), // Mostra intero
                      style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _confermaOperazione,
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
              // Mostra il moltiplicatore aggiornato
              Text(
                  "Valore: ${multiplier.toStringAsFixed(1)} pti/pz", // Es: "5.0 pti/pz"
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
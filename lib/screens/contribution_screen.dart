import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContributionScreen extends StatefulWidget {
  final String ecopointId;

  const ContributionScreen({super.key, required this.ecopointId});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  // --- VALORI HARDCODATI PER IL CALCOLO PUNTI ---
  static const int puntiPlastica = 5;   // Punti per unità
  static const int puntiVetro = 10;
  static const int puntiAlluminio = 8;

  // Controllers per gli input
  final _plasticaController = TextEditingController();
  final _vetroController = TextEditingController();
  final _alluminioController = TextEditingController();

  int _totalePunti = 0;

  @override
  void initState() {
    super.initState();
    // Aggiungiamo listener per ricalcolare i punti in tempo reale
    _plasticaController.addListener(_calcolaTotale);
    _vetroController.addListener(_calcolaTotale);
    _alluminioController.addListener(_calcolaTotale);
  }

  @override
  void dispose() {
    _plasticaController.dispose();
    _vetroController.dispose();
    _alluminioController.dispose();
    super.dispose();
  }

  void _calcolaTotale() {
    final int qtaPlastica = int.tryParse(_plasticaController.text) ?? 0;
    final int qtaVetro = int.tryParse(_vetroController.text) ?? 0;
    final int qtaAlluminio = int.tryParse(_alluminioController.text) ?? 0;

    setState(() {
      _totalePunti = (qtaPlastica * puntiPlastica) +
          (qtaVetro * puntiVetro) +
          (qtaAlluminio * puntiAlluminio);
    });
  }

  void _confermaOperazione() {
    if (_totalePunti == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci almeno un rifiuto per continuare.")),
      );
      return;
    }

    // Qui puoi chiamare il service per salvare i dati su Supabase
    // Per ora mostriamo il riepilogo locale come richiesto
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma Conferimento"),
        content: Text(
            "Stai per guadagnare $_totalePunti punti!\n\n"
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
              // TODO: Inviare dati al backend qui
              Navigator.pop(ctx); // Chiude dialog
              Navigator.pop(context); // Torna alla home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Punti accreditati con successo! (Simulazione)")),
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
      body: SingleChildScrollView(
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

            _buildInputRow("Plastica", "Bottiglie, flaconi...", Icons.local_drink, puntiPlastica, _plasticaController, Colors.blue),
            const SizedBox(height: 15),
            _buildInputRow("Vetro", "Bottiglie, vasetti...", Icons.wine_bar, puntiVetro, _vetroController, Colors.green),
            const SizedBox(height: 15),
            _buildInputRow("Alluminio", "Lattine, fogli...", Icons.takeout_dining, puntiAlluminio, _alluminioController, Colors.grey),

            const SizedBox(height: 40),

            // Card Totale
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
                      "$_totalePunti",
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

  Widget _buildInputRow(String label, String sub, IconData icon, int multiplier, TextEditingController controller, Color color) {
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
              Text("Valore: $multiplier pti/pz", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
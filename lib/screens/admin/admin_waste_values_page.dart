import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityclean/models/valore_rifiuto.dart';

class AdminWasteValuesPage extends StatefulWidget {
  const AdminWasteValuesPage({super.key});

  @override
  State<AdminWasteValuesPage> createState() => _AdminWasteValuesPageState();
}

class _AdminWasteValuesPageState extends State<AdminWasteValuesPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Future<List<ValoreRifiuto>> _wasteValuesFuture;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _wasteValuesFuture = _fetchWasteValues();
  }

  Future<List<ValoreRifiuto>> _fetchWasteValues() async {
    try {
      final response = await supabase
          .from('valore_rifiuto') // Assicurati che il nome tabella sia corretto
          .select()
          .order('id', ascending: true);

      final values = List<ValoreRifiuto>.from(
          response.map((item) => ValoreRifiuto.fromJson(item)));

      for (var value in values) {
        if (!_controllers.containsKey(value.id)) {
          _controllers[value.id] =
              TextEditingController(text: value.valoreRifiuto.toInt().toString());
        }
      }
      return values;
    } catch (e) {
      debugPrint("Errore nel caricamento dei valori: $e");
      rethrow;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> updatedValues = [];

      for (var entry in _controllers.entries) {
        final id = entry.key;
        final controller = entry.value;
        final newValue = double.tryParse(controller.text);

        if (newValue != null) {
          updatedValues.add({
            'id': id,
            'valoreRifiuto': newValue,
          });
        }
      }

      await supabase.from('valore_rifiuto').upsert(updatedValues);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Valori aggiornati con successo!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Più bello su web
            width: 400, // Non occupa tutto lo schermo su web
          ),
        );
      }
    } catch (e) {
      debugPrint("Errore salvataggio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          // 1. LIMITA LA LARGHEZZA PER SCHERMI GRANDI
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  const Text(
                    "Imposta Valore Rifiuti",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Definisci i punti assegnati per ogni tipo di rifiuto.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // --- Card Principale ---
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: FutureBuilder<List<ValoreRifiuto>>(
                        future: _wasteValuesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Errore: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("Nessun dato trovato."));
                          }

                          final wasteValues = snapshot.data!;

                          // 2. SCROLLBAR PER UTENTI DESKTOP
                          return Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // 3. GRIGLIA RESPONSIVE
                                    // LayoutBuilder ci permette di sapere quanto spazio abbiamo
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Su schermi larghi (> 600px) usiamo 2 colonne, altrimenti 1
                                        final int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                                        // Calcoliamo l'aspect ratio per non avere celle troppo alte
                                        final double childAspectRatio = constraints.maxWidth > 600 ? 4 : 3;

                                        return GridView.builder(
                                          shrinkWrap: true, // Importante dentro SingleChildScrollView
                                          physics: const NeverScrollableScrollPhysics(), // Lo scroll lo gestisce il genitore
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 10,
                                            childAspectRatio: childAspectRatio,
                                          ),
                                          itemCount: wasteValues.length,
                                          itemBuilder: (context, index) {
                                            final value = wasteValues[index];
                                            return _buildValueInputRow(
                                              label: value.tipoRifiuto,
                                              controller: _controllers[value.id]!,
                                            );
                                          },
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 40),

                                    // --- Bottone Salva ---
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: 200, // Larghezza fissa per il bottone su Web
                                        height: 50,
                                        child: ElevatedButton.icon(
                                          onPressed: _isLoading ? null : _saveChanges,
                                          icon: _isLoading
                                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                              : const Icon(Icons.save),
                                          label: Text(_isLoading ? "Salvataggio..." : "Salva Modifiche"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueInputRow({
    required String label,
    required TextEditingController controller,
  }) {
    // Nota: Ho rimosso il Padding esterno perché lo gestisce la GridView con 'spacing'
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis, // Evita errori se il testo è lungo
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: "0",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Più alto per cliccare facile col mouse
              suffixText: "pt",
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Richiesto' : null,
          ),
        ),
      ],
    );
  }
}
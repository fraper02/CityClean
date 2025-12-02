import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_list_ecopoints_page.dart'; // Importa la pagina lista

class AdminAddEcopointPage extends StatefulWidget {
  const AdminAddEcopointPage({super.key});

  @override
  State<AdminAddEcopointPage> createState() => _AdminAddEcopointPageState();
}

class _AdminAddEcopointPageState extends State<AdminAddEcopointPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Controllers
  final _nomeController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  // Variabile per la tipologia (Dropdown)
  String? _selectedTipologia;
  final List<String> _tipologie = ['Eco-compattatore', 'Raccolta oli', 'Raccolta Batterie', 'Sito di smaltimmento', 'Altro'];

  // Funzione per generare un ID casuale (simil-UUID)
  String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return "ECO-$now-$random";
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final idGenerato = _generateId();
      final lat = double.parse(_latController.text.replaceAll(',', '.'));
      final long = double.parse(_longController.text.replaceAll(',', '.'));

      await supabase.from('punto_raccolta').insert({
        'idpuntoraccolta': idGenerato,
        'nome': _nomeController.text.trim(),
        // 'indirizzo': null,
        'latitudine': lat,
        'longitudine': long,
        'tipologia': _selectedTipologia ?? 'Altro',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ecopunto aggiunto con successo!'), backgroundColor: Colors.green),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore salvataggio: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _nomeController.clear();
    _latController.clear();
    _longController.clear();
    setState(() {
      _selectedTipologia = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione con Pulsante per Lista
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Aggiungi Punto Raccolta",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Inserisci i dettagli del nuovo punto.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Naviga alla pagina della lista
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminListEcopointsPage()),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("Vedi Lista Ecopunti"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[800],
                    elevation: 0,
                  ),
                )
              ],
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sezione Dati Generali
                      const Text("Dati Generali", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomeController,
                              decoration: _inputDecoration("Nome Punto", Icons.label),
                              validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTipologia,
                              decoration: _inputDecoration("Tipologia Rifiuti", Icons.category),
                              items: _tipologie.map((type) {
                                return DropdownMenuItem(value: type, child: Text(type));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedTipologia = val),
                              validator: (value) => value == null ? 'Seleziona una tipologia' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Sezione Coordinate
                      const Text("Posizione Geografica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration("Latitudine (es. 40.712)", Icons.map),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Obbligatorio';
                                if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Numero non valido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _longController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration("Longitudine (es. 14.001)", Icons.map),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Obbligatorio';
                                if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Numero non valido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Bottone di Invio
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitForm,
                          icon: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save),
                          label: Text(_isLoading ? "Salvataggio in corso..." : "Aggiungi Punto Raccolta"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
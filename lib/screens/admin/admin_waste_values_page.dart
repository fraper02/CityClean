import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityclean/models/valore_rifiuto.dart';

class AdminWasteValuesPage extends StatefulWidget {
  const AdminWasteValuesPage({super.key});

  @override
  AdminWasteValuesPageState createState() => AdminWasteValuesPageState();
}

class AdminWasteValuesPageState extends State<AdminWasteValuesPage> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;
  List<ValoreRifiuto> _wasteValues = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase
          .from('valore_rifiuto')
          .select()
          .order('tipo_rifiuto', ascending: true); 

      if (!mounted) return;

      setState(() {
        _wasteValues = List<ValoreRifiuto>.from(
            response.map((item) => ValoreRifiuto.fromJson(item)));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Errore caricamento dati: $e";
        _isLoading = false;
      });
    }
  }

  void refreshWasteValues(){
    _loadData();
  }

  void createNewWasteValue(){
    _showEditDialog(null);
  }

  Future<void> _deleteValue(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Conferma eliminazione"),
        content: const Text("Sei sicuro di voler eliminare questo tipo di rifiuto?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annulla")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Elimina"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('valore_rifiuto').delete().eq('id', id);
        _loadData(); 
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Elemento eliminato")));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore eliminazione: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _saveValue(BuildContext context, ValoreRifiuto? original, String nome, double valore) async {
    try {
      if (original == null) {
        await supabase.from('valore_rifiuto').insert({
          'tipo_rifiuto': nome,
          'valore_rifiuto': valore,
        });
      } else {
        await supabase.from('valore_rifiuto').update({
          'tipo_rifiuto': nome,
          'valore_rifiuto': valore,
        }).eq('id', original.id);
      }

      if (context.mounted) {
        Navigator.pop(context); 
        _loadData(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Operazione completata con successo"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore salvataggio: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : _wasteValues.isEmpty
          ? const Center(child: Text("Nessun tipo di rifiuto configurato."))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: _wasteValues.length,
              itemBuilder: (context, index) => _buildWasteCard(_wasteValues[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        backgroundColor: Colors.green[700],
        tooltip: 'Aggiungi Tipo Rifiuto',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWasteCard(ValoreRifiuto item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[50],
          child: Icon(_getIconForType(item.tipoRifiuto), color: Colors.green[700]),
        ),
        title: Text(item.tipoRifiuto, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item.valoreRifiuto.toStringAsFixed(2)} punti al pezzo"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => _showEditDialog(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteValue(context, item.id),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastica')) return Icons.local_drink;
    if (t.contains('vetro')) return Icons.wine_bar;
    if (t.contains('alluminio') || t.contains('lattina')) return Icons.takeout_dining;
    if (t.contains('carta') || t.contains('cartone')) return Icons.newspaper;
    return Icons.delete_outline;
  }

  void _showEditDialog(ValoreRifiuto? item) {
    final isCreating = item == null;
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: item?.tipoRifiuto ?? '');
    final valoreController = TextEditingController(text: item?.valoreRifiuto.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isCreating ? "Nuovo Tipo Rifiuto" : "Modifica Valore"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo Rifiuto (es. Plastica)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: valoreController,
                    decoration: const InputDecoration(
                      labelText: 'Punti per unità',
                      suffixText: 'pt',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null)
                        ? 'Inserisci un numero valido'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _saveValue(
                    context, 
                    item,
                    nomeController.text.trim(),
                    double.parse(valoreController.text),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
              child: const Text("Salva"),
            ),
          ],
        );
      },
    );
  }
}

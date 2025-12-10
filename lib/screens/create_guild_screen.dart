import 'package:flutter/material.dart';
import '../controllers/guild_controller.dart';

class CreateGuildScreen extends StatefulWidget {
  final GuildController controller;

  const CreateGuildScreen({super.key, required this.controller});

  @override
  State<CreateGuildScreen> createState() => _CreateGuildScreenState();
}

class _CreateGuildScreenState extends State<CreateGuildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double _maxCapacity = 50.0;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGuild() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isCreating = true);

      try {
        await widget.controller.createGuild(
          name: _nameController.text,
          maxCapacity: _maxCapacity.toInt(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gilda creata con successo!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore: ${e.toString()}"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isCreating = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Crea Nuova Gilda"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dettagli Gilda",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome della Gilda",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Il nome è obbligatorio.';
                  }
                  if (value.length < 3) {
                    return 'Il nome deve essere di almeno 3 caratteri.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Text("Capacità Massima: ${_maxCapacity.toInt()} membri", style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _maxCapacity,
                min: 5,
                max: 200,
                divisions: 39, // (200 - 5) / 5
                label: _maxCapacity.toInt().toString(),
                onChanged: (value) {
                  setState(() => _maxCapacity = value);
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createGuild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isCreating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Crea Gilda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

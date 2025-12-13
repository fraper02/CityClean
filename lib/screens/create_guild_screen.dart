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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true, // Per far vedere l'header sotto l'appbar
      appBar: AppBar(
        title: const Text("Nuova Gilda", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. SFONDO VERDE CURVO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[800]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0), // Spazio per l'AppBar
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Fonda la tua squadra",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. CONTENUTO SCORREVOLE
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 140, 20, 20), // Top padding per non coprire l'header
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // CARD DEL FORM
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dettagli Principali",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),

                          // INPUT NOME
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: "Nome della Gilda",
                              hintText: "Es. Guerrieri del Verde",
                              prefixIcon: Icon(Icons.edit_rounded, color: Colors.green[700]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Il nome è obbligatorio.';
                              if (value.length < 3) return 'Almeno 3 caratteri.';
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // SLIDER CAPACITÀ
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Capacità Membri", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${_maxCapacity.toInt()}",
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.green[600],
                              inactiveTrackColor: Colors.green[100],
                              thumbColor: Colors.white,
                              overlayColor: Colors.green.withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                              valueIndicatorColor: Colors.green[700],
                            ),
                            child: Slider(
                              value: _maxCapacity,
                              min: 5,
                              max: 200,
                              divisions: 39,
                              label: _maxCapacity.toInt().toString(),
                              onChanged: (value) => setState(() => _maxCapacity = value),
                            ),
                          ),
                          Center(
                            child: Text(
                              _getCapacityLabel(_maxCapacity),
                              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // INFO BOX
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Come creatore, sarai automaticamente il Capo Gilda e potrai gestirne i membri.",
                              style: TextStyle(color: Colors.blue[900], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BUTTON CREA
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createGuild,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.green.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isCreating
                            ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        )
                            : const Text("Crea Gilda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCapacityLabel(double value) {
    if (value <= 20) return "Gruppo intimo e gestibile";
    if (value <= 50) return "Dimensione standard";
    if (value <= 100) return "Grande comunità";
    return "Esercito ecologico!";
  }
}
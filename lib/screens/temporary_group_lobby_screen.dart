import 'package:cityclean/controllers/temporary_group_controller.dart';
import 'package:flutter/material.dart';

class TemporaryGroupLobbyScreen extends StatefulWidget {
  final TemporaryGroupController controller;

  const TemporaryGroupLobbyScreen({super.key, required this.controller});

  @override
  State<TemporaryGroupLobbyScreen> createState() =>
      _TemporaryGroupLobbyScreenState();
}

class _TemporaryGroupLobbyScreenState extends State<TemporaryGroupLobbyScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanges);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanges);
    super.dispose();
  }

  void _handleControllerChanges() {
    if (mounted && widget.controller.error != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Attenzione', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(widget.controller.error!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              key: const Key('btn_error_ok'), // KEY AGGIUNTA
              child: const Text('OK', style: TextStyle(color: Colors.green)),
              onPressed: () {
                widget.controller.clearError();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuovo Gruppo'),
        content: TextField(
          key: const Key('input_group_name'), // KEY AGGIUNTA
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Nome del gruppo",
            hintText: "Es. Pulizia Parco Centro",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancel_create'), // KEY AGGIUNTA
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_create'), // KEY AGGIUNTA
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(ctx);
                widget.controller.createGroup(nameController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Crea', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unisciti al Gruppo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Inserisci il codice invito fornito dal creatore."),
            const SizedBox(height: 15),
            TextField(
              key: const Key('input_invite_code'), // KEY AGGIUNTA
              controller: codeController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "CODICE",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancel_join'), // KEY AGGIUNTA
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_join'), // KEY AGGIUNTA
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                Navigator.pop(ctx);
                widget.controller.joinGroup(codeController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Entra', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: 0, left: 0, right: 0,
            height: 330,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[800]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
            ),
          ),

          // Tasto Indietro personalizzato
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('btn_back_lobby'), // KEY AGGIUNTA
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Icon(Icons.groups_rounded, size: 60, color: Colors.green[700]),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Gruppi Temporanei",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Crea un gruppo veloce per un evento\no unisciti ai tuoi amici tramite codice.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text("Scade automaticamente dopo 24h", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Cards/Buttons Section
                    _buildActionCard(
                      key: const Key('card_create_group'), // KEY AGGIUNTA
                      icon: Icons.add_circle_outline,
                      title: "Crea Nuovo Gruppo",
                      subtitle: "Diventa il capo e invita altri utenti.",
                      color: Colors.green[700]!,
                      onTap: () => _showCreateGroupDialog(context),
                    ),

                    const SizedBox(height: 20),

                    _buildActionCard(
                      key: const Key('card_join_group'), // KEY AGGIUNTA
                      icon: Icons.qr_code_rounded,
                      title: "Unisciti con Codice",
                      subtitle: "Hai un codice invito? Inseriscilo qui.",
                      color: Colors.green[600]!,
                      isOutlined: true,
                      onTap: () => _showJoinGroupDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.controller.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            )
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required Key key, // Richiesto Key qui
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Material(
      color: Colors.white,
      elevation: isOutlined ? 0 : 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: key, // KEY ASSEGNATA
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isOutlined ? Border.all(color: color, width: 2) : null,
            boxShadow: isOutlined ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
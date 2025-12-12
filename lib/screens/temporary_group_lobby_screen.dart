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
    if (widget.controller.error != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Attenzione'),
          content: Text(widget.controller.error!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      widget.controller.clearError();
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crea Nuovo Gruppo'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Nome del gruppo'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            child: const Text('Crea'),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                widget.controller.createGroup(textController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unisciti a un Gruppo'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Codice di invito'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            child: const Text('Unisciti'),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                widget.controller.joinGroup(textController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruppi Temporanei'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.groups_3_outlined, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Non fai parte di nessun gruppo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Crea un nuovo gruppo per sfidare i tuoi amici o unisciti a uno esistente!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Crea Gruppo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => _showCreateGroupDialog(context),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: const Text('Unisciti con Codice'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => _showJoinGroupDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

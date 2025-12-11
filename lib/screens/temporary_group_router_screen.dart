import 'package:cityclean/controllers/temporary_group_controller.dart';
import 'package:cityclean/screens/temporary_group_dashboard_screen.dart';
import 'package:cityclean/screens/temporary_group_lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TemporaryGroupRouterScreen extends StatelessWidget {
  const TemporaryGroupRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa ChangeNotifierProvider per creare e fornire il controller al widget tree sottostante.
    return ChangeNotifierProvider(
      create: (_) => TemporaryGroupController(),
      child: Consumer<TemporaryGroupController>(
        builder: (context, controller, child) {
          // Durante il caricamento iniziale, mostra uno spinner.
          if (controller.isLoading && controller.group == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Se c'è un errore, mostralo.
          if (controller.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Errore')),
              body: Center(child: Text(controller.error!)),
            );
          }

          // Se l'utente è in un gruppo, mostra la dashboard.
          if (controller.group != null) {
            return const TemporaryGroupDashboardScreen();
          } else {
            // Altrimenti, mostra la lobby per creare/unirsi a un gruppo.
            return TemporaryGroupLobbyScreen(controller: controller);
          }
        },
      ),
    );
  }
}

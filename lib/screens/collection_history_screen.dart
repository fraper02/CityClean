import 'package:flutter/material.dart';

class CollectionHistoryScreen extends StatelessWidget {
  const CollectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Raccolte'),
      ),
      body: const Center(
        child: Text('Qui verrà visualizzato lo storico delle raccolte.'),
      ),
    );
  }
}

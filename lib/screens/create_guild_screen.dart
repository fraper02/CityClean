import 'package:flutter/material.dart';

class CreateGuildScreen extends StatelessWidget {
  const CreateGuildScreen({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dettagli Gilda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Nome Gilda
            const TextField(
              decoration: InputDecoration(
                labelText: "Nome della Gilda",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shield_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Descrizione
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descrizione",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Logica per salvare la gilda
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gilda creata con successo!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Crea Gilda",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
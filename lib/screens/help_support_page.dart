import 'package:flutter/material.dart';

class AiutoESupportoPage extends StatelessWidget {
  const AiutoESupportoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aiuto e Supporto"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Supporto",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _textTile(
            title: "FAQ",
            subtitle: "Domande frequenti sull’utilizzo dell’app",
            onTap: () {},
          ),

          _textTile(
            title: "Guida rapida",
            subtitle: "Come usare le principali funzionalità",
            onTap: () {},
          ),

          const SizedBox(height: 20),
          const Text(
            "Assistenza",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _textTile(
            title: "Contatta il supporto",
            subtitle: "Invia un messaggio al nostro team",
            onTap: () {},
          ),

          _textTile(
            title: "Segnala un problema",
            subtitle: "Comunicaci eventuali bug o malfunzionamenti",
            onTap: () {},
          ),

          const SizedBox(height: 20),
          const Text(
            "Informazioni",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _textTile(
            title: "Termini di servizio",
            subtitle: "Consulta i termini di utilizzo dell’app",
            onTap: () {},
          ),

          _textTile(
            title: "Privacy Policy",
            subtitle: "Scopri come gestiamo i tuoi dati",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _textTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyESicurezzaPage extends StatefulWidget {
  const PrivacyESicurezzaPage({super.key});

  @override
  State<PrivacyESicurezzaPage> createState() => _PrivacyESicurezzaPageState();
}

class _PrivacyESicurezzaPageState extends State<PrivacyESicurezzaPage> {
  bool hideSensitiveInfo = true;
  bool twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy e Sicurezza"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Privacy",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // TOGGLE 1
          _switchTile(
            title: "Nascondi info sensibili",
            subtitle: "Oscura i dati quando l’app è in background",
            value: hideSensitiveInfo,
            onChanged: (val) {
              setState(() => hideSensitiveInfo = val);
            },
          ),

          const SizedBox(height: 20),
          const Text("Sicurezza",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // TOGGLE 2
          _switchTile(
            title: "Autenticazione a due fattori",
            subtitle: "Richiede un codice aggiuntivo al login",
            value: twoFactorAuth,
            onChanged: (val) {
              setState(() => twoFactorAuth = val);
            },
          ),

          const SizedBox(height: 20),
          const Text("Gestione dei dati",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          _textTile(
            title: "Scarica i tuoi dati",
            subtitle: "Ottieni una copia delle tue informazioni",
            onTap: () {},
          ),
          _textTile(
            title: "Elimina account",
            subtitle: "Rimuovi definitivamente il tuo profilo",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Tile con toggle (switch)
  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
        Text(subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 10),
        Container(height: 1, color: Colors.black12),
        const SizedBox(height: 10),
      ],
    );
  }

  // Tile testuale semplice
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

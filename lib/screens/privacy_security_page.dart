import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // Stati Mockup (Non funzionali perché WIP)
  final bool _hideSensitiveInfo = true;
  final bool _twoFactorAuth = false;
  final bool _biometricAuth = false;

  // Helper per mostrare che è in lavorazione
  void _showWipMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.construction, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text("Funzionalità in fase di sviluppo.")),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Privacy e Sicurezza", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          key: const Key('btn_back_privacy'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // CARD 1: PRIVACY (WIP)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSectionHeader("Privacy Dati"),

                  // ORA WIP
                  _buildSwitchTile(
                    key: const Key('switch_hide_sensitive'),
                    title: "Nascondi info sensibili",
                    subtitle: "Oscura i dati nelle anteprime recenti",
                    value: _hideSensitiveInfo,
                    isWip: true,
                    onChanged: (val) => _showWipMessage(),
                  ),

                  const Divider(indent: 20, endIndent: 20),

                  // ORA WIP
                  _buildActionTile(
                    key: const Key('btn_manage_data'),
                    title: "Gestione dati personali",
                    subtitle: "Richiedi copia o eliminazione dati",
                    isWip: true,
                    onTap: _showWipMessage,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD 2: SICUREZZA (WIP)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSectionHeader("Sicurezza Account"),

                  _buildSwitchTile(
                    key: const Key('switch_2fa'),
                    title: "Autenticazione a due fattori",
                    subtitle: "Aumenta la sicurezza all'accesso",
                    value: _twoFactorAuth,
                    isWip: true,
                    onChanged: (val) => _showWipMessage(),
                  ),

                  const Divider(indent: 20, endIndent: 20),

                  _buildSwitchTile(
                    key: const Key('switch_biometric'),
                    title: "Accesso Biometrico",
                    subtitle: "Usa FaceID o Impronta",
                    value: _biometricAuth,
                    isWip: true,
                    onChanged: (val) => _showWipMessage(),
                  ),

                  const Divider(indent: 20, endIndent: 20),

                  _buildActionTile(
                    key: const Key('btn_change_password'),
                    title: "Cambia Password",
                    subtitle: "Aggiorna la tua password",
                    isWip: true,
                    onTap: _showWipMessage,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD 3: LEGALE (Funzionante con Mockup Pages)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSectionHeader("Informazioni Legali"),
                  _buildActionTile(
                    key: const Key('btn_terms'),
                    title: "Termini di Servizio",
                    subtitle: "Regole di utilizzo dell'app",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const _TermsPage()));
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _buildActionTile(
                    key: const Key('btn_privacy_policy'),
                    title: "Privacy Policy",
                    subtitle: "Come trattiamo i tuoi dati",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const _PrivacyPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.2
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isWip = false,
    Key? key,
  }) {
    return SwitchListTile.adaptive(
      key: key,
      activeColor: Colors.green[700],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          if (isWip) ...[
            const SizedBox(width: 8),
            _buildWipBadge(),
          ]
        ],
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isWip = false,
    Key? key,
  }) {
    return ListTile(
      key: key,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          if (isWip) ...[
            const SizedBox(width: 8),
            _buildWipBadge(),
          ]
        ],
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildWipBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Text(
        "WIP",
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800]),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// MOCKUP PAGE: TERMINI DI SERVIZIO
// --------------------------------------------------------------------------
class _TermsPage extends StatelessWidget {
  const _TermsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Termini di Servizio"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ultimo aggiornamento: 12 Ottobre 2023", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            _buildParagraph("1. Accettazione dei Termini",
                "Scaricando o utilizzando l'app CityClean, accetti automaticamente questi termini. Ti invitiamo a leggerli attentamente prima di utilizzare l'app."),

            _buildParagraph("2. Utilizzo dell'App",
                "CityClean è progettata per aiutare i cittadini a organizzare eventi di pulizia e conferire correttamente i rifiuti. È vietato utilizzare l'app per scopi illegali, diffamatori o dannosi."),

            _buildParagraph("3. Account Utente",
                "Sei responsabile della sicurezza del tuo account e della tua password. CityClean non è responsabile per eventuali perdite derivanti dall'accesso non autorizzato al tuo account."),

            _buildParagraph("4. Contenuti Generati dagli Utenti",
                "Gli utenti possono caricare foto e descrizioni. Ti impegni a caricare solo contenuti veritieri e rispettosi. Ci riserviamo il diritto di rimuovere contenuti inappropriati."),

            _buildParagraph("5. Modifiche ai Termini",
                "Ci riserviamo il diritto di aggiornare questi termini in qualsiasi momento. Continueremo a notificare gli utenti di eventuali modifiche significative."),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: const Text("Ho capito", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// MOCKUP PAGE: PRIVACY POLICY
// --------------------------------------------------------------------------
class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ultimo aggiornamento: 12 Ottobre 2023", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            _buildParagraph("1. Dati che raccogliamo",
                "Raccogliamo informazioni che ci fornisci direttamente, come nome, email e foto profilo quando crei un account. Raccogliamo anche dati sulla tua posizione quando organizzi o partecipi a eventi, previo tuo consenso."),

            _buildParagraph("2. Come utilizziamo i tuoi dati",
                "Utilizziamo le tue informazioni per fornire, mantenere e migliorare i nostri servizi, come mostrarti eventi di pulizia nelle vicinanze e gestire le classifiche delle Gilde."),

            _buildParagraph("3. Condivisione dei dati",
                "Non vendiamo i tuoi dati personali a terzi. Possiamo condividere informazioni aggregate o anonime che non ti identificano direttamente per fini statistici o di ricerca ambientale."),

            _buildParagraph("4. Sicurezza dei dati",
                "Adottiamo misure di sicurezza ragionevoli per proteggere i tuoi dati da accessi non autorizzati, ma ricorda che nessun metodo di trasmissione su Internet è sicuro al 100%."),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: const Text("Chiudi", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Aiuto e Supporto", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          key: const Key('btn_back_help'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // CARD 1: RISORSE
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSectionHeader("Risorse Utili"),
                  _buildListTile(
                    key: const Key('btn_faq'),
                    icon: Icons.question_answer_outlined,
                    color: Colors.blue,
                    title: "FAQ",
                    subtitle: "Domande frequenti",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const _FaqScreen()));
                    },
                  ),
                  const Divider(indent: 70),
                  _buildListTile(
                    key: const Key('btn_guide'),
                    icon: Icons.menu_book_rounded,
                    color: Colors.orange,
                    title: "Guida Rapida",
                    subtitle: "Impara a usare l'app",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const _GuideScreen()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD 2: ASSISTENZA
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSectionHeader("Assistenza"),
                  _buildListTile(
                    key: const Key('btn_contact_support'),
                    icon: Icons.headset_mic_outlined,
                    color: Colors.green,
                    title: "Contatta il Supporto",
                    subtitle: "Parla con il nostro team",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const _ContactSupportScreen(title: "Contatta Supporto")));
                    },
                  ),
                  const Divider(indent: 70),
                  _buildListTile(
                    key: const Key('btn_report_bug'),
                    icon: Icons.bug_report_outlined,
                    color: Colors.red,
                    title: "Segnala un Problema",
                    subtitle: "Hai trovato un bug?",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const _ContactSupportScreen(title: "Segnala Bug", isBugReport: true)));
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

  Widget _buildListTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Key? key,
  }) {
    return ListTile(
      key: key,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// -----------------------------------------------------------
// SOTTOSCHERMATE IMPLEMENTATE (FAQ, GUIDA, CONTATTI)
// -----------------------------------------------------------

class _FaqScreen extends StatelessWidget {
  const _FaqScreen();

  final List<Map<String, String>> faqs = const [
    {
      "question": "Come guadagno punti?",
      "answer": "Guadagni punti partecipando agli eventi di pulizia, completando le missioni giornaliere o conferendo correttamente i rifiuti presso le isole ecologiche partner."
    },
    {
      "question": "Come creo una gilda?",
      "answer": "Vai nella sezione Gilde dal menu principale, tocca il pulsante '+' in basso a destra e compila i dettagli. Potrai invitare i tuoi amici subito dopo."
    },
    {
      "question": "L'app è gratuita?",
      "answer": "Sì, CityClean è completamente gratuita per tutti i cittadini che vogliono contribuire a un ambiente più pulito."
    },
    {
      "question": "Posso cancellare la mia iscrizione?",
      "answer": "Certamente. Puoi richiedere la cancellazione del tuo account nella sezione Privacy e Sicurezza > Gestione Dati."
    },
    {
      "question": "Cosa succede se segnalo un bug?",
      "answer": "Il nostro team tecnico analizzerà la segnalazione. Se il bug viene confermato e risolto grazie al tuo aiuto, potresti ricevere un badge speciale!"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Domande Frequenti"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(faqs[index]["question"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(faqs[index]["answer"]!),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuideScreen extends StatefulWidget {
  const _GuideScreen();

  @override
  State<_GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<_GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> steps = [
    {
      "title": "Benvenuto in CityClean",
      "desc": "La tua app per rendere la città più pulita e verde. Scopri come fare la differenza in pochi passi.",
      "icon": Icons.eco_rounded,
      "color": Colors.green,
    },
    {
      "title": "Mappa e Segnalazioni",
      "desc": "Usa la mappa per trovare eventi di pulizia vicino a te o per segnalare rifiuti abbandonati.",
      "icon": Icons.map_rounded,
      "color": Colors.orange,
    },
    {
      "title": "Gilde e Community",
      "desc": "Unisciti a una Gilda per collaborare con gli amici. Insieme potete scalare le classifiche!",
      "icon": Icons.groups_rounded,
      "color": Colors.purple,
    },
    {
      "title": "Premi e Badge",
      "desc": "Ogni azione positiva ti dà punti. Riscatta premi reali e colleziona badge unici.",
      "icon": Icons.emoji_events_rounded,
      "color": Colors.amber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guida Rapida"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(color: step['color'].withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(step['icon'], size: 80, color: step['color']),
                      ),
                      const SizedBox(height: 40),
                      Text(step['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Text(step['desc'], style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 10,
                width: _currentPage == index ? 20 : 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.green[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              )),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ContactSupportScreen extends StatelessWidget {
  final String title;
  final bool isBugReport;

  const _ContactSupportScreen({required this.title, this.isBugReport = false});

  @override
  Widget build(BuildContext context) {
    final TextEditingController msgController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isBugReport ? Colors.red[700] : Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Come possiamo aiutarti?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              isBugReport
                  ? "Descrivi il problema tecnico che hai riscontrato. Più dettagli ci dai, prima risolveremo!"
                  : "Hai dubbi o suggerimenti? Scrivici un messaggio.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: msgController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Scrivi qui il tuo messaggio...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (msgController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Messaggio inviato! Ti risponderemo presto.")));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBugReport ? Colors.red[700] : Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("INVIA MESSAGGIO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:cityclean/controllers/admin/admin_prizes_controller.dart';
import 'package:cityclean/models/partner.dart';
import 'package:cityclean/models/prizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // NECESSARIO PER PICKER
import 'package:latlong2/latlong.dart'; // NECESSARIO PER PICKER

const Color adminPrimaryColor = Color(0xFF2E7D32);

class AdminRewardsPage extends StatefulWidget {
  const AdminRewardsPage({super.key});

  @override
  AdminRewardsPageState createState() => AdminRewardsPageState();
}

class AdminRewardsPageState extends State<AdminRewardsPage> with SingleTickerProviderStateMixin {
  late final AdminPrizesController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = AdminPrizesController();
    _tabController = TabController(length: 2, vsync: this);
    _controller.loadAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void refreshRewards() {
    _controller.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.card_giftcard), text: "Premi"),
            Tab(icon: Icon(Icons.business), text: "Partner"),
          ],
        ),
      ),
      body: ValueListenableBuilder<AdminPrizesState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == AdminPrizesState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == AdminPrizesState.error) {
            return Center(child: Text(_controller.errorMessage.value));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPrizesTab(),
              _buildPartnersTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrizesTab() {
    return Scaffold(
      body: ValueListenableBuilder<List<Prize>>(
        valueListenable: _controller.prizes,
        builder: (context, prizes, _) {
          if (prizes.isEmpty) {
            return const Center(child: Text("Nessun premio trovato."));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: prizes.length,
            itemBuilder: (context, index) => _buildPrizeCard(prizes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPrizeDialog(null),
        backgroundColor: adminPrimaryColor,
        tooltip: 'Aggiungi Premio',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPartnersTab() {
    return Scaffold(
      body: ValueListenableBuilder<List<Partner>>(
        valueListenable: _controller.partners,
        builder: (context, partners, _) {
          if (partners.isEmpty) {
            return const Center(child: Text("Nessun partner trovato."));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: partners.length,
            itemBuilder: (context, index) => _buildPartnerCard(partners[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPartnerDialog(null),
        backgroundColor: adminPrimaryColor,
        tooltip: 'Aggiungi Partner',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPrizeCard(Prize prize) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(prize.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Partner: ${prize.partner?.nome ?? 'N/D'} | Qty: ${prize.quantitaDisponibile}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${prize.costoPunti} Punti", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showPrizeDialog(prize)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _controller.deletePrize(context, prize.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(Partner partner) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile( // Usiamo ExpansionTile per mostrare i dettagli extra
        title: Text(partner.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(partner.descrizione ?? 'Nessuna descrizione', maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (partner.indirizzo != null) Text("📍 Indirizzo: ${partner.indirizzo}"),
                if (partner.latitudine != null) Text("🌐 GPS: ${partner.latitudine}, ${partner.longitudine}"),
                if (partner.link != null) Text("🔗 Sito: ${partner.link}"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Modifica"),
                        onPressed: () => _showPartnerDialog(partner)
                    ),
                    TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text("Elimina", style: TextStyle(color: Colors.red)),
                        onPressed: () => _controller.deletePartner(context, partner.idpartner)
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showPrizeDialog(Prize? prize) {
    // ... (Codice Prize dialog invariato, omesso per brevità ma incluso nel contesto mentale)
    final isCreating = prize == null;
    final formKey = GlobalKey<FormState>();

    String? selectedPartnerId = prize?.idPartner;
    final nomeController = TextEditingController(text: prize?.nome ?? '');
    final descController = TextEditingController(text: prize?.descrizione ?? '');
    final costoController = TextEditingController(text: prize?.costoPunti.toString() ?? '');
    final qtyController = TextEditingController(text: prize?.quantitaDisponibile.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isCreating ? "Nuovo Premio" : "Modifica Premio"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome Premio'), validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null),
                  TextFormField(controller: descController, decoration: const InputDecoration(labelText: 'Descrizione')),
                  TextFormField(controller: costoController, decoration: const InputDecoration(labelText: 'Costo in Punti'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'Valore non valido' : null),
                  TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantità Disponibile'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'Valore non valido' : null),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<Partner>>(
                    valueListenable: _controller.partners,
                    builder: (context, partners, _) {
                      return DropdownButtonFormField<String>(
                        value: selectedPartnerId,
                        decoration: const InputDecoration(labelText: 'Partner', border: OutlineInputBorder()),
                        hint: const Text("Seleziona un partner"),
                        items: partners.map((p) => DropdownMenuItem(value: p.idpartner, child: Text(p.nome))).toList(),
                        onChanged: (value) => selectedPartnerId = value,
                        validator: (v) => v == null ? 'Campo obbligatorio' : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newPrize = Prize(
                    id: prize?.id ?? 'PRIZE-${DateTime.now().millisecondsSinceEpoch}',
                    nome: nomeController.text,
                    descrizione: descController.text,
                    costoPunti: int.parse(costoController.text),
                    quantitaDisponibile: int.parse(qtyController.text),
                    idPartner: selectedPartnerId!,
                  );
                  if (isCreating) {
                    _controller.createPrize(context, newPrize);
                  } else {
                    _controller.updatePrize(context, newPrize);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Salva"),
            ),
          ],
        );
      },
    );
  }

  // --- DIALOGO PARTNER AGGIORNATO ---
  void _showPartnerDialog(Partner? partner) {
    final isCreating = partner == null;
    final formKey = GlobalKey<FormState>();

    final nomeController = TextEditingController(text: partner?.nome ?? '');
    final descController = TextEditingController(text: partner?.descrizione ?? '');
    final linkController = TextEditingController(text: partner?.link ?? '');
    final indirizzoController = TextEditingController(text: partner?.indirizzo ?? '');
    final latController = TextEditingController(text: partner?.latitudine?.toString() ?? '');
    final lonController = TextEditingController(text: partner?.longitudine?.toString() ?? '');

    void pickLocationOnMap(BuildContext dialogContext) async {
      double startLat = double.tryParse(latController.text.replaceAll(',', '.')) ?? 40.6824;
      double startLng = double.tryParse(lonController.text.replaceAll(',', '.')) ?? 14.7681;

      final LatLng? pickedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => _LocationPickerScreen(initialCenter: LatLng(startLat, startLng)),
        ),
      );

      if (pickedLocation != null) {
        latController.text = pickedLocation.latitude.toStringAsFixed(6);
        lonController.text = pickedLocation.longitude.toStringAsFixed(6);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isCreating ? "Nuovo Partner" : "Modifica Partner"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome Partner'), validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null),
                  const SizedBox(height: 10),
                  TextFormField(controller: descController, decoration: const InputDecoration(labelText: 'Descrizione')),
                  const SizedBox(height: 10),
                  TextFormField(controller: linkController, decoration: const InputDecoration(labelText: 'Sito Web (URL)')),
                  const SizedBox(height: 10),
                  TextFormField(controller: indirizzoController, decoration: const InputDecoration(labelText: 'Indirizzo (Via, Città)')),
                  const SizedBox(height: 20),

                  const Text("Posizione", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => pickLocationOnMap(ctx),
                    icon: const Icon(Icons.map),
                    label: const Text("📍 Seleziona su Mappa"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.blue[900],
                        minimumSize: const Size(double.infinity, 40)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latController,
                          decoration: const InputDecoration(labelText: 'Latitudine', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: lonController,
                          decoration: const InputDecoration(labelText: 'Longitudine', border: OutlineInputBorder()),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Parsing sicuro coordinate
                  double? lat;
                  double? lon;
                  if (latController.text.isNotEmpty) lat = double.tryParse(latController.text.replaceAll(',', '.'));
                  if (lonController.text.isNotEmpty) lon = double.tryParse(lonController.text.replaceAll(',', '.'));

                  final newPartner = Partner(
                    idpartner: partner?.idpartner ?? 'PARTNER-${DateTime.now().millisecondsSinceEpoch}',
                    nome: nomeController.text,
                    descrizione: descController.text,
                    link: linkController.text,
                    indirizzo: indirizzoController.text,
                    latitudine: lat,
                    longitudine: lon,
                  );

                  if (isCreating) {
                    _controller.createPartner(context, newPartner);
                  } else {
                    _controller.updatePartner(context, newPartner);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Salva"),
            ),
          ],
        );
      },
    );
  }
}

// --- LOCATION PICKER SCREEN (Riutilizzato) ---
class _LocationPickerScreen extends StatefulWidget {
  final LatLng initialCenter;
  const _LocationPickerScreen({required this.initialCenter});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  late LatLng _pickedPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _pickedPosition = widget.initialCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleziona Posizione Partner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _pickedPosition),
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _pickedPosition = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.unisa.cityclean',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _pickedPosition),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text("CONFERMA POSIZIONE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
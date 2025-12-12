import 'package:cityclean/controllers/admin/admin_prizes_controller.dart';
import 'package:cityclean/models/partner.dart';
import 'package:cityclean/models/prizes.dart';
import 'package:flutter/material.dart';

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
      child: ListTile(
        title: Text(partner.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(partner.descrizione ?? 'Nessuna descrizione'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showPartnerDialog(partner)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _controller.deletePartner(context, partner.id)),
          ],
        ),
      ),
    );
  }


  void _showPrizeDialog(Prize? prize) {
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
                        items: partners.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
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

  void _showPartnerDialog(Partner? partner) {
    final isCreating = partner == null;
    final formKey = GlobalKey<FormState>();

    final nomeController = TextEditingController(text: partner?.nome ?? '');
    final descController = TextEditingController(text: partner?.descrizione ?? '');
    final linkController = TextEditingController(text: partner?.link ?? '');

    showDialog(
      context: context,
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
                  TextFormField(controller: descController, decoration: const InputDecoration(labelText: 'Descrizione')),
                  TextFormField(controller: linkController, decoration: const InputDecoration(labelText: 'Sito Web (URL)')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newPartner = Partner(
                    id: partner?.id ?? 'PARTNER-${DateTime.now().millisecondsSinceEpoch}',
                    nome: nomeController.text,
                    descrizione: descController.text,
                    link: linkController.text,
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

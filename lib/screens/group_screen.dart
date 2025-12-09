import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'location_picker_screen.dart';

import 'create_event_screen.dart';
import '../services/storage_service.dart';

class GroupModel {
  final String name;
  final String time;
  final String date;
  final String address;
  final String inviteLink;
  final bool isAdmin;
  List<String> members;

  GroupModel({
    required this.name,
    required this.time,
    required this.date,
    required this.address,
    required this.inviteLink,
    required this.isAdmin,
    required this.members,
  });
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<GroupModel> myGroups = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  Future<void> _pickLocationFromMap() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _addressController.text = "Posizione GPS: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
      });
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Nuovo Gruppo"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Creazione gruppo
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nome Gruppo"),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    // Creazione Data
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_selectedDate == null ? "Seleziona Data" : "Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context, initialDate: DateTime.now(),
                          firstDate: DateTime.now(), lastDate: DateTime(2030),
                        );
                        if (picked != null) setDialogState(() => _selectedDate = picked);
                      },
                    ),
                    // Creazione ora
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_selectedTime == null ? "Seleziona Ora" : "Ora: ${_selectedTime!.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (picked != null) setDialogState(() => _selectedTime = picked);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _selectedTime != null && _selectedDate != null) {
                      setState(() {
                        myGroups.add(GroupModel(
                          name: _nameController.text,
                          address: _addressController.text,
                          time: _selectedTime!.format(context),
                          date: DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          inviteLink: "https://cityclean.app/invite/${myGroups.length + 123}",
                          isAdmin: true,
                          members: ["Tu (Admin)", "Marco R.", "Giulia B.", "Luca S."],
                        ));
                      });
                      _nameController.clear();
                      _addressController.clear();
                      _selectedTime = null;
                      _selectedDate = null;
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  child: const Text("Crea", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGroupDetails(int index) {
    final group = myGroups[index];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDetailsState) {
            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(group.name, overflow: TextOverflow.ellipsis),
                  ),

                  // Se l'utente è Admin, vede il bottone
                  if (group.isAdmin) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final userId = await StorageService.getUserId();

                        if (userId != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateEventScreen(
                                userId: userId,
                                groupName: group.name,
                              ),
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore utente non loggato")));
                        }
                      },
                      child: const Text(
                        "+ Evento",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ]
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📍 ${group.address}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("📅 ${group.date} ore ${group.time}"),
                    const Divider(),
                    const Text("Partecipanti:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: group.members.length,
                      itemBuilder: (context, memberIndex) {
                        final memberName = group.members[memberIndex];
                        final isMe = memberIndex == 0;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(memberName[0])),
                          title: Text(memberName),
                          trailing: group.isAdmin && !isMe
                              ? IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setDetailsState(() {
                                group.members.removeAt(memberIndex);
                              });
                              setState(() {});
                            },
                          )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      myGroups.removeAt(index);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Esci dal gruppo", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Chiudi"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gruppi"),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "Crea", icon: Icon(Icons.add_circle_outline, color: Colors.white)),
              Tab(text: "I miei gruppi", icon: Icon(Icons.group, color: Colors.white)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB CREA
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volunteer_activism, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text("Organizza una pulizia di gruppo", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showCreateGroupDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Crea un gruppo"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            // TAB I MIEI GRUPPI
            myGroups.isEmpty
                ? const Center(child: Text("Non sei in nessun gruppo."))
                : ListView.builder(
              itemCount: myGroups.length,
              itemBuilder: (context, index) {
                final group = myGroups[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: () => _showGroupDetails(index),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.group, color: Colors.green),
                    ),
                    title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("📅 ${group.date} - ${group.members.length} partecipanti"),
                    trailing: IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: group.inviteLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Link invito copiato!")),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
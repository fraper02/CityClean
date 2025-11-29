import 'package:flutter/material.dart';
import '../models/guild.dart';
import '../data/guild_data.dart';
import 'create_guild_screen.dart'; // La creeremo dopo

class GuildsListScreen extends StatefulWidget {
  const GuildsListScreen({super.key});

  @override
  State<GuildsListScreen> createState() => _GuildsListScreenState();
}

class _GuildsListScreenState extends State<GuildsListScreen> {
  List<Guild> _allGuilds = [];
  List<Guild> _filteredGuilds = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allGuilds = MockGuildData.guilds;
    _filteredGuilds = _allGuilds;
  }

  void _runFilter(String keyword) {
    List<Guild> results = [];
    if (keyword.isEmpty) {
      results = _allGuilds;
    } else {
      results = _allGuilds
          .where((guild) =>
      guild.name.toLowerCase().contains(keyword.toLowerCase()) ||
          guild.id.contains(keyword)) // Cerca anche per ID se vuoi
          .toList();
    }
    setState(() {
      _filteredGuilds = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Gilde"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // BARRA DI RICERCA
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _runFilter,
                  decoration: InputDecoration(
                    hintText: "Cerca gilda per nome...",
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // LISTA GILDE
              Expanded(
                child: _filteredGuilds.isEmpty
                    ? const Center(child: Text("Nessuna gilda trovata"))
                    : ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80), // Added bottom padding to avoid button overlap
                  itemCount: _filteredGuilds.length,
                  itemBuilder: (context, index) {
                    final guild = _filteredGuilds[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text(
                            guild.name[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                        title: Text(
                          guild.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              guild.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.group, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${guild.membersCount} membri",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Richiesta inviata a ${guild.name}")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text("Unisciti"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // TASTO CREA GILDA CENTRATO
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateGuildScreen()),
                  );
                },
                backgroundColor: primaryGreen,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Crea Gilda", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:cityclean/components/network_image_with_fallback.dart';
import 'package:flutter/material.dart';
import '../controllers/badge_controller.dart';
import '../models/badge.dart' as app_badge;

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  late final BadgeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BadgeController();
    _controller.loadBadges();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('I Tuoi Badge'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<BadgeScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, child) {
          if (state == BadgeScreenState.loading || state == BadgeScreenState.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == BadgeScreenState.error) {
            return Center(child: Text(_controller.errorMessage.value));
          }
          return _buildUI();
        },
      ),
    );
  }

  Widget _buildUI() {
    return ValueListenableBuilder<List<app_badge.Badge>>(
      valueListenable: _controller.badges,
      builder: (context, badges, _) {
        if (badges.isEmpty) {
          return const Center(child: Text("Nessun badge disponibile."));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: badges.length,
          itemBuilder: (context, index) => _buildBadgeCard(badges[index]),
        );
      },
    );
  }

  Widget _buildBadgeCard(app_badge.Badge badge) {
    final bool isUnlocked = badge.isUnlocked;

    // Usiamo un Card come contenitore principale per sfruttare le sue proprietà di clipping.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isUnlocked ? 2 : 0.5,
      clipBehavior: Clip.antiAlias, // Questa è la chiave per risolvere il bug del ripple
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isUnlocked ? Colors.white : Colors.grey[300],
      child: InkWell(
        onTap: () => _controller.showBadgeDetails(context, badge),
        child: Opacity(
          opacity: isUnlocked ? 1.0 : 0.6, // Leggera opacità per i badge bloccati
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: NetworkImageWithFallback(
                    imageUrl: badge.urlIcona,
                    fallbackWidget: Icon(Icons.shield, color: Colors.grey[500], size: 40),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.nome,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.descrizione,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.lock, color: Colors.black54, size: 28),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

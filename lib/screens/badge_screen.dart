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
      appBar: AppBar(
        title: const Text('I Tuoi Badge'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<BadgeScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, child) {
          switch (state) {
            case BadgeScreenState.loading:
              return const Center(child: CircularProgressIndicator());
            case BadgeScreenState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Errore nel caricamento dei badge: ${_controller.errorMessage.value}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            case BadgeScreenState.success:
              return _buildBadgeGrid();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildBadgeGrid() {
    return ValueListenableBuilder<List<app_badge.Badge>>(
      valueListenable: _controller.badges,
      builder: (context, badges, _) {
        if (badges.isEmpty) {
          return const Center(child: Text("Non ci sono badge da mostrare."));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(badges[index]);
          },
        );
      },
    );
  }

  Widget _buildBadgeCard(app_badge.Badge badge) {
    final cardColor = badge.isUnlocked ? Colors.white : Colors.grey[200];

    final Widget iconWidget = NetworkImageWithFallback(
      imageUrl: badge.urlIcona,
      fallbackWidget: Icon(Icons.shield_outlined, color: Colors.grey[600], size: 40),
    );

    final Widget cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: Center(child: iconWidget)),
        const SizedBox(height: 8),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              badge.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ],
    );

    return Card(
      elevation: 2.0,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _controller.showBadgeDetails(context, badge),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Il contenuto (icona e testo).
            cardContent,

            // Layer 2 e 3: Velo scuro e lucchetto, solo per i badge bloccati.
            if (!badge.isUnlocked) ...[
              // Questo Container crea un velo scuro uniforme.
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              // Il lucchetto è sopra al velo scuro.
              const Icon(Icons.lock, color: Colors.white, size: 32),
            ],
          ],
        ),
      ),
    );
  }
}

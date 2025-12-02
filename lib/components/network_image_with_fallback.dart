import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final Widget fallbackWidget;
  final BoxFit fit;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    required this.fallbackWidget,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    // Se l'URL è palesemente non valido, mostra subito il fallback.
    if (imageUrl.isEmpty || !Uri.tryParse(imageUrl)!.isAbsolute) {
      return fallbackWidget;
    }

    return Image.network(
      imageUrl,
      fit: fit,
      // In caso di errore durante il download (es. 404), mostra il widget di fallback.
      errorBuilder: (context, error, stackTrace) {
        return fallbackWidget;
      },
      // Mostra un indicatore di caricamento pulito mentre l'immagine scarica.
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child; // Immagine caricata con successo.
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}

import 'package:cityclean/screens/contribution_screen.dart';
import 'package:cityclean/services/ecopoint_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // Evita scansioni multiple immediate
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    // Se stiamo già elaborando, ignoriamo altre scansioni
    if (_isProcessing) return;

    final String? code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isProcessing = true; // Blocca UI
    });

    // 1. Mostra indicatore di caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Verifica Ecopoint..."),
              ],
            ),
          ),
        ),
      ),
    );

    // 2. Chiama il service per verificare se esiste nel DB
    final bool exists = await EcopointService.verifyEcopointExists(code);

    if (!mounted) return;

    // Chiudi il dialog di caricamento
    Navigator.of(context).pop();

    if (exists) {
      // 3A. ESISTE: Vai alla schermata di inserimento
      // Mettiamo in pausa la camera per risparmiare risorse
      _scannerController.stop();

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ContributionScreen(ecopointId: code),
        ),
      );
    } else {
      // 3B. NON ESISTE: Mostra errore e riprendi
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Errore"),
          content: Text("L'Ecopoint scansionato ($code) non è stato trovato nel sistema."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Riprova"),
            ),
          ],
        ),
      );

      // Resetta lo stato per permettere una nuova scansione
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scannerizza Ecopoint'),
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        actions: [
          // FIX: Utilizzo di ValueListenableBuilder ascoltando direttamente il controller
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _scannerController,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: () => _scannerController.toggleTorch(),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          const QRScannerOverlay(),

          // Istruzioni in basso
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Inquadra il QR code sul cassonetto",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getOuterPath(Rect rect) {
      final cutOutSize = rect.width * 0.70; // Leggermente più grande
      final cutOutRect = Rect.fromCenter(
        center: rect.center,
        width: cutOutSize,
        height: cutOutSize,
      );

      final outerPath = Path()..addRect(rect);
      final cutOutPath = Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, const Radius.circular(20)));

      return Path.combine(PathOperation.difference, outerPath, cutOutPath);
    }
    return _getOuterPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutSize = rect.width * 0.70;
    final borderLength = 40.0;
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.greenAccent // Colore verde per l'overlay
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(getOuterPath(rect), backgroundPaint);

    // Disegna gli angoli
    final Path cornersPath = Path();
    // Top Left
    cornersPath.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    cornersPath.lineTo(cutOutRect.left, cutOutRect.top);
    cornersPath.lineTo(cutOutRect.left + borderLength, cutOutRect.top);
    // Top Right
    cornersPath.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    cornersPath.lineTo(cutOutRect.right, cutOutRect.top);
    cornersPath.lineTo(cutOutRect.right, cutOutRect.top + borderLength);
    // Bottom Right
    cornersPath.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    cornersPath.lineTo(cutOutRect.right, cutOutRect.bottom);
    cornersPath.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);
    // Bottom Left
    cornersPath.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    cornersPath.lineTo(cutOutRect.left, cutOutRect.bottom);
    cornersPath.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(cornersPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
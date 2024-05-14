import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan")),
      body: ScanView(
        resultHandler: (capture, resumeScanner) {
          showDialog(
            context: context,
            builder: (context) => PopScope(
              onPopInvoked: (didPop) {
                resumeScanner();
              },
              child: QRValueDialog(capture: capture),
            ),
          );
        },
      ),
    );
  }
}

typedef ScanViewResultHandler = void Function(
    BarcodeCapture capture, void Function() resumeScanner);

class ScanView extends StatefulWidget {
  const ScanView({super.key, required this.resultHandler});

  /// handle the QR code result.
  /// 
  /// The scanner will stop each time the result is complete. 
  /// Process the result here and then resume the scanner by calling `resumeScanner`.
  final ScanViewResultHandler resultHandler;

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with WidgetsBindingObserver {
  final scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  StreamSubscription? subscription;

  bool hasResult = false;

  void resumeScanner() {
    hasResult = false;
    scannerController.start();
  }

  void handleQRcode(BarcodeCapture capture) {
    if (hasResult) return;
    hasResult = true;

    scannerController.stop().then((_) {
      widget.resultHandler(capture, resumeScanner);
    });
  }

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    subscription = scannerController.barcodes.listen(handleQRcode);

    // Finally, start the scanner itself.
    scannerController.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!scannerController.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        subscription = scannerController.barcodes.listen(handleQRcode);
        scannerController.start();
        break;
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        subscription?.cancel();
        subscription = null;
        scannerController.stop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(controller: scannerController);
  }

  @override
  void dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    subscription?.cancel();
    subscription = null;
    super.dispose();
    // Finally, dispose of the controller.
    scannerController.dispose();
  }
}

class QRValueDialog extends StatelessWidget {
  const QRValueDialog({
    super.key,
    required this.capture,
  });

  final BarcodeCapture capture;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("QR code"),
      children: List.generate(
        capture.barcodes.length,
        (i) => ListTile(
          leading: Text("$i"),
          title: Text("${capture.barcodes[i].rawValue}"),
        ),
      ),
    );
  }
}

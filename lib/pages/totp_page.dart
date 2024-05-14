import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_test/pages/scan_page.dart';
import 'package:totp/totp.dart';

class TotpInfo {
  String label;
  String issuer;

  TotpInfo(this.label, this.issuer);
}

class TotpPage extends StatefulWidget {
  const TotpPage({super.key});

  @override
  State<TotpPage> createState() => _TotpPageState();
}

class _TotpPageState extends State<TotpPage> {
  Map<TotpInfo, Totp> totpMap = {};

  void addTotp() async {
    final qrCodeValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Scan")),
          body: ScanView(
            resultHandler: (capture, resumeScanner) {
              Navigator.pop(
                context,
                capture.barcodes.first.rawValue,
              );
            },
          ),
        ),
      ),
    );

    final uri = Uri.tryParse(qrCodeValue ?? "");
    if (uri == null) return;

    final query = uri.queryParameters;
    final secret = query["secret"];
    final digit = query["digits"];
    final period = query["period"];
    final issuer = query["issuer"];
    if (secret == null) return;
    final totpInfo = TotpInfo(
      uri.pathSegments.last,
      issuer ?? "",
    );
    final totp = Totp.fromBase32(
      secret: secret.toUpperCase(),
      algorithm: Algorithm.sha1,
      digits: digit == null ? 6 : int.tryParse(digit) ?? 6,
      period: period == null ? 30 : int.tryParse(period) ?? 30,
    );

    setState(() {
      totpMap[totpInfo] = totp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Totp")),
      body: ListView.builder(
        itemCount: totpMap.length,
        itemBuilder: (context, i) =>
            TotpTile(id: i, totpItem: totpMap.entries.elementAt(i)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTotp,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TotpTile extends StatefulWidget {
  const TotpTile({super.key, required this.totpItem, required this.id});

  final MapEntry<TotpInfo, Totp> totpItem;
  final int id;

  @override
  State<TotpTile> createState() => _TotpTileState();
}

class _TotpTileState extends State<TotpTile> {
  late String password;
  late Timer updater;
  int validity = 0;

  int getValidity() {
    final utc = DateTime.now().toUtc();
    return widget.totpItem.value.period -
        (utc.millisecondsSinceEpoch ~/ 1000 % 30);
  }

  @override
  void initState() {
    super.initState();
    password = widget.totpItem.value.now();
    validity = getValidity();

    updater = Timer.periodic(const Duration(seconds: 1), (timer) {
      validity = getValidity();

      setState(() {
        validity = getValidity();
        if (validity == widget.totpItem.value.period) {
          password = widget.totpItem.value.now();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("${widget.id}"),
      title: Text(
        "${widget.totpItem.key.issuer} / ${widget.totpItem.key.label}",
        maxLines: 1,
      ),
      subtitle: Text(password),
      trailing: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: validity / widget.totpItem.value.period,
          ),
          Text("$validity")
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    updater.cancel();
  }
}

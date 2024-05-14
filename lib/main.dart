import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_test/pages/scan_page.dart';
import 'package:mobile_test/pages/totp_page.dart';

void main() {
  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: supportedLocales,
      routes: {
        "/": (context) => const AppHome(),
        "SCAN_PAGE": (context) => const ScanPage(),
        "TOTP_PAGE":(context) => const TotpPage(),
      },
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "SCAN_PAGE");
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan"),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "TOTP_PAGE");
              },
              icon: const Icon(Icons.lock),
              label: const Text("Totp"),
            ),
          ],
        ),
      ),
    );
  }
}

// Full Chinese support for CN, TW, and HK
const supportedLocales = <Locale>[
  // generic Chinese 'zh'
  Locale.fromSubtags(languageCode: 'zh'),
  // generic simplified Chinese 'zh_Hans'
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  // generic traditional Chinese 'zh_Hant'
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  // 'zh_Hans_CN'
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
  // 'zh_Hant_TW'
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
  // 'zh_Hant_HK'
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
];

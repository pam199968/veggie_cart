import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = '';
  String buildNumber = '';
  String appName = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      version = info.version;
      buildNumber = info.buildNumber;
      appName = info.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Version : $version'),
            Text('Build : $buildNumber'),
            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 20),
            const Text(
              "Cette application a été développée pour faciliter la gestion "
              "des commandes, du catalogue et des offres hebdomadaires au Bio jardin.",
              style: TextStyle(fontSize: 16),
            ),

            const Spacer(),

            Center(
              child: Text(
                "© ${2025} - Patrick M.",
                style: const TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

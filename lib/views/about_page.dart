// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:au_bio_jardin_app/extensions/context_extension.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = '';
  String buildNumber = '';
  String appName = 'Au Bio Jardin.';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.about),
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
            Text(
              context.l10n.aboutDescription,
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            Center(
              child: Text(
                context.l10n.copyright(DateTime.now().year),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
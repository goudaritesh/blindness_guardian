import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/alert_provider.dart';

class CameraViewPage extends StatelessWidget {
  const CameraViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProv = context.watch<AlertProvider>();
    // Try getting image from active alert first, then from recent alerts list
    String? imageUrl = alertProv.activeAlert?.imageUrl;
    
    if (imageUrl == null && alertProv.alerts.isNotEmpty) {
      imageUrl = alertProv.alerts.firstWhere((a) => a.imageUrl != null, orElse: () => alertProv.alerts.first).imageUrl;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera View')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            else
              const Column(
                children: [
                  Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No latest emergency image available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  final user = context.read<AuthProvider>().user;
                  if (user != null) {
                    alertProv.fetchHistory(user.deviceId);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Feed'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

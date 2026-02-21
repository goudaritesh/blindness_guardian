import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';

class ActiveAlertDialog extends StatelessWidget {
  const ActiveAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProv = context.watch<AlertProvider>();
    final authProv = context.watch<AuthProvider>();
    final locationProv = context.watch<LocationProvider>();
    final alert = alertProv.activeAlert;
    final theme = Theme.of(context);
    final isFall = alert?.type.toUpperCase() == 'FALL';
    final alertColor = isFall ? Colors.orangeAccent : Colors.redAccent;

    if (alert == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Pulse
          Container(
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alertColor.withOpacity(0.1),
            ),
          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 2.seconds).fadeOut(),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A0505),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: alertColor.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: alertColor.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: alertColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFall ? Icons.directions_run_rounded : Icons.warning_amber_rounded,
                        color: alertColor,
                        size: 48,
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
                    const SizedBox(height: 16),
                    Text(
                      isFall ? 'FALL DETECTED' : 'CRITICAL SOS',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: alertColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${authProv.user?.name ?? "User"} is in danger!',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    if (alert.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: alert.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 160,
                            color: Colors.white10,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                        ),
                      ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.near_me_rounded),
                      label: const Text('TRACK ON MAP', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        // Use live location if available, otherwise fallback to alert location
                        final lat = locationProv.currentLocation?.latitude ?? alert.latitude;
                        final lng = locationProv.currentLocation?.longitude ?? alert.longitude;
                        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: alertColor,
                              side: BorderSide(color: alertColor),
                              minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.phone_rounded),
                            label: const Text('CALL'),
                            onPressed: () async {
                              final phone = authProv.user?.phone;
                              if (phone != null) {
                                final url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) await launchUrl(url);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white54,
                              minimumSize: const Size(0, 56),
                            ),
                            child: const Text('DISMISS'),
                            onPressed: () async {
                              await alertProv.markAsSafe(alert.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}

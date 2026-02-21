import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('App Manual', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              title: "System Overview",
              content: "The Blindness Guardian system consists of a Smart Blind Stick (IoT Device) and this Guardian Mobile App. It ensures the safety of visually impaired users through real-time tracking and emergency alerts.",
              icon: Icons.info_outline_rounded,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              title: "1. Device Connection",
              content: "Ensure the Smart Stick is powered on and connected to WiFi. The 'ONLINE' status on your dashboard indicates the stick is transmitting data.",
              icon: Icons.wifi_rounded,
            ).animate().fadeIn(delay: 200.ms).slideY(),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              title: "2. Emergency Alerts (SOS)",
              content: "When the user presses the SOS button on the stick for 3 seconds, your phone will trigger a loud alarm and show a full-screen alert. You can click 'Mark as Safe' once the situation is handled.",
              icon: Icons.error_outline_rounded,
            ).animate().fadeIn(delay: 400.ms).slideY(),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              title: "3. Live Location",
              content: "Click 'Live Map' to see the user's current coordinates. Use the 'Open in Maps' button to get turn-by-turn navigation via Google Maps.",
              icon: Icons.map_rounded,
            ).animate().fadeIn(delay: 600.ms).slideY(),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              title: "4. Geo-fencing",
              content: "You can set a safe radius in the System Config. If the user moves outside this circle, you will receive an automated boundary alert.",
              icon: Icons.grain_rounded,
            ).animate().fadeIn(delay: 800.ms).slideY(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white70, height: 1.5)),
        ],
      ),
    );
  }
}

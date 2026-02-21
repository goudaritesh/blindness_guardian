import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/stats_provider.dart';
import '../../../domain/models/device_status.dart';

import 'live_location_page.dart';
import 'camera_view_page.dart';
import 'emergency_history_page.dart';
import 'settings_page.dart';
import '../../widgets/active_alert_dialog.dart';
import '../auth/login_page.dart';
import 'manual_page.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<DeviceProvider>().listenToDevice(user.deviceId);
        context.read<LocationProvider>().listenToLocation(user.deviceId);
        context.read<AlertProvider>().listenToAlerts(user.deviceId);
        context.read<StatsProvider>().fetchTodayStats(user.deviceId);
      }
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakStatus(DeviceStatus? device, String name) async {
    bool isOnline = device?.isOnline ?? false;
    int battery = device?.batteryLevel ?? 0;
    String statusText = "User $name is ${isOnline ? 'connected' : 'currently offline'}. Battery is at $battery percent.";
    await flutterTts.speak(statusText);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final device = context.watch<DeviceProvider>().status;
    final alertProv = context.watch<AlertProvider>();
    final statsProv = context.watch<StatsProvider>();
    final theme = Theme.of(context);
    
    if (!auth.isAuthenticated) return const LoginPage();

    final String displayName = user?.name ?? 'Guardian';
    bool hasEmergency = alertProv.alerts.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              hasEmergency ? const Color(0xFF2A0505) : theme.scaffoldBackgroundColor,
              hasEmergency ? const Color(0xFF1A0505) : theme.colorScheme.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 120,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  title: Text(
                    'Blindness Guardian',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: hasEmergency ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.menu_book_rounded),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualPage())),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSosIndicator(alertProv.alerts.isNotEmpty),
                    if (hasEmergency) const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $displayName',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn().slideX(),
                            const SizedBox(height: 8),
                            Text(
                              'Monitoring system active',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                        _buildVoiceButton(device, displayName),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(child: _buildStatusCard(device, theme)),
                        const SizedBox(width: 16),
                        _buildSafetyScore(device, statsProv, theme),
                      ],
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 32),
                    _buildAnalyticsPanel(statsProv, theme),
                    
                    const SizedBox(height: 32),
                    Text(
                      'QUICK ACTIONS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                    _buildActionGrid(context, theme, alertProv),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton(DeviceStatus? device, String name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        icon: const Icon(Icons.record_voice_over_rounded, color: Colors.cyanAccent),
        onPressed: () => _speakStatus(device, name),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds, color: Colors.cyanAccent.withOpacity(0.2));
  }

  Widget _buildSafetyScore(DeviceStatus? device, StatsProvider statsProv, ThemeData theme) {
    int battery = device?.batteryLevel ?? 0;
    bool isOnline = device?.isOnline ?? false;
    
    // Real calculation: 40% battery, 40% connection, 20% recent safe activity
    double score = (battery * 0.4) + (isOnline ? 40 : 10);
    if (statsProv.todayStats != null) {
      score += 20; // Bonus for active monitoring today
    }
    if (score > 100) score = 100;

    return Container(
      height: 180,
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 6.0,
            percent: score / 100,
            center: Text(
              "${score.toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            progressColor: score > 70 ? Colors.greenAccent : Colors.orangeAccent,
            backgroundColor: Colors.white10,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'SAFETY SCORE',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPanel(StatsProvider statsProv, ThemeData theme) {
    final stats = statsProv.todayStats;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAILY ANALYTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white38)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('${stats?.distanceKm ?? 0.0} km', 'Walked', Icons.directions_walk_rounded, Colors.blueAccent),
              _buildStatItem('${stats?.obstaclesAvoided ?? 0}', 'Cleared', Icons.security_rounded, Colors.greenAccent),
              _buildStatItem('${stats?.safeHours ?? 0.0}h', 'Safe', Icons.timer_outlined, Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      ],
    );
  }

  Widget _buildStatusCard(DeviceStatus? device, ThemeData theme) {
    bool isOnline = device?.isOnline ?? false;
    bool isSafe = device?.isSafe ?? true;
    int battery = device?.batteryLevel ?? 0;
    
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1.seconds).fadeOut(),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'STICK CONNECTED' : 'DISCONNECTED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text('$battery%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const Text('Battery Life', style: TextStyle(fontSize: 12, color: Colors.white38)),
          const Spacer(),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 6.0,
            percent: battery / 100,
            barRadius: const Radius.circular(3),
            progressColor: battery > 20 ? Colors.cyanAccent : Colors.redAccent,
            backgroundColor: Colors.white10,
            animation: true,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SIGNAL STRENGTH', style: TextStyle(fontSize: 8, color: Colors.white30, letterSpacing: 1)),
              Row(
                children: [
                   Icon(Icons.signal_cellular_alt_rounded, size: 12, color: isOnline ? Colors.greenAccent : Colors.white10),
                   const SizedBox(width: 4),
                   Icon(Icons.wifi_rounded, size: 12, color: isOnline ? Colors.blueAccent : Colors.white10),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, ThemeData theme, AlertProvider alertProv) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: [
        _buildActionCard(
          context,
          icon: Icons.map_rounded,
          title: 'Live Location',
          color: Colors.blueAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveLocationPage())),
        ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.1),
        _buildActionCard(
          context,
          icon: Icons.visibility_rounded,
          title: 'Camera Preview',
          color: Colors.purpleAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraViewPage())),
          isCamera: true,
          lastAlert: alertProv.alerts.isNotEmpty ? alertProv.alerts.first : null,
        ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1),
        _buildActionCard(
          context,
          icon: Icons.history_rounded,
          title: 'Alert History',
          color: Colors.orangeAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyHistoryPage())),
          badge: alertProv.alerts.length,
        ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.1),
        _buildActionCard(
          context,
          icon: Icons.settings_rounded,
          title: 'System Config',
          color: Colors.tealAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
        ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required Color color, 
    required VoidCallback onTap,
    int? badge,
    bool isCamera = false,
    var lastAlert,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          image: isCamera && lastAlert?.imageUrl != null ? DecorationImage(
            image: NetworkImage(lastAlert!.imageUrl!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
          ) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (badge != null && badge > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSosIndicator(bool hasActiveEmergency) {
    if (!hasActiveEmergency) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 32)
            .animate(onPlay: (c) => c.repeat()).shake(duration: 1.seconds),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CRITICAL EMERGENCY', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                Text('User needs immediate assistance!', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2.seconds, color: Colors.redAccent.withOpacity(0.3));
  }
}

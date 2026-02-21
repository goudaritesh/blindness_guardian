import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/location_provider.dart';
import '../../../domain/models/location_log.dart';

class LiveLocationPage extends StatefulWidget {
  const LiveLocationPage({super.key});

  @override
  State<LiveLocationPage> createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  final MapController _mapController = MapController();
  bool _autoCenter = true;
  LatLng? _lastLoggedPos;
  LatLng? _safeCenter;

  @override
  Widget build(BuildContext context) {
    final locationProv = context.watch<LocationProvider>();
    final LocationLog? currentLog = locationProv.currentLocation;
    final List<LocationLog> history = locationProv.history;
    final theme = Theme.of(context);

    if (currentLog != null) {
      final currentPos = LatLng(currentLog.latitude, currentLog.longitude);
      _safeCenter ??= currentPos; 

      if (_autoCenter && _lastLoggedPos != currentPos) {
        _lastLoggedPos = currentPos;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(currentPos, _mapController.camera.zoom);
          }
        });
      }
    }

    final List<LatLng> pathPoints = history.map((e) => LatLng(e.latitude, e.longitude)).toList();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('LIVE TRACKER', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(_autoCenter ? Icons.gps_fixed : Icons.gps_not_fixed, 
                color: _autoCenter ? Colors.blueAccent : Colors.white),
              onPressed: () => setState(() => _autoCenter = !_autoCenter),
            ),
          ),
        ],
      ),
      body: currentLog == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(currentLog.latitude, currentLog.longitude),
                    initialZoom: 15.0,
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture && _autoCenter) {
                        setState(() => _autoCenter = false);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.blindnessguardian.blindness_guardian',
                      tileBuilder: (context, tileWidget, tile) {
                         return ColorFiltered(
                           colorFilter: const ColorFilter.matrix([
                             -1, 0, 0, 0, 255,
                             0, -1, 0, 0, 255,
                             0, 0, -1, 0, 255,
                             0, 0, 0, 1, 0,
                           ]),
                           child: tileWidget,
                         );
                      },
                    ),
                    if (_safeCenter != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _safeCenter!,
                            radius: locationProv.geoFenceRadius,
                            useRadiusInMeter: true,
                            color: Colors.blueAccent.withOpacity(0.05),
                            borderColor: Colors.blueAccent.withOpacity(0.2),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: pathPoints,
                          color: Colors.blueAccent.withOpacity(0.4),
                          strokeWidth: 3.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(currentLog.latitude, currentLog.longitude),
                          width: 120,
                          height: 120,
                          child: _buildMarker(currentLog),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: _buildLocationInfoCard(currentLog, theme),
                ),
              ],
            ),
    );
  }

  Widget _buildMarker(LocationLog log) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withOpacity(0.3),
          ),
        ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(2, 2), duration: 2.seconds).fadeOut(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.blind_rounded, color: Colors.white, size: 16),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfoCard(LocationLog log, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, spreadRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
              ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5)).fadeOut(),
              const SizedBox(width: 10),
              Text(
                'LIVE GPS STREAM',
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white54),
              ),
              const Spacer(),
              Text(
                'SYNC: ${DateFormat('HH:mm:ss').format(log.timestamp)}',
                style: GoogleFonts.outfit(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetric('LAT', log.latitude.toStringAsFixed(6)),
              const SizedBox(width: 40),
              _buildMetric('LNG', log.longitude.toStringAsFixed(6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

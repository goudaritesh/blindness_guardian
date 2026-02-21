import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final loc = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Enable alerts for SOS, Fall, and Battery'),
            value: true,
            onChanged: (val) {},
            activeColor: Colors.tealAccent,
          ),
          const Divider(),
          ListTile(
            title: const Text('Edit Guardian Profile'),
            subtitle: const Text('Update contact details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          const Divider(),
          ListTile(
            title: const Text('Geo-fence Radius'),
            subtitle: Text('Current: \${loc.geoFenceRadius}m'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: loc.geoFenceRadius,
                min: 100,
                max: 2000,
                divisions: 19,
                activeColor: Colors.tealAccent,
                onChanged: (val) {
                  context.read<LocationProvider>().setGeoFenceRadius(auth.user?.uid ?? '', val);
                },
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('App Version', style: TextStyle(color: Colors.grey)),
            subtitle: const Text('1.0.0 (MVP)', style: TextStyle(color: Colors.grey)),
            leading: const Icon(Icons.info, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                auth.logout();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}

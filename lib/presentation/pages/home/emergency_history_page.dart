import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/alert_provider.dart';
import '../../../domain/models/alert.dart';

class EmergencyHistoryPage extends StatelessWidget {
  const EmergencyHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency History')),
      body: FutureBuilder<List<Alert>>(
        future: context.read<AlertProvider>().fetchHistory(
          context.read<AuthProvider>().user?.deviceId ?? ''
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return const Center(child: Text('No history available.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
               final alert = alerts[index];
               final color = alert.type == 'SOS' ? Colors.redAccent 
                          : alert.type == 'FALL' ? Colors.orangeAccent 
                          : Colors.blueAccent;

               return Card(
                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: ListTile(
                   leading: CircleAvatar(
                     backgroundColor: color.withOpacity(0.2),
                     child: Icon(Icons.warning, color: color),
                   ),
                   title: Text('${alert.type} Alert'),
                   subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(alert.timestamp)),
                   trailing: alert.resolved 
                     ? const Icon(Icons.check_circle, color: Colors.green)
                     : const Icon(Icons.pending, color: Colors.red),
                   onTap: () {
                     // Detail dialog could be shown here
                   },
                 ),
               );
            },
          );
        },
      ),
    );
  }
}

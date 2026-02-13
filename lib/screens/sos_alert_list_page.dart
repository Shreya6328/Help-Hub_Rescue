import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'action_page.dart';

class SOSAlertListPage extends StatelessWidget {
  final String alertType;
  const SOSAlertListPage({super.key, required this.alertType});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: Text("$alertType Alerts"), backgroundColor: Colors.red),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('sos_alerts').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!
              .where((a) => a['type'] == alertType && a['status'] == 'assigned')
              .toList();

          if (alerts.isEmpty) {
            return const Center(child: Text("No active alerts"));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (_, i) {
              final a = alerts[i];
              return ListTile(
                title: Text(a['assigned_team'] ?? 'Assigned'),
                subtitle: Text("${a['latitude']} , ${a['longitude']}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActionPage(
                        alertId: a['id'],
                        userLat: a['latitude'].toDouble(),
                        userLng: a['longitude'].toDouble(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

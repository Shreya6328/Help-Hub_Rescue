import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import 'live_tracking_map.dart';
import 'resolve_page.dart';

class ActionPage extends StatelessWidget {
  final int alertId;
  final double userLat;
  final double userLng;

  const ActionPage({
    super.key,
    required this.alertId,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Actions"), backgroundColor: Colors.red),
      body: Column(
        children: [
          ActionCard(
            title: "Track User Location",
            icon: Icons.location_on,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveTrackingMap(
                    userLat: userLat,
                    userLng: userLng,
                  ),
                ),
              );
            },
          ),
          ActionCard(
            title: "Mark as Resolved",
            icon: Icons.check_circle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResolvePage(alertId: alertId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

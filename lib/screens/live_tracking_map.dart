import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LiveTrackingMap extends StatefulWidget {
  final double userLat;
  final double userLng;

  const LiveTrackingMap({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  LatLng? rescuerLocation;
  List<LatLng> routePoints = [];
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLiveTracking() async {
    await Geolocator.requestPermission();

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((pos) async {
          rescuerLocation = LatLng(pos.latitude, pos.longitude);
          await _loadRoute();
          setState(() {});
        });
  }

  Future<void> _loadRoute() async {
    if (rescuerLocation == null) return;

    final userLocation = LatLng(widget.userLat, widget.userLng);

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${rescuerLocation!.longitude},${rescuerLocation!.latitude};'
        '${userLocation.longitude},${userLocation.latitude}'
        '?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body);
    final coords = data['routes'][0]['geometry']['coordinates'];

    routePoints = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (rescuerLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userLocation = LatLng(widget.userLat, widget.userLng);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        backgroundColor: Colors.red,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: rescuerLocation!, initialZoom: 14),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.rescueteam',
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 5,
                  color: Colors.blue,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: rescuerLocation!,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              Marker(
                point: userLocation,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

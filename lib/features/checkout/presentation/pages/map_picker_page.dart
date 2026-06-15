import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  LatLng _selectedPoint = const LatLng(-6.2088, 106.8456); // Default: Jakarta
  bool _isLoadingLocation = false;
  String _statusText = 'Tap on the map to select your delivery location';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _statusText = 'Getting your location...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        setState(() {
          _statusText = 'Location service disabled. Tap map to select manually.';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          setState(() {
            _statusText = 'Location permission denied. Tap map to select manually.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _statusText = 'Location permission permanently denied. Tap map to select manually.';
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;

      final myLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPoint = myLocation;
        _statusText = 'Your current location selected';
        _isLoadingLocation = false;
      });
      _mapController.move(myLocation, 15);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = 'Could not get location. Tap map to select manually.';
        _isLoadingLocation = false;
      });
    }
  }

  String _formatCoords(LatLng point) {
    return '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('PICK DELIVERY LOCATION', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.outline.withOpacity(0.2), width: 1.5)),
            ),
            child: Row(
              children: [
                _isLoadingLocation
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
                    : Icon(Icons.location_on, color: cs.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusText,
                    style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedPoint = point;
                    _statusText = 'Location pinned: ${_formatCoords(point)}';
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bustedworld.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
                      width: 48,
                      height: 48,
                      child: Icon(Icons.location_pin, color: cs.primary, size: 48),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outline, width: 2)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selected coordinates
                  Row(
                    children: [
                      Icon(Icons.pin_drop, color: cs.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatCoords(_selectedPoint),
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      // Re-center to current location button
                      IconButton(
                        icon: Icon(Icons.my_location, color: cs.primary),
                        tooltip: 'Use my location',
                        onPressed: _getCurrentLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedPoint);
                    },
                    child: const Text('CONFIRM LOCATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

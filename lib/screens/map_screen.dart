import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  final Location _locationService = Location();
  final Set<Polygon> _polygons = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _locationService.getLocation();
    _locationSubscription = _locationService.onLocationChanged.listen((
      LocationData result,
    ) {
      setState(() {
        _currentLocation = result;
        _updateCameraPosition();
        _updateRectangle();
      });
    });

    if (_currentLocation != null) {
      setState(() {
        _updateCameraPosition();
        _updateRectangle();
      });
    }
  }

  void _updateCameraPosition() async {
    if (_currentLocation != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            zoom: 14.4746,
          ),
        ),
      );
    }
  }

  void _updateRectangle() {
    if (_currentLocation == null) return;

    final center = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );
    const double distance = 1.0; // 1km from center, so 2km total side length
    const double earthRadius = 6371.0; // in kilometers

    // Convert distance to radians
    final latRad = _toRadians(center.latitude);
    final lonRad = _toRadians(center.longitude);
    final distRad = distance / earthRadius;

    // Calculate offsets in radians
    final latOffset = distRad;
    final lonOffset = asin(sin(distRad) / cos(latRad));

    // Calculate corner points
    final north = _toDegrees(latRad + latOffset);
    final south = _toDegrees(latRad - latOffset);
    final east = _toDegrees(lonRad + lonOffset);
    final west = _toDegrees(lonRad - lonOffset);

    final points = [
      LatLng(north, west),
      LatLng(north, east),
      LatLng(south, east),
      LatLng(south, west),
    ];

    setState(() {
      _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('user_area'),
          points: points,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.1),
        ),
      );
    });
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Map')),
      body:
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                polygons: _polygons,
              ),
    );
  }
}

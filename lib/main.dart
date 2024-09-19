import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qibla Direction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QiblaDirectionPage(),
    );
  }
}

class QiblaDirectionPage extends StatefulWidget {
  @override
  _QiblaDirectionPageState createState() => _QiblaDirectionPageState();
}

class _QiblaDirectionPageState extends State<QiblaDirectionPage> {
  double _qiblaDirection = 0.0; // Arah kiblat
  double _currentDirection = 0.0; // Arah magnetometer
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    magnetometerEvents.listen(_onMagnetometerEvent);
  }

  // Mendapatkan lokasi pengguna
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _calculateQiblaDirection();
    });
  }

  // Menghitung arah kiblat berdasarkan lokasi pengguna
  void _calculateQiblaDirection() {
    const double latKabah = 21.4225; // Latitude Ka'bah
    const double lngKabah = 39.8262; // Longitude Ka'bah

    if (_currentPosition != null) {
      double userLat = _currentPosition!.latitude;
      double userLng = _currentPosition!.longitude;

      // Rumus untuk menghitung arah kiblat menggunakan koordinat
      double qiblaDirection = atan2(
        sin(_toRadians(lngKabah - userLng)),
        cos(_toRadians(userLat)) * tan(_toRadians(latKabah)) -
            sin(_toRadians(userLat)) * cos(_toRadians(lngKabah - userLng)),
      );

      setState(() {
        _qiblaDirection = _toDegrees(qiblaDirection);
        if (_qiblaDirection < 0) {
          _qiblaDirection += 360;
        }
      });
    }
  }

  // Konversi derajat ke radian
  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Konversi radian ke derajat
  double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  // Mendapatkan data dari magnetometer untuk arah medan magnet
  void _onMagnetometerEvent(MagnetometerEvent event) {
    double x = event.x;
    double y = event.y;
    double radians = atan2(y, x);
    double degrees = _toDegrees(radians);
    setState(() {
      _currentDirection = degrees;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arah Kiblat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPosition != null) ...[
              Text(
                'Lokasi Anda: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
            ],
            Text(
              'Arah Kiblat: ${_qiblaDirection.toStringAsFixed(2)}°',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Arah Medan Magnet: ${_currentDirection.toStringAsFixed(2)}°',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            Transform.rotate(
              angle: (_currentDirection - _qiblaDirection) * (pi / 180),
              child: Icon(
                Icons.arrow_upward,
                size: 100,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Putar perangkat ke arah kiblat',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

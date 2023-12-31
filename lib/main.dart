import 'dart:async';

import 'package:fl_location/fl_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(ExampleApp());

enum ButtonState { LOADING, DONE, DISABLED }

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  StreamSubscription<Location>? _locationSubscription;

  String _result = '';
  ButtonState _getLocationButtonState = ButtonState.DONE;

  Future<bool> _checkAndRequestPermission({bool? background}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
      // Location services are disabled.
      return false;
    }

    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      return false;
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) return false;
    }
    if (background == true &&
        locationPermission == LocationPermission.whileInUse) return false;
    return true;
  }

  void _refreshPage() {
    setState(() {});
  }

  Future<void> _listenLocationStream() async {
    if (await _checkAndRequestPermission()) {
      _locationSubscription = FlLocation.getLocationStream().listen((event) {
        _result = event.toJson().toString();
        print("Location stream event : $_result");
        _refreshPage();
      });

      _getLocationButtonState = ButtonState.DISABLED;
      _refreshPage();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: _listenLocationStream,
            child: const Text(
              'Listen LocationStream',
            ),
          ),
        ),
      ),
    );
  }
}

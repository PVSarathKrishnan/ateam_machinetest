import 'dart:convert';
import 'package:ateam_machinetest/model/search.dart';
import 'package:ateam_machinetest/utils/style.dart';
import 'package:ateam_machinetest/views/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hive/hive.dart';

class ResultsScreen extends StatefulWidget {
  final String startLocation;
  final String endLocation;

  ResultsScreen({required this.startLocation, required this.endLocation});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late MapboxMapController mapController;
  LatLng? startLatLng;
  LatLng? endLatLng;
  double? distance;
  String mapboxAccessToken =
      'sk.eyJ1IjoiYWtoaWxsZXZha3VtYXIiLCJhIjoiY2x4MDcxM3JlMGM5YTJxc2Q1cHc4MHkyZSJ9.awWNy5HErR8ooOddFDR6Gg';

  @override
  void initState() {
    super.initState();
    _updateRoute();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  void _drawRoute() {
    if (startLatLng == null || endLatLng == null) return;

    mapController.clearLines();
    mapController.clearSymbols();

    _addMarker(startLatLng!, "Start");
    _addMarker(endLatLng!, "End");

    List<LatLng> route = [startLatLng!, endLatLng!];
    mapController.addLine(
      LineOptions(
        geometry: route,
        lineColor: "#ff0000",
        lineWidth: 5.0,
      ),
    );

    // Move the camera to show the route
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        startLatLng!.latitude < endLatLng!.latitude
            ? startLatLng!.latitude
            : endLatLng!.latitude,
        startLatLng!.longitude < endLatLng!.longitude
            ? startLatLng!.longitude
            : endLatLng!.longitude,
      ),
      northeast: LatLng(
        startLatLng!.latitude > endLatLng!.latitude
            ? startLatLng!.latitude
            : endLatLng!.latitude,
        startLatLng!.longitude > endLatLng!.longitude
            ? startLatLng!.longitude
            : endLatLng!.longitude,
      ),
    );
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds,
          bottom: 50, top: 50, left: 50, right: 50),
    );
  }

  void _addMarker(LatLng position, String label) {
    mapController.addSymbol(
      SymbolOptions(
        geometry: position,
        iconImage: "marker-15",
        textField: label,
        textOffset: Offset(0, 1.5),
      ),
    );
  }

  Future<void> _updateRoute() async {
    startLatLng = await _getLatLngFromAddress(widget.startLocation);
    endLatLng = await _getLatLngFromAddress(widget.endLocation);
    if (startLatLng != null && endLatLng != null) {
      distance = await _calculateDistance(startLatLng!, endLatLng!);
      setState(() {
        _drawRoute();
      });
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$address.json?access_token=$mapboxAccessToken';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          return LatLng(coordinates[1], coordinates[0]);
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
    }
    return null;
  }

  Future<double?> _calculateDistance(LatLng start, LatLng end) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?access_token=$mapboxAccessToken';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final distance = data['routes'][0]['distance'];
          return distance / 1000; // Convert meters to kilometers
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
    }
    return null;
  }

  Future<void> _saveSearch() async {
    final searchBox = await Hive.openBox<Search>('searches');
    final search = Search(
      widget.startLocation,
      widget.endLocation,
      DateTime.now(),
    );
    await searchBox.add(search);
    print('Search saved: $search');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Route Saved'),
          content: Text('Want to check it out?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(),
                    ));
              },
            ),
          ],
        );
      },
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => HistoryScreen(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Finder'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _updateRoute(); // Refresh route when replay button is pressed
              });
            },
            icon: Icon(Icons.replay_outlined),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                Expanded(
                  child: MapboxMap(
                    accessToken: mapboxAccessToken,
                    styleString: MapboxStyles.MAPBOX_STREETS,
                    initialCameraPosition: CameraPosition(
                      target: startLatLng ?? LatLng(37.7749, -122.4194),
                      zoom: 12.0, // Adjust initial zoom level as needed
                    ),
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start: ${widget.startLocation}",
                        style: text_style_normal,
                      ),
                      Text(
                        "End: ${widget.endLocation}",
                        style: text_style_normal,
                      ),
                      Text(
                        "Distance: ${distance?.toStringAsFixed(2) ?? 'N/A'} km",
                        style: text_style_normal,
                      ),
                      ElevatedButton(
                        onPressed: _saveSearch,
                        child: const Text('Save Route'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

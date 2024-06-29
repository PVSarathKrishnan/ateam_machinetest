import 'dart:convert';
import 'package:ateam_machinetest/model/search.dart';
import 'package:ateam_machinetest/utils/style.dart';
import 'package:ateam_machinetest/views/history_screen/history_screen.dart';
import 'package:ateam_machinetest/views/home_screen/home_screen.dart';
import 'package:ateam_machinetest/views/result_screen/widgets/map_details.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  List<LatLng> routeCoordinates = [];
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
    if (routeCoordinates.isEmpty) return;

    mapController.clearLines();
    mapController.clearSymbols();

    _addMarker(startLatLng!, "Start");
    _addMarker(endLatLng!, "End");

    mapController.addLine(
      LineOptions(
        geometry: routeCoordinates,
        lineColor: "#ff0000",
        lineWidth: 5.0,
      ),
    );

   
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        routeCoordinates.map((e) => e.latitude).reduce((a, b) => a < b ? a : b),
        routeCoordinates
            .map((e) => e.longitude)
            .reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        routeCoordinates.map((e) => e.latitude).reduce((a, b) => a > b ? a : b),
        routeCoordinates
            .map((e) => e.longitude)
            .reduce((a, b) => a > b ? a : b),
      ),
    );
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds,
          bottom: 50, top: 50, left: 50, right: 50),
    );
  }

  void _addMarker(LatLng position, String label) {
    String iconImage;
    if (label == 'Start') {
      iconImage =
          'assets/origin.png'; 
    } else {
      iconImage =
          'assets/destination.png'; 
    }

    mapController.addSymbol(
      SymbolOptions(
          geometry: position,
          iconImage: iconImage,
          iconSize: 50, // Adjust icon size as needed
          textField: label,
          textOffset: Offset(0, 0),
          textSize: 20),
    );
  }

  Future<void> _updateRoute() async {
    startLatLng = await _getLatLngFromAddress(widget.startLocation);
    endLatLng = await _getLatLngFromAddress(widget.endLocation);
    if (startLatLng != null && endLatLng != null) {
      routeCoordinates = await _getRouteCoordinates(startLatLng!, endLatLng!);
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

  Future<List<LatLng>> _getRouteCoordinates(LatLng start, LatLng end) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&access_token=$mapboxAccessToken';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0]['geometry']['coordinates'];
          return route
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
    }
    return [];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Finder'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
            },
            icon: Icon(Icons.navigate_before)),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _updateRoute(); // Refresh route 
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
                      zoom: 12.0,
                    ),
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    gestureRecognizers: Set()
                      ..add(Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer())),
                  ),
                ),
                //
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        MapDetailsWidget(widget: widget, distance: distance),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveSearch,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Save Route',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

                //
              ],
            ),
          ),
        ],
      ),
    );
  }
}

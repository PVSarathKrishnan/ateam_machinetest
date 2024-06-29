
import 'package:ateam_machinetest/views/result_screen/result_screen.dart';
import 'package:flutter/material.dart';

class MapDetailsWidget extends StatelessWidget {
  const MapDetailsWidget({
    super.key,
    required this.widget,
    required this.distance,
  });

  final ResultsScreen widget;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Start Location",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          widget.startLocation,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.0),
        Text(
          "End Location",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          widget.endLocation,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Distance",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              "${distance?.toStringAsFixed(2) ?? 'N/A'} km",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.0),
      ],
    );
  }
}

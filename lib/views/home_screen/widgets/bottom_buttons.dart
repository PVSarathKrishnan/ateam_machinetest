import 'package:ateam_machinetest/views/history_screen.dart';
import 'package:ateam_machinetest/views/result_screen.dart';
import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({
    super.key,
    required this.startController,
    required this.endController,
  });

  final TextEditingController startController;
  final TextEditingController endController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                      startLocation: startController.text,
                      endLocation: endController.text,
                    ),
                  ),
                );
                
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color for gradient
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.transparent), // Remove border
                ),
                elevation: 3,
              ),
              child: Text('Navigate'),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color for gradient
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.transparent), // Remove border
                ),
                elevation: 3,
              ),
              child: Text('Saved'),
            ),
          ),
        ],
      ),
    );
  }
}

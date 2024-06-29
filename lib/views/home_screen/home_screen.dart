import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ateam_machinetest/utils/style.dart';
import 'package:ateam_machinetest/views/home_screen/widgets/bottom_buttons.dart';
import 'package:ateam_machinetest/views/home_screen/widgets/user_details.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final startController = TextEditingController();
  final endController = TextEditingController();
  String mapboxAccessToken =
      'sk.eyJ1IjoiYWtoaWxsZXZha3VtYXIiLCJhIjoiY2x4MDcxM3JlMGM5YTJxc2Q1cHc4MHkyZSJ9.awWNy5HErR8ooOddFDR6Gg';

  Future<List<String>> _getAutoCompleteSuggestions(String query) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxAccessToken';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(
            data['features'].map((feature) => feature['place_name']));
      } else {
        // Handle server errors
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('Network error: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserDetailsWidget(screenWidth: screenWidth),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 20.0),
                child: Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return await _getAutoCompleteSuggestions(
                            textEditingValue.text);
                      },
                      onSelected: (String selection) {
                        startController.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style:
                              const TextStyle(color: Colors.blue), 
                          cursorColor: Colors.blue, 
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.location_on),
                            labelText: 'Start Location',
                            labelStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue), // Label text color
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue
                                      .withOpacity(0.5)), // Border color
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Colors.blue), // Border color when focused
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Autocomplete<String>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return await _getAutoCompleteSuggestions(
                            textEditingValue.text);
                      },
                      onSelected: (String selection) {
                        endController.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style:
                              const TextStyle(color: Colors.blue), // Text color
                          cursorColor: Colors.blue, // Cursor color
                          decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.location_on),
                            labelText: 'End Location',
                            labelStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue), // Label text color
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue
                                      .withOpacity(0.5)), // Border color
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Colors.blue), // Border color when focused
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              BottomButtons(
                  startController: startController,
                  endController: endController),
              // to avoid white space
              SizedBox(
                height: screenHeight / 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Powered by",
                    style: text_style_header,
                  ),
                  Image.asset(
                    "lib/assets/mblogo.png",
                    width: screenHeight / 6,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

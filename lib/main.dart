import 'dart:async';

import 'package:ateam_machinetest/model/search.dart';
import 'package:flutter/material.dart';
import 'package:ateam_machinetest/views/home_screen/home_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'view_model/search_view_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SearchAdapter());
  await Hive.openBox<Search>('searches');

  runApp(
    ChangeNotifierProvider(
      create: (context) => SearchProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ateam Mapbox',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: SplashScreen(), // Show SplashScreen initially
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use Future.delayed to navigate after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/splash.gif', // Replace with your actual GIF path
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

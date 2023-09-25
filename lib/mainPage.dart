import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Freezer App'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[200]
      ),
      backgroundColor: Colors.lightBlue[100],
      body: Center(
        child: SearchBar(
          hintText: 'Search Freezer Inventory',
        )
      )
    );
  }
}

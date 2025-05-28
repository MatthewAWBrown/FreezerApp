import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/inven_provider.dart';
import 'screens/show_inven_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => InvenProvider(),),
        ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue
        ),
        home: const ShowInvenScreen(),
      ),
    );
  }
}


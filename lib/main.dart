// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../provider/inven_provider.dart';
// import 'screens/show_inven_screen.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//         providers: [
//           ChangeNotifierProvider(create: (context) => InvenProvider(),),
//         ],
//       builder: (context, child) => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.lightBlue
//         ),
//         home: const ShowInvenScreen(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/inven_provider.dart';
import 'screens/show_inven_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InvenProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Freezer Space',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: ShowInvenScreen(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:zip_diff/drag_drop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DragNDropWidget(text: 'Zip File 1'),
                DragNDropWidget(text: 'Zip File 2'),
              ],
            )
          ]),
        ),
      ),
    );
  }
}

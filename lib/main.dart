import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pizza_management/UI/welcome/welcome.dart';
import 'CA/ca/my_http.dart';

void main() {
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Management',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),

      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return child!;
            }

            double width = constraints.maxWidth * 0.8;
            if (width < 700) width = 700;
            if (width > 1200) width = 1200;

            return Container(
              color: const Color(0xFFF2F2F2),
              child: Center(
                child: SizedBox(
                  width: width,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: child!,
                  ),
                ),
              ),
            );
          },
        );
      },
      home: const Welcome(),
    );
  }
}
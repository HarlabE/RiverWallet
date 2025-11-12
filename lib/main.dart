import 'package:crypto_wallet_app/pages/start_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 78, 116, 240),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Theme.of(context).colorScheme.onPrimary,
          displayColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      home: StartPage(),
    );
  }
}

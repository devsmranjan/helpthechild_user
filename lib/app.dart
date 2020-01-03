import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'root.dart';

class HelpTheChildUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF4286f4),
          accentColor: const Color(0xFFDBA716),
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          ),
      home: RootPage(
        auth: Auth(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// The header for the app which contains the logo.
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Image.asset('assets/logo-noBackground.png'),
      alignment: Alignment.topLeft,
    );
  }
}

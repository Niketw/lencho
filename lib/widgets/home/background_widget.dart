import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget child;
  
  const BackgroundGradient({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 240, 240, 240), // Light yellow
            Color.fromARGB(255, 255, 255, 255), // Accent green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

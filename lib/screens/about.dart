import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About EasyDock"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "EasyDock is a smart bouy docking management app that helps you find, reserve, and manage anchor points easily.\n\nVersion 0.0.5-alpha",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
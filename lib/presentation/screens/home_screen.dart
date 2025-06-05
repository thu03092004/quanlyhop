import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Center(
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: const Center(child: Text('This is Home Screen!')),
    );
  }
}

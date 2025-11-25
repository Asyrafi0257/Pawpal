import 'package:flutter/material.dart';
import 'package:pawpal_app/model/user.dart';

class Home extends StatefulWidget {
  final User? user;

  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(child: Text('Welcome, ${widget.user?.userName}')),
    );
  }
}

import 'package:flutter/material.dart';

class DetailJobPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détail Job')),
      body: Center(child: Text('job', style: TextStyle(fontSize: 32))),
    );
  }
} 
import 'package:flutter/material.dart';

class DetailCompanyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détail Company')),
      body: Center(child: Text('company', style: TextStyle(fontSize: 32))),
    );
  }
} 
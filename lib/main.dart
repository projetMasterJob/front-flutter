import 'package:flutter/material.dart';
import 'log_in_screen.dart';
import 'detail_job.dart';
import 'detail_company.dart';
import 'template.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LogInScreen(), // La page de login reste la page d'accueil initiale
      routes: {
        '/detail_job': (context) => const DetailJobPage(),
        '/detail_company': (context) => const DetailCompanyPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';

void chatPage() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Flutter Demo 2',
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
useMaterial3: true,
),
home: const MyChatPage(title: 'Flutter Demo Home Page'),
);
}
}

class MyChatPage extends StatefulWidget {
const MyChatPage({super.key, required this.title});

final String title;

@override
State<MyChatPage> createState() => _MyChatPage();
}

class _MyChatPage extends State<MyChatPage> {
int _counter = 0;

void _incrementCounter() {
setState(() {
_counter++;
});
}

@override
Widget build(BuildContext context) {

return Scaffold(
appBar: AppBar(

backgroundColor: Theme.of(context).colorScheme.inversePrimary,

title: Text(widget.title),
),
body: Center(
// Center is a layout widget. It takes a single child and positions it
// in the middle of the parent.
child: Column(

mainAxisAlignment: MainAxisAlignment.center,
children: <Widget>[
const Text(
'You have pushed the button this many times:',
),
Text(
'$_counter',
style: Theme.of(context).textTheme.headlineMedium,
),
],
),
),
floatingActionButton: FloatingActionButton(
onPressed: _incrementCounter,
tooltip: 'Increment',
child: const Icon(Icons.add),
), // This trailing comma makes auto-formatting nicer for build methods.
);
}
}

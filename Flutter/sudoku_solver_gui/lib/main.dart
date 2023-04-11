import 'package:flutter/material.dart';
import 'Puzzle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const SudokuHomePage(title: 'Flutter Sudoku Solver GUI'),
    );
  }
}

class SudokuHomePage extends StatefulWidget {
  const SudokuHomePage({super.key, required this.title});

  final String title;

  @override
  State<SudokuHomePage> createState() => _SudokuHomePageState();
}

class _SudokuHomePageState extends State<SudokuHomePage> {
  var puzzle = Grid(3);
  bool puzzleLoaded = false;

  void loadPuzzle() {
    if (puzzleLoaded) {
      return;
    }

    puzzle.loadLine([9, 0, 0, 0, 0, 0, 4, 0, 0]);
    puzzle.loadLine([0, 0, 0, 5, 0, 0, 0, 0, 0]);
    puzzle.loadLine([0, 0, 6, 0, 1, 7, 0, 0, 2]);
    puzzle.loadLine([6, 0, 0, 0, 8, 5, 0, 9, 0]);
    puzzle.loadLine([0, 0, 5, 2, 0, 0, 0, 0, 0]);
    puzzle.loadLine([0, 0, 0, 3, 0, 0, 0, 0, 8]);
    puzzle.loadLine([0, 0, 0, 0, 3, 0, 0, 0, 0]);
    puzzle.loadLine([0, 1, 0, 0, 0, 0, 0, 2, 0]);
    puzzle.loadLine([0, 0, 7, 0, 6, 8, 0, 0, 1]);

    puzzleLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SudokuGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: loadPuzzle,
        tooltip: 'Load Puzzle',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class SudokuGrid extends StatelessWidget {
  const SudokuGrid();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'You have pushed the button this many times:',
          ),
        ],
      ),
    );
  }
}

class SudokuSubGrid extends StatelessWidget {
  const SudokuSubGrid();

  @override
  Widget build(BuildContext context) {
    return Center();
  }
}

class SudokuCell extends StatelessWidget {
  const SudokuCell();

  @override
  Widget build(BuildContext context) {
    return Center();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

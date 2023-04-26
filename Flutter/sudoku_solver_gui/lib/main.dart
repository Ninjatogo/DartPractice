import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: const MyHomePage(title: 'Flutter Sudoku Solver GUI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Grid puzzleSolver;
  late GlobalKey<SudokuBoardState> _childWidgetKey;
  List<List<int>> grid = [
    [9, 0, 0, 0, 0, 0, 4, 0, 0],
    [0, 0, 0, 5, 0, 0, 0, 0, 0],
    [0, 0, 6, 0, 1, 7, 0, 0, 2],
    [6, 0, 0, 0, 8, 5, 0, 9, 0],
    [0, 0, 5, 2, 0, 0, 0, 0, 0],
    [0, 0, 0, 3, 0, 0, 0, 0, 8],
    [0, 0, 0, 0, 3, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 2, 0],
    [0, 0, 7, 0, 6, 8, 0, 0, 1],
  ];

  @override
  void initState() {
    super.initState();
    _childWidgetKey = GlobalKey();
  }

  void _loadCurrentInputToPuzzleSolver() {
    setState(() {
      // Call the method on the object inside the child widget
      puzzleSolver = Grid(useMrv: true, useForwardChecking: true);
      for (var row in grid) {
        puzzleSolver.loadLine(row);
      }
      if (puzzleSolver.solveViaBacktracking()) {
        grid = puzzleSolver.getGridCellValues();
        // Update the key to force the child widget to rebuild
        _childWidgetKey = GlobalKey();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        SudokuBoard(key: _childWidgetKey, grid: grid),
        const Spacer(
          flex: 1,
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCurrentInputToPuzzleSolver,
        tooltip: 'Solve puzzle',
        child: const Icon(Icons.lightbulb),
      ),
    );
  }
}

class SudokuBoard extends StatefulWidget {
  final List<List<int>> grid;

  const SudokuBoard({required Key key, required this.grid}) : super(key: key);

  @override
  SudokuBoardState createState() => SudokuBoardState();
}

class SudokuBoardState extends State<SudokuBoard> {
  late List<List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SudokuBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.grid != oldWidget.grid) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _controllers = [];
    for (var row = 0; row < 9; row++) {
      List<TextEditingController> rows = [];
      for (var column = 0; column < 9; column++) {
        var value = widget.grid[row][column];
        rows.add(
            TextEditingController(text: (value > 0) ? value.toString() : '0'));
      }
      _controllers.add(rows);
    }
  }

  void _disposeControllers() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        _controllers[i][j].dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var row = 0; row < widget.grid.length; row++)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var column = 0;
                        column < widget.grid[row].length;
                        column++)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: const BorderSide(
                                  color: Colors.black, width: 1.0),
                              left: const BorderSide(
                                  color: Colors.black, width: 1.0),
                              right: BorderSide(
                                color: Colors.black,
                                width: ((column + 1) % 3 == 0) ? 3.0 : 1.0,
                              ),
                              bottom: BorderSide(
                                color: Colors.black,
                                width: ((row + 1) % 3 == 0) ? 3.0 : 1.0,
                              ),
                            ),
                            color: (row % 3 == 0)
                                ? Colors.grey[200]
                                : Colors.white,
                          ),
                          child: TextField(
                            controller: _controllers[row][column],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(4.0),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: (row % 3 == 0)
                                  ? Colors.black
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

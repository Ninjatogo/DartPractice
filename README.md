# DartPractice

Collection of Dart practice projects demonstrating core algorithm implementation and Flutter development. This repository contains a sudoku solver with two implementations: a command-line solver and an interactive Flutter GUI application.

## 📁 Project Structure

```
DartPractice/
├── Sudoku Solver/           # Pure Dart CLI sudoku solver
│   ├── Puzzle.dart          # Core solver engine with backtracking algorithm
│   ├── Solve Engine.dart    # Benchmark and testing harness
│   ├── Stack.dart           # Custom generic stack data structure
│   └── pubspec.yaml         # Project dependencies
│
├── Flutter/                 # Flutter GUI applications
│   └── sudoku_solver_gui/   # Interactive sudoku solver app
│       ├── lib/
│       │   ├── main.dart    # Flutter app entry point and UI components
│       │   ├── Puzzle.dart  # Solver engine (copied from CLI)
│       │   └── Stack.dart   # Stack implementation (copied from CLI)
│       ├── test/            # Widget tests
│       └── pubspec.yaml     # Project dependencies
│
└── README.md                # This file
```

## 🎯 Project Overview

This repository demonstrates the implementation of a sophisticated sudoku solver using constraint propagation and backtracking with multiple optimization heuristics. It serves as both a practical example of algorithm design and a hands-on Flutter development project.

### Key Features

- **Advanced Constraint Solving**: Implements multiple heuristics for optimal performance
- **Performance Benchmarking**: Built-in benchmarking to measure solver efficiency
- **Interactive GUI**: User-friendly Flutter interface for solving puzzles
- **Custom Data Structures**: Implements a generic Stack for internal state management
- **Algorithm Optimization**: Demonstrates the impact of different heuristic combinations

## 📚 Documentation

For detailed information about each component:

- **[Sudoku Solver CLI Documentation](./Sudoku%20Solver/README.md)** - Command-line solver with benchmarking
- **[Flutter GUI Documentation](./Flutter/sudoku_solver_gui/README.md)** - Interactive web app with visual interface
- **[API & Architecture Documentation](./ARCHITECTURE.md)** - Technical implementation details

## 🚀 Quick Start

### Running the CLI Solver

```bash
cd "Sudoku Solver"
dart "Solve Engine.dart"
```

This will run benchmark tests on several difficult sudoku puzzles and display:
- Solver output for each puzzle
- Number of backtracking steps required
- Comparison of different heuristic configurations

### Running the Flutter GUI

```bash
cd Flutter/sudoku_solver_gui
flutter pub get
flutter run
```

This launches an interactive sudoku solver where you can:
- Enter a puzzle manually or paste unsolved puzzle values
- Click the "Solve" button to solve the puzzle
- View the solution displayed in the grid

## 🧠 Core Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| CLI Solver | Dart 2.18.6+ | Algorithm implementation and benchmarking |
| GUI App | Flutter | Cross-platform interactive interface |
| Data Structure | Dart | Generic stack for operation history |
| Constraint Solver | Custom Implementation | Sudoku-specific constraint propagation |

## 📊 Performance Metrics

The solver demonstrates dramatic improvements with heuristic optimization:

**Example: Evil Difficulty Puzzle**

| Configuration | Backtracking Steps | Relative Performance |
|---|---|---|
| No heuristics | 120,552 | 1x |
| MRV only | 3,777 | 31x faster |
| MRV + Forward Checking | 149 | **804x faster** |
| LCV + Forward Checking | 3,238 | 37x faster |

*MRV = Minimum Remaining Values heuristic*
*LCV = Least Constraining Value heuristic*

## 🔧 Implementation Highlights

### Solver Architecture

The sudoku solver (`Puzzle.dart`) consists of:

1. **Constraint Propagation Phase** - Eliminates impossible values from cells
2. **Backtracking Search** - Recursively assigns values using constraint checking
3. **Heuristic Optimization**:
   - Minimum Remaining Values (MRV) - Prioritize cells with fewer possibilities
   - Least Constraining Value (LCV) - Order value assignments by constraint impact
   - Forward Checking - Pre-validate remaining cells

### GUI Architecture

The Flutter application (`main.dart`) provides:

1. **Dynamic Grid Input** - 9×9 grid of text fields for puzzle input
2. **Styled Board Display** - Visual sudoku board with 3×3 subgrid borders
3. **Solver Integration** - Direct integration with the Puzzle engine
4. **Result Display** - Shows solved puzzle with step count

## 📖 Learning Resources

This project is designed as a learning reference for:

- **Algorithm Design**: Constraint satisfaction problems and backtracking algorithms
- **Optimization Techniques**: Heuristic-driven search strategies
- **Dart Programming**: Language features and best practices
- **Flutter Development**: Widget composition, state management, and UI design
- **Custom Data Structures**: Generic implementation patterns in Dart

## 🔄 Development History

Key milestones:

- Added styled sudoku board to Flutter app
- Reduced external visibility of sudoku internals (encapsulation)
- Sudoku solver code cleanup and optimization
- Added LCV and forward checking heuristics
- Added message to show number of backtracking steps
- Implemented MRV heuristic
- Added framework for Flutter sudoku app

## 📝 License

This is an educational project created for learning purposes.

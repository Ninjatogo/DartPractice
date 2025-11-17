# Sudoku Solver GUI

An interactive Flutter application for solving sudoku puzzles with a styled visual board and real-time solution display.

## Overview

This Flutter application provides a user-friendly interface to the sudoku solver engine. Users can input puzzles manually or paste pre-filled values, then click a button to solve and view the solution. The interface includes a properly styled sudoku board with 3×3 subgrid borders for visual clarity.

**Features:**
- Interactive 9×9 sudoku input grid
- Styled board display with 3×3 subgrid borders
- One-click solving with integrated solver engine
- Solution display with backtracking step count
- Responsive design optimized for mobile and tablet
- Single-digit input validation

## Quick Start

### Prerequisites

- Flutter SDK 3.0 or later
- Dart SDK 2.18.6 or later
- A mobile device or emulator/simulator

### Installation & Running

1. **Get dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the application:**
   ```bash
   flutter run
   ```

3. **For specific platforms:**
   ```bash
   flutter run -d ios      # iOS device/simulator
   flutter run -d android  # Android device/emulator
   flutter run -d web      # Web browser (if enabled)
   ```

### Usage

1. **Enter a puzzle:**
   - Tap each cell and enter a digit (1-9)
   - Leave cells empty (don't enter anything) for unsolved cells
   - Only numeric input is accepted

2. **Solve the puzzle:**
   - Tap the blue "Solve" floating action button
   - Wait for the solver to complete

3. **View the solution:**
   - The solved puzzle is displayed in the same grid
   - Step count shows how many backtracking iterations were needed
   - The solution remains on screen for copying or further work

## Architecture

### Project Structure

```
sudoku_solver_gui/
├── lib/
│   ├── main.dart                    # App entry point and UI
│   ├── Puzzle.dart                  # Solver engine (copied from CLI)
│   ├── Stack.dart                   # Stack data structure
│   └── [other auto-generated files]
├── test/
│   └── widget_test.dart             # Flutter widget tests
├── pubspec.yaml                     # Dependencies and metadata
├── analysis_options.yaml            # Linting configuration
└── README.md                        # This file
```

### Main Components

#### `MyApp` Widget

Root application widget that:
- Sets up Material Design theme with blue color scheme
- Creates the app title "Sudoku Solver"
- Initializes `MyHomePage` as the main screen

#### `MyHomePage` Widget

Stateful widget managing the main sudoku interface:

**State:**
- `_gridControllers` - Array of TextEditingController for each cell
- `_solution` - 2D array storing the solved puzzle
- `_backtrackingSteps` - Counter for display

**Key Methods:**
- `initState()` - Initialize 81 text controllers (one per cell)
- `dispose()` - Clean up controllers when widget is destroyed
- `_solvePuzzle()` - Extract values, run solver, display results
- `build()` - Construct the UI

#### `SudokuBoard` Widget

Custom widget rendering the sudoku grid:

**Features:**
- 9×9 grid of TextField widgets
- 3×3 styled borders for subgrid separation
- Alternating cell colors for visual distinction
- Input validation (digits only)
- Responsive sizing

**Styling:**
- Regular cell borders: 1px gray
- Subgrid borders (every 3rd row/column): 3px black
- Alternating colors: light gray and white
- Consistent cell sizing for square appearance

## Widget Hierarchy

```
MyApp
└── MyHomePage (Stateful)
    ├── AppBar
    │   └── Text ("Sudoku Solver")
    ├── Scaffold
    │   ├── Body
    │   │   └── Column
    │   │       ├── SudokuBoard
    │   │       └── Result Display (Text)
    │   └── FloatingActionButton
    │       └── Icon (Solve)
    └── Dialog (Error display)
```

## Usage Examples

### Input a Puzzle Programmatically

```dart
// To input puzzle values:
_gridControllers[rowIndex * 9 + colIndex].text = '5';
```

### Extract Puzzle from Grid

```dart
List<List<int>> puzzle = [];
for (int i = 0; i < 9; i++) {
  List<int> row = [];
  for (int j = 0; j < 9; j++) {
    String val = _gridControllers[i * 9 + j].text;
    row.add(val.isEmpty ? 0 : int.parse(val));
  }
  puzzle.add(row);
}
```

### Solve and Display

```dart
Grid grid = Grid(
  useMrv: true,
  useForwardChecking: true,
);

for (var row in puzzle) {
  grid.loadLine(row);
}

if (grid.solveViaBacktracking()) {
  setState(() {
    _solution = grid.getGridCellValues();
    _backtrackingSteps = grid.getBacktrackingStepCount();
  });
} else {
  _showErrorDialog("No solution found for this puzzle");
}
```

## UI Components

### Sudoku Board (`SudokuBoard` Widget)

A custom widget that renders the sudoku grid with:

**Cell Input:**
- 81 TextField widgets (9×9 grid)
- Single digit input only (regex validation)
- White/light gray alternating background
- No keyboard autocorrect or suggestions

**Borders & Styling:**
- 1px gray borders between cells
- 3px black borders around 3×3 subgrids
- Proper spacing and alignment
- Responsive to screen size

**Color Scheme:**
- Light gray background for odd-indexed cells
- White background for even-indexed cells
- Black text on light backgrounds
- Blue accent for focused cells

### Floating Action Button

**Purpose:** Trigger puzzle solving

**Behavior:**
- Shows a solve icon (redo/refresh icon)
- Tapping invokes `_solvePuzzle()`
- Scales on interaction
- Blue color matching theme

### Result Display

**Shows:**
- Solved puzzle values in the same grid
- Success message with step count
- Aligned with input interface

**Example Output:**
```
Puzzle solved! Required 149 backtracking steps.
```

### Error Handling

**Shows AlertDialog on:**
- Invalid puzzle (no solution)
- Invalid input format
- Solver timeout (not implemented)

## Integration with Solver Engine

### Grid Class Integration

The Flutter app uses the same `Grid` class from the CLI solver:

```dart
// Initialize with optimal heuristics
Grid grid = Grid(
  gridDiameter: 3,
  useMrv: true,
  useForwardChecking: true,
);

// Load puzzle
for (var row in inputPuzzle) {
  grid.loadLine(row);
}

// Solve
if (grid.solveViaBacktracking()) {
  var solution = grid.getGridCellValues();
  var steps = grid.getBacktrackingStepCount();
  // Display results
}
```

### Code Duplication Note

The `Puzzle.dart` and `Stack.dart` files are copied from the CLI solver. In a production app, these should be shared via:
- Dart package
- Shared code directory with symbolic links
- Monorepo setup

## Dependencies

```yaml
name: sudoku_solver_gui
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  tuple: ^2.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

**Key Dependencies:**
- `flutter` - Flutter framework and widgets
- `tuple` - Used by solver's LCV heuristic
- `flutter_lints` - Code quality analysis
- `cupertino_icons` - iOS-style icons

## Styling & Theming

### Material Theme

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,
  useMaterial3: true,
)
```

### Color Palette

| Element | Color | Usage |
|---------|-------|-------|
| Primary | Blue | FAB, focused inputs |
| Background | White | Empty cells |
| Alternate | Light Gray | Alternating cells |
| Borders | Gray/Black | Cell and subgrid borders |
| Text | Black | Input and display |

### Responsive Design

- Adapts to different screen sizes
- Grid scales proportionally
- Touch-friendly cell sizes
- Works on phones, tablets, and web

## Testing

### Widget Tests

Located in `test/widget_test.dart`:

```bash
flutter test
```

Current tests include:
- App initialization verification
- Widget presence checks
- Basic UI rendering tests

### Manual Testing Checklist

- [ ] Input validation (only digits 1-9)
- [ ] Empty cells (leave blank)
- [ ] Solve button triggers solving
- [ ] Solution displays correctly
- [ ] Step count shows accurate number
- [ ] Error dialog on invalid puzzles
- [ ] Responsive on different screen sizes
- [ ] All cells visible without scrolling
- [ ] Input fields are accessible
- [ ] Results persist after solving

## Performance

### Solver Performance

Inherits performance from CLI solver:
- **Evil puzzles:** Solved in ~5-10ms with heuristics
- **Medium puzzles:** < 1ms
- **Easy puzzles:** < 1ms

### UI Performance

- Minimal rebuild cycles (only when solving)
- Efficient TextEditingController management
- Grid rendering is O(81) = O(1)
- No unnecessary repaints between interactions

## Future Enhancements

Potential improvements for production:

1. **Features:**
   - Puzzle import/export (image OCR)
   - Multiple difficulty levels
   - Timer and leaderboard
   - Save progress
   - Hint system
   - Undo/Redo

2. **Performance:**
   - Async solving (don't block UI)
   - Progress indication
   - Animation on reveal

3. **Code Quality:**
   - Extract widgets into separate files
   - Implement proper state management (Provider/Riverpod)
   - Share solver code via package
   - Add integration tests

4. **UX:**
   - Keyboard support for faster input
   - Paste puzzle from clipboard
   - Share solution
   - Dark mode
   - Haptic feedback

## Troubleshooting

### App Won't Run

```bash
flutter clean
flutter pub get
flutter run
```

### Solver Not Responding

- Check puzzle validity (has unique solution)
- Try a simpler puzzle first
- Check console for error messages

### Input Not Accepted

- Only digits 1-9 are accepted
- Empty cells leave the field blank
- No special characters allowed

### Grid Not Displaying Properly

- Check device screen size
- Try rotating device
- Rebuild with `flutter clean`

## File Reference

| File | Purpose | Lines |
|------|---------|-------|
| `main.dart` | UI widgets and app logic | ~500 |
| `Puzzle.dart` | Solver engine | ~564 |
| `Stack.dart` | Stack implementation | ~50 |
| `widget_test.dart` | Widget tests | ~30 |

## Learning Resources

This app demonstrates:
- **Stateful Widgets** - State management with `setState()`
- **Custom Widgets** - `SudokuBoard` widget composition
- **Form Input** - TextField widgets with validation
- **Layout** - Column, Row, GridView alternatives
- **Material Design** - Theme, colors, FAB, AppBar
- **Dialog** - Error handling with AlertDialog
- **Integration** - Using Dart code from CLI in Flutter

## License

Educational project for learning Flutter development.

## Related Documentation

- [Parent Project Documentation](../../README.md)
- [Sudoku Solver CLI Documentation](../../Sudoku%20Solver/README.md)
- [Architecture & API Documentation](../../ARCHITECTURE.md)
- [Flutter Official Documentation](https://docs.flutter.dev/)
- [Dart Language Guide](https://dart.dev/guides)

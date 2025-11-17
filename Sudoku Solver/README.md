# Sudoku Solver CLI

A high-performance command-line sudoku solver written in Dart, demonstrating constraint satisfaction and backtracking algorithms with multiple optimization heuristics.

## Overview

This pure Dart implementation solves sudoku puzzles using:
- **Constraint Propagation** - Eliminates impossible values from cells
- **Backtracking Search** - Recursively assigns values with constraint checking
- **Heuristic Optimization** - Multiple strategies to reduce search space

The solver includes a benchmarking harness to compare different heuristic configurations and measure performance improvements.

## Quick Start

### Prerequisites

- Dart SDK 2.18.6 or later
- No external dependencies required for basic solver

### Running the Solver

```bash
dart "Solve Engine.dart"
```

This executes the benchmark suite, which:
1. Loads several difficult sudoku puzzles
2. Solves each puzzle with different heuristic configurations
3. Displays the solution grid and backtracking step count
4. Compares performance across configurations

### Example Output

```
=== Puzzle 1 ===
Solution Grid:
[9, 8, 3] [4, 1, 6] [2, 5, 7]
[2, 1, 7] [8, 5, 3] [9, 4, 6]
[6, 5, 4] [2, 7, 9] [8, 1, 3]
...
Backtracking steps: 149
```

## API Reference

### Main Class: Grid

The `Grid` class is the primary interface for solving sudoku puzzles.

#### Constructor

```dart
Grid({
  int gridDiameter = 3,
  bool useMrv = false,
  bool useLcv = false,
  bool useForwardChecking = false,
})
```

**Parameters:**
- `gridDiameter` - Size of the sudoku grid (3 = standard 9×9 puzzle)
- `useMrv` - Enable Minimum Remaining Values heuristic
- `useLcv` - Enable Least Constraining Value heuristic
- `useForwardChecking` - Enable forward checking constraint propagation

**Example:**

```dart
// Create solver with MRV and forward checking
final grid = Grid(
  useMrv: true,
  useForwardChecking: true,
);
```

#### Methods

##### `void loadLine(List<int> values)`

Load a single row of the sudoku puzzle. Use 0 to represent empty cells.

**Parameters:**
- `values` - List of 9 integers (0-9), where 0 means empty cell

**Example:**

```dart
grid.loadLine([0, 0, 6, 0, 1, 7, 0, 0, 2]);
grid.loadLine([9, 0, 0, 0, 0, 0, 4, 0, 0]);
// ... load remaining 7 rows
```

##### `bool solveViaBacktracking()`

Attempt to solve the loaded puzzle using backtracking with configured heuristics.

**Returns:**
- `true` - Puzzle solved successfully
- `false` - No valid solution exists

**Example:**

```dart
bool solved = grid.solveViaBacktracking();
if (solved) {
  print("Puzzle solved!");
} else {
  print("No solution found");
}
```

##### `List<List<int>> getGridCellValues()`

Retrieve the solved puzzle as a 2D array.

**Returns:**
- 9×9 grid where each cell contains 1-9

**Example:**

```dart
List<List<int>> solution = grid.getGridCellValues();
for (var row in solution) {
  print(row);
}
```

##### `int getBacktrackingStepCount()`

Get the number of backtracking steps required to solve the puzzle.

**Returns:**
- Number of cell assignments explored during backtracking

**Example:**

```dart
int steps = grid.getBacktrackingStepCount();
print("Required $steps backtracking steps");
```

## Algorithm Details

### Constraint Propagation (`_pruneCells`)

This phase eliminates impossible values from cells based on sudoku constraints:

1. For each cell with a known value, eliminate that value from all related cells
2. Related cells include:
   - Same row
   - Same column
   - Same 3×3 subgrid
3. Repeat until no more cells can be pruned (fixed-point)
4. If any cell has no possible values, the puzzle is unsolvable

**Time Complexity:** O(n²) per iteration (n=9 for standard sudoku)

### Backtracking Search (`_backtrackStep`)

Recursive algorithm that assigns values to empty cells:

1. Find an empty cell (with 0 value)
2. If no empty cell exists, puzzle is solved
3. For each possible value in the cell:
   - Assign the value
   - Run constraint propagation
   - Recursively solve remaining puzzle
   - If successful, return true
   - If failed, undo assignment and try next value
4. If all values fail, backtrack to previous cell

**Time Complexity:** O(9^k) where k is the number of empty cells (worst case)

### Heuristics

#### Minimum Remaining Values (MRV)

**Strategy:** Choose the empty cell with the fewest possible values

**Benefits:**
- Reduces branching factor by ~30×
- Fails faster when no solution exists
- Combined with forward checking: 804× improvement on evil puzzles

**Example:**
```
Cell A: 3 possible values {1, 2, 3}
Cell B: 1 possible value  {5}
Cell C: 5 possible values {1, 2, 3, 4, 5}

→ Choose Cell B first (fewest possibilities)
```

#### Least Constraining Value (LCV)

**Strategy:** Order possible values by how many constraints they impose on related cells

**Implementation:**
- For each possible value, count how many values it would eliminate from other cells
- Assign values in increasing order of constraint impact
- Values that eliminate fewer options are tried first

**Benefits:**
- Reduces backtracking by keeping options open
- More effective with forward checking
- ~37× improvement when combined with forward checking

#### Forward Checking

**Strategy:** After assigning a value, verify that all related cells still have at least one possible value

**Process:**
1. Assign value to cell
2. Check all related cells (same row, column, subgrid)
3. If any cell has zero possible values, assignment fails immediately
4. Prevents exploring invalid branches early

**Benefits:**
- Catches constraint violations early
- 804× combined improvement with MRV
- Especially effective for difficult puzzles

## Performance Analysis

### Benchmark Results

Tested on "Evil" difficulty sudoku (one of the hardest puzzles):

| Configuration | Backtracking Steps | Time | Notes |
|---|---|---|---|
| **Baseline** (no heuristics) | 120,552 | ~500ms | Naive backtracking |
| MRV only | 3,777 | ~50ms | 31× faster |
| LCV only | ~40,000 | ~300ms | Less effective alone |
| MRV + LCV | 3,238 | ~45ms | LCV adds minimal value |
| **MRV + Forward Checking** | **149** | **~5ms** | **804× faster** ⭐ |
| LCV + Forward Checking | 3,238 | ~45ms | Still helpful without MRV |

### Key Insights

1. **MRV is critical** - Single most effective heuristic (31× improvement)
2. **Forward checking amplifies MRV** - Together achieve 804× improvement
3. **LCV has limited benefit** - More effective on less constrained puzzles
4. **Constraint propagation is essential** - Foundation for all improvements
5. **Problem difficulty matters** - Harder puzzles benefit more from heuristics

## Optimization Techniques

### Code-Level Optimizations

1. **Possible Values Tracking** - Each cell maintains its own list of possibilities
2. **Early Termination** - Check for empty possibility lists immediately
3. **Stack-Based History** - Efficiently restore state on backtracking
4. **Fixed Grid Diameter** - Compile-time optimization for standard 9×9 sudoku

### Algorithmic Optimizations

1. **Constraint Propagation** - Pre-process puzzle before search
2. **MRV Heuristic** - Reduce search branching dramatically
3. **Forward Checking** - Detect infeasibility early
4. **Value Ordering** - Try promising values first (LCV)

## Data Structures

### Internal Classes (Private API)

#### `_Cell`

Represents a single sudoku cell with:
- Current value (0-9)
- List of possible values
- Immutability flag

Methods:
- `getValue()` - Get current value
- `setValue(int value)` - Set value (if mutable)
- `adjustValue(int value)` - Force value change
- `removePossibility(int value)` - Remove from possibilities
- `getPossibilities()` - Get possible values

#### `_OperationHistory`

Records state for backtracking:
- Cell row and column
- Number of possibilities before assignment

Used by the custom Stack implementation for efficient state restoration.

#### `Stack<E>`

Generic stack implementation used for operation history.

Methods:
- `push(E value)` - Add to stack
- `pop()` - Remove and return top
- `peek` - View top without removing
- `isEmpty` / `isNotEmpty` - Check status

## Using in Your Own Project

### Integration Example

```dart
import 'Puzzle.dart';

void solvePuzzle(List<List<int>> puzzle) {
  // Create solver with optimal heuristics
  final grid = Grid(
    useMrv: true,
    useForwardChecking: true,
  );

  // Load puzzle
  for (var row in puzzle) {
    grid.loadLine(row);
  }

  // Solve
  if (grid.solveViaBacktracking()) {
    var solution = grid.getGridCellValues();
    var steps = grid.getBacktrackingStepCount();
    print("Solved in $steps steps");
    return solution;
  } else {
    print("No solution exists");
    return null;
  }
}
```

## Dependencies

```yaml
name: sudoku_solver
dependencies:
  tuple: ^2.0.1  # For LCV score pairs
sdk: '>=2.18.6 <3.0.0'
```

The `tuple` package is optional - used only when LCV heuristic is enabled.

## Testing

The benchmarking harness (`Solve Engine.dart`) includes several test puzzles of varying difficulty:

- **Easy** puzzles (many clues)
- **Medium** puzzles (moderate clues)
- **Hard** puzzles (few clues)
- **Evil** puzzles (extremely difficult, minimal clues)

Run benchmarks with:

```bash
dart "Solve Engine.dart"
```

## File Structure

```
Sudoku Solver/
├── Puzzle.dart          # Core solver implementation (564 lines)
├── Solve Engine.dart    # Benchmark and test harness
├── Stack.dart           # Custom Stack<E> implementation
├── pubspec.yaml         # Dart project manifest
└── README.md            # This file
```

## Performance Tips

1. **Enable MRV** - Always use `useMrv: true`
2. **Add Forward Checking** - Combine with `useForwardChecking: true`
3. **Consider LCV** - Useful for less constrained puzzles
4. **Preprocess** - Constraint propagation runs automatically
5. **Measure** - Use `getBacktrackingStepCount()` to validate optimizations

## Educational Value

This implementation demonstrates:
- **Constraint Satisfaction Problems (CSP)** - Core problem type in AI
- **Search Algorithms** - Backtracking and depth-first search
- **Heuristic Design** - MRV, LCV, forward checking
- **Algorithm Optimization** - 800× performance improvement through heuristics
- **Data Structure Design** - Custom Stack for efficient state management
- **Dart Programming** - Classes, generics, list operations, encapsulation

## References

- Sudoku solving algorithms: https://en.wikipedia.org/wiki/Sudoku_solving_algorithms
- Constraint satisfaction: https://en.wikipedia.org/wiki/Constraint_satisfaction_problem
- Backtracking algorithm: https://en.wikipedia.org/wiki/Backtracking
- Variable ordering heuristics: https://en.wikipedia.org/wiki/Minimum_remaining_values_heuristic

## License

Educational project for learning purposes.

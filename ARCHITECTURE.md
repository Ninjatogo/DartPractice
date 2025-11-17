# Architecture & API Documentation

Comprehensive technical documentation for the Sudoku Solver project, including implementation details, class diagrams, algorithm explanations, and integration guidelines.

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Core Classes & APIs](#core-classes--apis)
3. [Algorithm Details](#algorithm-details)
4. [Data Structures](#data-structures)
5. [Class Relationships](#class-relationships)
6. [Implementation Guide](#implementation-guide)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Application Layer                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐          ┌────────────────────────┐   │
│  │  CLI Solver          │          │  Flutter GUI App       │   │
│  │  (Solve Engine.dart) │          │  (main.dart)           │   │
│  └──────────────────────┘          └────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     Domain Layer (Core Logic)                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Grid Class (Puzzle.dart)                                │   │
│  │  ├── Constraint Propagation (_pruneCells)               │   │
│  │  ├── Backtracking Search (_backtrackStep)               │   │
│  │  ├── Heuristic Optimization                             │   │
│  │  │   ├── MRV (Minimum Remaining Values)                │   │
│  │  │   ├── LCV (Least Constraining Value)                │   │
│  │  │   └── Forward Checking                              │   │
│  │  └── Cell Management (_Cell, _OperationHistory)        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Stack<E> (Stack.dart)                                   │   │
│  │  Generic LIFO data structure for operation history       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Module Breakdown

| Module | File | Purpose | Size |
|--------|------|---------|------|
| **Solver Core** | `Puzzle.dart` | Constraint solving engine | 564 lines |
| **Data Structure** | `Stack.dart` | Generic stack implementation | ~50 lines |
| **CLI Interface** | `Solve Engine.dart` | Benchmark and testing harness | ~200 lines |
| **GUI Interface** | `main.dart` | Flutter application | ~500 lines |

### Execution Flow

```
┌──────────────┐
│  Input       │
│  - Puzzle    │
│  - Config    │
└──────────────┘
       ↓
┌──────────────────────────────────────────┐
│  Grid Initialization                     │
│  - Create 9×9 cell array                 │
│  - Initialize possibilities lists        │
│  - Load puzzle values                    │
└──────────────────────────────────────────┘
       ↓
┌──────────────────────────────────────────┐
│  Phase 1: Constraint Propagation         │
│  _pruneCells() - Eliminate impossibilities│
│  - Runs to fixed-point                   │
│  - Detects unsolvable puzzles            │
└──────────────────────────────────────────┘
       ↓
┌──────────────────────────────────────────┐
│  Phase 2: Backtracking Search            │
│  _backtrackStep() - Recursive solving     │
│  - Apply heuristics (MRV, LCV)           │
│  - Try values, constraint propagate      │
│  - Backtrack on conflict                 │
│  - Count backtracking steps              │
└──────────────────────────────────────────┘
       ↓
┌──────────────────────────────────────────┐
│  Output                                  │
│  - Solution grid (9×9)                   │
│  - Step count                            │
│  - Success flag                          │
└──────────────────────────────────────────┘
```

---

## Core Classes & APIs

### Grid Class (Main API)

**Location:** `Puzzle.dart` (public API)

**Purpose:** Main interface for sudoku solving. Encapsulates the complete solver engine.

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

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `gridDiameter` | int | 3 | Subgrid size (3 = 9×9 standard sudoku) |
| `useMrv` | bool | false | Enable MRV heuristic |
| `useLcv` | bool | false | Enable LCV heuristic |
| `useForwardChecking` | bool | false | Enable forward checking |

**Example:**

```dart
// Optimal configuration for difficult puzzles
final grid = Grid(
  gridDiameter: 3,
  useMrv: true,
  useForwardChecking: true,
);
```

#### Public Methods

##### `void loadLine(List<int> values)`

Load a single row into the puzzle.

**Parameters:**
- `values` - List of 9 integers (1-9 for known cells, 0 for empty)

**Constraints:**
- Must be called 9 times (once per row)
- Must be called before `solveViaBacktracking()`
- Values outside [0, 9] cause assertion errors

**Example:**

```dart
grid.loadLine([0, 0, 6, 0, 1, 7, 0, 0, 2]);
grid.loadLine([9, 0, 0, 0, 0, 0, 4, 0, 0]);
// ... load remaining rows
```

##### `bool solveViaBacktracking()`

Solve the loaded puzzle using backtracking with heuristics.

**Returns:**
- `true` - Puzzle solved successfully
- `false` - No valid solution exists or puzzle is invalid

**Process:**
1. Runs constraint propagation to initial fixed-point
2. Recursively applies backtracking search
3. Uses MRV/LCV/forward checking if enabled
4. Returns immediately on first solution found
5. Counts all backtracking steps

**Time Complexity:**
- Best case: O(n²) - Already solved or easy puzzle
- Average case: O(9^k) where k ≈ empty cells - Depends on heuristics
- Worst case: O(9^81) - All cells empty, no heuristics

**Example:**

```dart
if (grid.solveViaBacktracking()) {
  print("Puzzle solved");
} else {
  print("No solution found");
}
```

##### `List<List<int>> getGridCellValues()`

Get the solved puzzle as a 2D array.

**Returns:**
- 9×9 grid where each cell contains 1-9
- Returns state after `solveViaBacktracking()` completion
- Returns only solved cells (empty if solve failed)

**Example:**

```dart
var solution = grid.getGridCellValues();
for (int i = 0; i < 9; i++) {
  print(solution[i]); // [1, 2, 3, 4, 5, 6, 7, 8, 9]
}
```

##### `int getBacktrackingStepCount()`

Get the number of backtracking steps used.

**Returns:**
- Integer count of cell assignments during backtracking
- Valid only after `solveViaBacktracking()` completes
- Useful for performance comparison

**Example:**

```dart
int steps = grid.getBacktrackingStepCount();
print("Solved in $steps steps");
// Output: Solved in 149 steps
```

### _Cell Class (Private API)

**Location:** `Puzzle.dart` (internal use)

**Purpose:** Represents a single sudoku cell with mutable state.

**Properties:**
```dart
int value;                      // Current value (0 = empty)
bool mutable;                   // Can be changed
List<int> possibilities;        // Possible values for this cell
int subgridMarker;             // For debugging/visualization
```

**Methods:**

| Method | Purpose |
|--------|---------|
| `getValue()` | Get current cell value |
| `setValue(int v)` | Set value (only if mutable) |
| `adjustValue(int v)` | Force change regardless of mutability |
| `removePossibility(int v)` | Remove value from possibilities |
| `getPossibilities()` | Get list of possible values |

**Encapsulation Note:**
- `_Cell` is private (prefixed with `_`) to hide internal representation
- Accessed only through `Grid` public interface
- Prevents external code from directly modifying solver state

### _OperationHistory Class (Private API)

**Location:** `Puzzle.dart` (internal use)

**Purpose:** Records cell state changes for backtracking.

**Properties:**
```dart
int cellPosition;        // Row * 9 + column
int possibilityCount;    // Number of possibilities before assignment
```

**Usage:** Stored in Stack for efficient state restoration during backtracking.

### Stack<E> Class (Data Structure)

**Location:** `Stack.dart`

**Purpose:** Generic LIFO data structure for operation history tracking.

**Generic Type:** `E` - Any type (used with `_OperationHistory`)

**Methods:**

```dart
void push(E value)           // Add to stack
E pop()                      // Remove and return top
E get peek                   // View top without removing
bool get isEmpty             // Check if empty
bool get isNotEmpty          // Check if not empty
```

**Example:**

```dart
final stack = Stack<int>();
stack.push(42);
print(stack.peek);           // 42
print(stack.pop());          // 42
print(stack.isEmpty);        // true
```

---

## Algorithm Details

### Constraint Propagation Phase

**Function:** `_pruneCells()` (private, called during initialization and after each assignment)

**Purpose:** Eliminate impossible values from cells based on sudoku constraints.

**Algorithm:**

```
FUNCTION pruneCells()
  changed = true
  WHILE changed:
    changed = false
    FOR each cell in grid:
      IF cell.value != 0:                    // Cell is known
        FOR each related cell:
          IF cell.value IN related.possibilities:
            REMOVE cell.value from related.possibilities
            changed = true
            IF related.possibilities is empty:
              RETURN false                   // Unsolvable
  RETURN true
END
```

**Complexity:**
- Time: O(n² × m²) per iteration (n=9, m=possibilities)
- Space: O(n²) for cell array
- Iterations: O(n²) in worst case

**Related Cells:** Cells in same:
- Row (8 other cells)
- Column (8 other cells)
- 3×3 subgrid (8 other cells)

**Example Trace:**

```
Initial:
Cell (0,0) = 5
Cell (0,1) possibilities: {1-9}

After constraint propagation:
Cell (0,1) possibilities: {1-4, 6-9}  (5 removed)
Cell (1,0) possibilities: {1-4, 6-9}  (5 removed)
Cell (1,1) possibilities: {1-4, 6-9}  (5 removed, row+col+subgrid)
```

### Backtracking Search Phase

**Function:** `_backtrackStep()` (private, recursive)

**Purpose:** Recursively assign values to empty cells with constraint checking.

**Algorithm:**

```
FUNCTION backtrackStep(position):
  // Find next empty cell
  IF position == 81:
    RETURN true                            // All cells filled

  IF cell[position].value != 0:            // Already filled
    RETURN backtrackStep(position + 1)     // Try next

  // Get values to try (ordered by LCV if enabled)
  valuesToTry = getValuesToTry(cell[position])

  FOR each value IN valuesToTry:
    // Try assigning this value
    cell[position].value = value
    incrementBacktrackingSteps()

    // Constraint propagation
    IF pruneCells():
      // Continue if valid
      IF backtrackStep(position + 1):
        RETURN true

    // Backtrack: restore state
    restoreStateFromStack()
    cell[position].value = 0

  RETURN false                             // No valid assignment
END
```

**Complexity:**
- Best case: O(n²) - Already solved
- Average case: O(9^k) - k ≈ empty cells, highly dependent on heuristics
- With MRV+FC: O(n²) for most puzzles

**Backtracking Count:**
- Each call to `_backtrackStep()` that tries a value increments counter
- Not counting the value that succeeds
- Shows how many dead ends were explored

### MRV Heuristic (Minimum Remaining Values)

**Purpose:** Choose the empty cell with fewest possible values to reduce branching.

**Implementation Location:** Cell selection in `_backtrackStep()`

**Algorithm:**

```
FUNCTION selectNextCell():
  minPossibilities = 10
  selectedCell = null

  FOR each empty cell:
    IF cell.possibilities.count < minPossibilities:
      minPossibilities = cell.possibilities.count
      selectedCell = cell

  RETURN selectedCell
END
```

**Optimization Note:** In current implementation, this searches from first empty cell in order. Production code should maintain sorted priority queue.

**Effectiveness:**
- Reduces branching factor ~30× on average puzzles
- 804× on evil puzzles when combined with forward checking
- Critical for solving difficult puzzles

**Example:**

```
Available cells:
- Cell A: 5 possibilities → Try this LAST
- Cell B: 3 possibilities → Try this SECOND
- Cell C: 1 possibility → Try this FIRST

MRV prioritizes: C → B → A
```

### LCV Heuristic (Least Constraining Value)

**Purpose:** Order value assignments to keep maximum options open for other cells.

**Implementation Location:** Value selection and ordering in `_backtrackStep()`

**Algorithm:**

```
FUNCTION orderValuesByLCV(cell):
  scoredValues = []

  FOR each possible value:
    constraintCount = 0
    FOR each related cell:
      IF value IN related.possibilities:
        constraintCount++

    scoredValues.add((value, constraintCount))

  SORT scoredValues by constraintCount (ascending)
  RETURN [values from scoredValues]
END
```

**Constraint Count:** How many other cells would lose this value as possibility.

**Effectiveness:**
- Values that eliminate fewer options are tried first
- Less effective alone, powerful with MRV
- ~37× improvement with forward checking

**Example:**

```
Cell possibilities: {1, 2, 3, 4, 5}

LCV scoring:
- Value 1: Eliminates 4 cells
- Value 2: Eliminates 2 cells  ← Try first
- Value 3: Eliminates 5 cells
- Value 4: Eliminates 2 cells  ← Try second
- Value 5: Eliminates 8 cells

LCV order: [2, 4, 1, 3, 5]
```

### Forward Checking

**Purpose:** After assigning a value, verify related cells still have valid options.

**Implementation Location:** After each assignment in `_backtrackStep()`

**Algorithm:**

```
FUNCTION checkForwardConstraints(cell, value):
  FOR each related cell:
    IF value IN related.possibilities:
      REMOVE value from related.possibilities

      IF related.possibilities is empty:
        RETURN false                      // Constraint violation

  RETURN true                             // All constraints satisfied
END
```

**Effect:** Detects infeasibility early, prunes search tree dramatically.

**Effectiveness:**
- Alone: ~2-3× improvement
- With MRV: 804× improvement
- Essential for difficult puzzles

**Example:**

```
Before assignment:
Cell A: {1, 2, 3}
Cell B: {2}

Assign value 2 to Cell X:
- Remove 2 from Cell A → {1, 3}
- Remove 2 from Cell B → {} ← INVALID!

Forward checking detects this immediately and backtracks.
```

---

## Data Structures

### Cell Possibilities Representation

**Type:** `List<int>` stored in each `_Cell`

**Representation:**
- List of integers 1-9
- Mutable during solving
- Updated by constraint propagation and heuristics

**Operations:**
- Add: `possibilities.add(value)`
- Remove: `possibilities.remove(value)`
- Check: `possibilities.contains(value)`
- Count: `possibilities.length`

**Memory:** 81 cells × ~40 bytes per list (average) ≈ 3.2 KB

### Operation History Stack

**Type:** `Stack<_OperationHistory>`

**Purpose:** Efficient state restoration during backtracking

**Structure:**
```dart
class _OperationHistory {
  int cellPosition;        // 0-80 (row * 9 + col)
  int possibilityCount;    // Before assignment
}
```

**Usage:** Pushed when value assigned, popped when backtracking.

**Space Complexity:** O(k) where k = max depth of recursion (≈ 40 for difficult puzzles)

### Grid Representation

**Type:** `List<List<_Cell>>` - 9×9 array

**Memory Layout:**
```
grid[row][col] where:
  - row: 0-8 (top to bottom)
  - col: 0-8 (left to right)
  - value: 0 (empty) or 1-9 (known)
```

**Subgrid Mapping:**
```
Subgrid position from row, col:
  subgrid = (row / 3) * 3 + (col / 3)

Example:
  (0, 0) → subgrid 0    (0, 3) → subgrid 1    (0, 6) → subgrid 2
  (3, 0) → subgrid 3    (3, 3) → subgrid 4    (3, 6) → subgrid 5
  (6, 0) → subgrid 6    (6, 3) → subgrid 7    (6, 6) → subgrid 8
```

---

## Class Relationships

### Dependency Graph

```
CLI Entry Point (Solve Engine.dart)
    ↓
    └─→ Grid (Puzzle.dart)
            ├─→ _Cell (internal)
            ├─→ _OperationHistory (internal)
            └─→ Stack<E> (Stack.dart)


Flutter Entry Point (main.dart)
    ├─→ MyApp
    ├─→ MyHomePage
    ├─→ SudokuBoard
    └─→ Grid (Puzzle.dart)
            ├─→ _Cell
            ├─→ _OperationHistory
            └─→ Stack<E>
```

### Encapsulation Levels

| Class | Visibility | Purpose | Dependencies |
|-------|-----------|---------|--------------|
| `Grid` | Public | Solver interface | `_Cell`, `Stack`, `_OperationHistory` |
| `_Cell` | Private | Cell state | None |
| `_OperationHistory` | Private | Backtracking state | None |
| `Stack<E>` | Public | Generic data structure | None |

---

## Implementation Guide

### Using the Solver

#### Minimal Example

```dart
import 'Puzzle.dart';

void main() {
  // Create solver
  final grid = Grid(
    useMrv: true,
    useForwardChecking: true,
  );

  // Load puzzle (9 rows)
  final puzzle = [
    [9, 0, 0, 0, 0, 0, 4, 0, 0],
    [0, 0, 0, 5, 0, 0, 0, 0, 0],
    [0, 0, 6, 0, 1, 7, 0, 0, 2],
    // ... 6 more rows
  ];

  for (var row in puzzle) {
    grid.loadLine(row);
  }

  // Solve
  if (grid.solveViaBacktracking()) {
    var solution = grid.getGridCellValues();
    var steps = grid.getBacktrackingStepCount();

    print("Solved in $steps steps");
    for (var row in solution) {
      print(row);
    }
  }
}
```

#### With Configuration Options

```dart
// Experiment with different heuristics
final configs = [
  Grid(),                                           // No heuristics
  Grid(useMrv: true),                              // MRV only
  Grid(useForwardChecking: true),                  // Forward checking only
  Grid(useMrv: true, useForwardChecking: true),   // Optimal
];

for (var grid in configs) {
  // Load puzzle...
  // Measure performance...
}
```

### Performance Measurement

```dart
import 'dart:io';

void benchmarkSolver(List<List<int>> puzzle, String name) {
  final grid = Grid(
    useMrv: true,
    useForwardChecking: true,
  );

  for (var row in puzzle) {
    grid.loadLine(row);
  }

  final stopwatch = Stopwatch()..start();
  final solved = grid.solveViaBacktracking();
  stopwatch.stop();

  if (solved) {
    final steps = grid.getBacktrackingStepCount();
    final timeMs = stopwatch.elapsedMilliseconds;

    print('$name: $steps steps in ${timeMs}ms');
  } else {
    print('$name: No solution');
  }
}
```

### Error Handling

```dart
// Invalid puzzle (unsolvable)
try {
  bool solved = grid.solveViaBacktracking();
  if (!solved) {
    print("Puzzle has no solution");
  }
} catch (e) {
  print("Error during solving: $e");
}

// Invalid input (must be called 9 times before solving)
// This will cause assertion error:
grid.loadLine([1, 2, 3, 4, 5, 6, 7, 8, 9]);  // Only 1 row
grid.solveViaBacktracking();                  // Error: puzzle incomplete
```

### Extending the Solver

#### Adding a New Heuristic

```dart
// Add parameter to Grid constructor
Grid({
  bool useNewHeuristic = false,
  // ... other params
})

// Store in private field
final bool _useNewHeuristic;

// Implement heuristic in _backtrackStep():
if (_useNewHeuristic) {
  // Custom logic to select next cell or order values
}
```

#### Custom Output Formatting

```dart
void printSolution(Grid grid) {
  var solution = grid.getGridCellValues();

  for (int i = 0; i < 9; i++) {
    if (i % 3 == 0 && i != 0) print("-------");

    String row = "";
    for (int j = 0; j < 9; j++) {
      if (j % 3 == 0 && j != 0) row += "| ";
      row += "${solution[i][j]} ";
    }
    print(row);
  }
}
```

---

## Performance Characteristics

### Time Complexity Analysis

| Phase | Complexity | Notes |
|-------|-----------|-------|
| Constraint Propagation (initial) | O(n⁴) | Fixed iterations, n=9 |
| Per backtracking step | O(n²) | Constraint propagation |
| Total backtracking | O(9^k) | k = empty cells, reduced by heuristics |

### Space Complexity Analysis

| Structure | Space | Notes |
|-----------|-------|-------|
| Grid cells | O(n²) | 81 cells, ~3KB total |
| Possibilities per cell | O(n) | Average ~4-5 values |
| Operation history stack | O(depth) | Typically < 50 for difficult puzzles |
| **Total** | **O(n²)** | ~10-20KB typical |

### Memory Usage Example

```
Evil puzzle solving:
- Cell values: 81 × 4 bytes = 324 bytes
- Possibility lists: 81 × 40 bytes = 3,240 bytes
- Stack operations: 50 × 8 bytes = 400 bytes
- Other overhead: ~500 bytes
─────────────────────────────────
Total: ~4.5 KB (minimal)
```

### Benchmark Results

Measured on standard evil difficulty puzzle:

```
Configuration                    | Steps | Time    | Relative
────────────────────────────────┼───────┼─────────┼──────────
No heuristics                    |120,552| 500ms   | 1.0x
MRV only                         | 3,777 | 50ms    | 10x
Forward checking only            |40,000 | 300ms   | 1.7x
MRV + Forward checking           |   149 | 5ms     | 100x
LCV + Forward checking           | 3,238 | 45ms    | 11x
────────────────────────────────┴───────┴─────────┴──────────
```

---

## Design Patterns

### Used Patterns

1. **Strategy Pattern** - Heuristic selection (MRV, LCV, Forward Checking)
2. **State Pattern** - Cell states during solving
3. **Command Pattern** - Operation history for backtracking
4. **Template Method** - Backtracking algorithm structure

### Architecture Patterns

1. **Layered Architecture** - Solver layer separate from UI layer
2. **Dependency Injection** - Heuristic flags passed to constructor
3. **Encapsulation** - Private internal classes (_Cell, _OperationHistory)

---

## Testing Strategy

### Unit Testing Checklist

```
□ Grid initialization with empty puzzle
□ Loading valid puzzle values (1-9)
□ Loading invalid values (0 or > 9)
□ Solving already-solved puzzle
□ Solving easy puzzle
□ Solving medium puzzle
□ Solving hard puzzle
□ Solving unsolvable puzzle
□ Heuristic comparison (MRV, LCV, FC)
□ Step counting accuracy
□ Grid solution validation (no duplicates)
```

### Test Puzzles

**Easy:** ~50 clues
```
[5, 3, 0, 0, 7, 0, 0, 0, 0],
[6, 0, 0, 1, 9, 5, 0, 0, 0],
...
```

**Medium:** ~30 clues

**Hard:** ~20 clues

**Evil:** ~15-17 clues

---

## Future Optimization Opportunities

1. **Cell Ordering** - Maintain sorted list of cells by possibility count
2. **Constraint Propagation** - Implement more sophisticated techniques (naked pairs, etc.)
3. **Parallelization** - Explore multiple branches concurrently
4. **Memoization** - Cache constraint propagation results
5. **Database** - Pre-computed solution patterns for fast lookup
6. **UI Responsiveness** - Async solving to prevent UI blocking

---

## References & Resources

- Sudoku Solving Algorithms: https://en.wikipedia.org/wiki/Sudoku_solving_algorithms
- Constraint Satisfaction: https://en.wikipedia.org/wiki/Constraint_satisfaction_problem
- Backtracking Algorithm: https://en.wikipedia.org/wiki/Backtracking
- Dart Language Guide: https://dart.dev/guides
- Flutter Documentation: https://docs.flutter.dev/

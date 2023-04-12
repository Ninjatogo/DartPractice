import 'Stack.dart';
import 'dart:io';
import 'package:tuple/tuple.dart';

/// Cell - This is the smallest object of the puzzle
/// Use this to store the current value and the list of possible values
class Cell {
  int _currentValue = 0;
  bool _mutable = false;
  List<int> _possibleValues = [];
  int _possibleValueSelection = -1;
  int _subGridMarker = -1;

  Cell(this._currentValue, this._subGridMarker, List<int> possibleValues) {
    if (this._currentValue == 0) {
      this._mutable = true;
      this._possibleValues = possibleValues.toList();
    }
  }

  int getValue() => this._currentValue;
  bool getMutability() => this._mutable;
  int getSubGridMarker() => this._subGridMarker;
  List<int> getPossibilities() => this._possibleValues;
  int getPossibilityCount() => this._possibleValues.length;
  void setPossibleValues(List<int> possibleValues) {
    this._possibleValues = possibleValues;
  }

  // Returns bool representing whether there are any possible moves left
  bool adjustValue() {
    bool movesLeft = false;

    if (!this._mutable) {
      return movesLeft;
    }

    if (this._possibleValues.length > 0 &&
        (this._possibleValueSelection + 1 < this._possibleValues.length)) {
      this._possibleValueSelection += 1;
      this._currentValue = this._possibleValues[this._possibleValueSelection];
      movesLeft = true;
    } else {
      this._possibleValueSelection = -1;
      this._currentValue = 0;
    }

    return movesLeft;
  }

  // Use strictly for initial possibility pruning
  bool removePossibility(int value) {
    if (this._possibleValues.length > 1) {
      this._possibleValues.remove(value);
    }
    if (this._possibleValues.length == 1 && this._mutable) {
      this._currentValue = this._possibleValues.first;
      this._mutable = false;

      return true;
    }

    return false;
  }
}

class OperationHistory {
  OperationHistory(this._cellRowPosition, this._cellColumnPosition,
      this._cellPossibilityCount);

  var _cellRowPosition = 0;
  var _cellColumnPosition = 0;
  var _cellPossibilityCount = 0;
}

/// Sudoku puzzle object - Use this to 2D array of cell objects
/// Uses 2D array to store objects for easy addressing when doing move checking
class Grid {
  var gridDiameter = 3;
  var emptyCellCount = 0;
  var backtrackingStepCount = 0;
  var useMrv = false;
  var useLcv = false;
  var useForwardChecking = false;
  List<List<Cell>> _gridCells = [];
  Stack<OperationHistory> _solvedCells = Stack<OperationHistory>();
  Stack<OperationHistory> _cellsToSolve = Stack<OperationHistory>();

  Grid(
      {this.gridDiameter = 3,
      this.useMrv = false,
      this.useLcv = false,
      this.useForwardChecking = false});

  void loadLine(List<int> input_cells) {
    List<Cell> cells = [];
    var row = 1;
    var possibleValues = [for (var i = 1; i < input_cells.length + 1; i++) i];

    if (_gridCells.length > 0 && (_gridCells.length ~/ gridDiameter) > 0) {
      row += (_gridCells.length ~/ gridDiameter);
    }

    for (var i = 0; i < input_cells.length; i++) {
      var column = 1;

      if (i > 0 && ((i) ~/ gridDiameter > 0)) {
        column += ((i) ~/ gridDiameter);
      }

      var subgridMarker = int.parse(row.toString() + column.toString());

      if (input_cells[i] == 0) {
        emptyCellCount++;
      }

      var cell = Cell(input_cells[i], subgridMarker, possibleValues);

      cells.add(cell);
    }

    _gridCells.add(cells);
  }

  void pruneCells() {
    var solvedCells = 0;
    do {
      solvedCells = pruneCellPossibilities();
    } while (solvedCells > 0);
  }

  int pruneCellPossibilities() {
    var solvedCells = 0;
    for (var row = 0; row < _gridCells.length; row++) {
      var rowValues = [];

      for (var column = 0; column < _gridCells[row].length; column++) {
        if (_gridCells[row][column].getMutability() == false) {
          rowValues.add(_gridCells[row][column].getValue());
        }
      }

      for (var column = 0; column < _gridCells[row].length; column++) {
        if (!_gridCells[row][column].getMutability()) {
          continue;
        }
        // Prune values in same row
        for (var i = 0; i < rowValues.length; i++) {
          if (column == i) {
            continue;
          }
          if (this._gridCells[row][column].removePossibility(rowValues[i])) {
            solvedCells++;
          }
        }

        // Prune values in same column
        for (var rowInner = 0; rowInner < _gridCells.length; rowInner++) {
          if (row == rowInner) {
            continue;
          }
          if (_gridCells[rowInner][column].getMutability() == false) {
            var cellValue = -1;
            cellValue = _gridCells[rowInner][column].getValue();
            if (this._gridCells[row][column].removePossibility(cellValue)) {
              solvedCells++;
            }
          }
        }

        // Prune values in same subgrid
        for (var rowInner = 0; rowInner < _gridCells.length; rowInner++) {
          var cellSolved = false;

          for (var columnInner = 0;
              columnInner < _gridCells[rowInner].length;
              columnInner++) {
            if (row == rowInner && column == columnInner) {
              continue;
            }

            if (_gridCells[rowInner][columnInner].getMutability() == false &&
                _gridCells[rowInner][columnInner].getSubGridMarker() ==
                    _gridCells[row][column].getSubGridMarker()) {
              var cellValue = _gridCells[rowInner][columnInner].getValue();
              if (this._gridCells[row][column].removePossibility(cellValue)) {
                solvedCells++;
              }

              if (_gridCells[row][column].getMutability() == false) {
                cellSolved = true;
                break;
              }
            }
          }

          if (cellSolved) {
            break;
          }
        }
      }
    }

    emptyCellCount -= solvedCells;
    return solvedCells;
  }

  // Record locations of all unsolved mutable cells in the grid
  void setupMutableCellStack() {
    List<OperationHistory> mutableCells = [];

    for (var row = 0; row < _gridCells.length; row++) {
      for (var column = 0; column < _gridCells[row].length; column++) {
        if (_gridCells[row][column].getMutability() &&
            _gridCells[row][column].getValue() == 0) {
          mutableCells.add(OperationHistory(
              row, column, _gridCells[row][column].getPossibilityCount()));
        }
      }
    }

    // Sort mutable cells by descending order of possibility count
    // This is to ensure that operation history stack can be used with MRV hueristic in backtracking
    if (useMrv) {
      mutableCells.sort(
          (a, b) => b._cellPossibilityCount.compareTo(a._cellPossibilityCount));
    }

    for (var cell in mutableCells) {
      _cellsToSolve.push(cell);
    }
  }

  void resetOperationHistoryStacks() {
    if (_solvedCells.isNotEmpty) {
      _solvedCells = new Stack<OperationHistory>();
    }
    if (_cellsToSolve.isNotEmpty) {
      _cellsToSolve = new Stack<OperationHistory>();
    }
  }

  // Returns true once puzzle is solved, false if puzzle is impossible to solve
  bool solveViaBacktracking() {
    var puzzleSolved = false;
    resetOperationHistoryStacks();

    setupMutableCellStack();

    puzzleSolved = backtrackStep();

    return puzzleSolved;
  }

  bool checkCellLegality(int row, int column, int cellValue) {
    // Check whether cell is legal in row
    for (int i = 0; i < _gridCells[row].length; i++) {
      if (i == column) {
        continue;
      }
      if (cellValue == _gridCells[row][i].getValue()) {
        return false;
      }
    }

    // Check whether cell is legal in column
    for (int j = 0; j < _gridCells.length; j++) {
      if (j == row) {
        continue;
      }
      if (cellValue == _gridCells[j][column].getValue()) {
        return false;
      }
    }

    // Check whether cell is legal in subgrid
    for (var rowInner = 0; rowInner < _gridCells.length; rowInner++) {
      for (var columnInner = 0;
          columnInner < _gridCells[rowInner].length;
          columnInner++) {
        if (row == rowInner && column == columnInner) {
          continue;
        }

        if (_gridCells[rowInner][columnInner].getSubGridMarker() ==
            _gridCells[row][column].getSubGridMarker()) {
          if (_gridCells[rowInner][columnInner].getValue() == cellValue) {
            return false;
          }
        }
      }
    }

    return true;
  }

  void lcvSortCellPossibilities(int row, int column) {
    var cellPossibilities = _gridCells[row][column].getPossibilities();
    List<Tuple2<int, int>> cellPossibilityScoreTuple = [];

    // For each possibility of selected cell
    for (var cellPossibility in cellPossibilities) {
      var cellPossibilityConstraintHits = 0;

      // Calculate LCV score for row-related cells
      for (var i = 0; i < _gridCells[row].length; i++) {
        if (i == column) {
          continue;
        }
        if (_gridCells[row][i]._mutable) {
          if (_gridCells[row][i].getSubGridMarker() ==
              _gridCells[row][column].getSubGridMarker()) {
            continue;
          }

          if (_gridCells[row][i].getPossibilities().contains(cellPossibility)) {
            cellPossibilityConstraintHits += 1;
          }
        }
      }

      // Calculate LCV score for column-related cells
      for (var j = 0; j < _gridCells.length; j++) {
        if (j == row) {
          continue;
        }
        if (_gridCells[j][column]._mutable) {
          if (_gridCells[j][column].getSubGridMarker() ==
              _gridCells[row][column].getSubGridMarker()) {
            continue;
          }

          if (_gridCells[j][column]
              .getPossibilities()
              .contains(cellPossibility)) {
            cellPossibilityConstraintHits += 1;
          }
        }
      }

      // Calculate LCV score for subgrid-related cells
      for (var rowInner = 0; rowInner < _gridCells.length; rowInner++) {
        for (var columnInner = 0;
            columnInner < _gridCells[rowInner].length;
            columnInner++) {
          if (row == rowInner && column == columnInner) {
            continue;
          }

          if (_gridCells[rowInner][columnInner]._mutable &&
              _gridCells[rowInner][columnInner].getSubGridMarker() ==
                  _gridCells[row][column].getSubGridMarker()) {
            if (_gridCells[rowInner][columnInner]
                .getPossibilities()
                .contains(cellPossibility)) {
              cellPossibilityConstraintHits += 1;
            }
          }
        }
      }

      cellPossibilityScoreTuple.add(
          Tuple2<int, int>(cellPossibility, cellPossibilityConstraintHits));
    }

    // Sort possibilities by ascending order of LCV score
    cellPossibilityScoreTuple.sort((a, b) => a.item2.compareTo(b.item2));

    List<int> sortedPossibilities = [];
    for (var cellPossibility in cellPossibilityScoreTuple) {
      sortedPossibilities.add(cellPossibility.item1);
    }

    // Store sorted list in cell
    _gridCells[row][column].setPossibleValues(sortedPossibilities);
  }

  bool forwardCheckLegalityCheck(int row, int column) {
    var targetCellPossibilities = _gridCells[row][column].getPossibilities();
    var legalMovesLeft = false;
    for (var possibility in targetCellPossibilities) {
      if (checkCellLegality(row, column, possibility) == true) {
        legalMovesLeft = true;
        break;
      }
    }
    return legalMovesLeft;
  }

  bool forwardCheckPossibilities(int row, int column) {
    // For each mutable cell related to the current cell
    // Check if they have any legal moves left at this point in the game
    // If any cell reports 0 moves left, then return false
    for (var i = 0; i < _gridCells[row].length; i++) {
      if (i == column) {
        continue;
      }
      if (_gridCells[row][i]._mutable && _gridCells[row][i].getValue() == 0) {
        if (_gridCells[row][i].getSubGridMarker() ==
            _gridCells[row][column].getSubGridMarker()) {
          continue;
        }

        var targetLegalMovesLeft = forwardCheckLegalityCheck(row, i);
        if (targetLegalMovesLeft == false) {
          return false;
        }
      }
    }

    for (var j = 0; j < _gridCells.length; j++) {
      if (j == row) {
        continue;
      }
      if (_gridCells[j][column]._mutable &&
          _gridCells[j][column].getValue() == 0) {
        if (_gridCells[j][column].getSubGridMarker() ==
            _gridCells[row][column].getSubGridMarker()) {
          continue;
        }

        var targetLegalMovesLeft = forwardCheckLegalityCheck(j, column);
        if (targetLegalMovesLeft == false) {
          return false;
        }
      }
    }

    for (var rowInner = 0; rowInner < _gridCells.length; rowInner++) {
      for (var columnInner = 0;
          columnInner < _gridCells[rowInner].length;
          columnInner++) {
        if (row == rowInner && column == columnInner) {
          continue;
        }

        if (_gridCells[rowInner][columnInner]._mutable &&
            _gridCells[rowInner][columnInner].getSubGridMarker() ==
                _gridCells[row][column].getSubGridMarker()) {
          var targetLegalMovesLeft =
              forwardCheckLegalityCheck(rowInner, columnInner);
          if (targetLegalMovesLeft == false) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // Returns true if move was successful, false if move failed
  bool backtrackStep() {
    if (_cellsToSolve.isEmpty) {
      return true;
    }
    backtrackingStepCount += 1;

    var moveSuccessful = false;
    var currentOperation = _cellsToSolve.pop();
    _solvedCells.push(currentOperation);

    // Adjust current cell possibilities via LCV score-based possibility sorting
    if (useLcv) {
      lcvSortCellPossibilities(currentOperation._cellRowPosition,
          currentOperation._cellColumnPosition);
    }

    var movesLeft = _gridCells[currentOperation._cellRowPosition]
            [currentOperation._cellColumnPosition]
        .adjustValue();

    while (movesLeft) {
      var cellValue = _gridCells[currentOperation._cellRowPosition]
              [currentOperation._cellColumnPosition]
          .getValue();

      if (checkCellLegality(currentOperation._cellRowPosition,
          currentOperation._cellColumnPosition, cellValue)) {
        var safeToStepForward = true;
        if (useForwardChecking) {
          safeToStepForward = forwardCheckPossibilities(
              currentOperation._cellRowPosition,
              currentOperation._cellColumnPosition);
        }

        if (safeToStepForward) {
          moveSuccessful = backtrackStep();
          if (moveSuccessful) {
            break;
          }
        }
      }

      movesLeft = _gridCells[currentOperation._cellRowPosition]
              [currentOperation._cellColumnPosition]
          .adjustValue();
    }

    if (moveSuccessful == false) {
      _cellsToSolve.push(_solvedCells.pop());
    }

    return moveSuccessful;
  }

  void printPuzzle() {
    for (var row = 0; row < _gridCells.length; row++) {
      for (var column = 0; column < _gridCells.length; column++) {
        stdout.write(_gridCells[row][column].getValue());
      }
      print('');
    }
  }

  int getRemainingCellsToSolveCount() => emptyCellCount;
  int getBacktrackingStepCount() => backtrackingStepCount;

  void resetPuzzle() {
    for (var row = 0; row < _gridCells.length; row++) {
      for (var column = 0; column < _gridCells[row].length; column++) {
        if (_gridCells[row][column]._mutable) {
          _gridCells[row][column]._currentValue = 0;
          _gridCells[row][column]._possibleValueSelection = -1;
        }
      }
    }

    backtrackingStepCount = 0;
  }
}

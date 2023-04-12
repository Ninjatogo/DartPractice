import 'Stack.dart';
import 'dart:io';

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
  var _gridDiameter = 3;
  var _emptyCellCount = 0;
  var _backtrackingStepCount = 0;
  List<List<Cell>> _gridCells = [];
  Stack<OperationHistory> _solvedCells = Stack<OperationHistory>();
  Stack<OperationHistory> _cellsToSolve = Stack<OperationHistory>();

  Grid(this._gridDiameter);

  void loadLine(List<int> input_cells) {
    List<Cell> cells = [];
    var row = 1;
    var possibleValues = [for (var i = 1; i < input_cells.length + 1; i++) i];

    if (_gridCells.length > 0 && (_gridCells.length ~/ _gridDiameter) > 0) {
      row += (_gridCells.length ~/ _gridDiameter);
    }

    for (var i = 0; i < input_cells.length; i++) {
      var column = 1;

      if (i > 0 && ((i) ~/ _gridDiameter > 0)) {
        column += ((i) ~/ _gridDiameter);
      }

      var subgridMarker = int.parse(row.toString() + column.toString());

      if (input_cells[i] == 0) {
        _emptyCellCount++;
      }

      var cell = Cell(input_cells[i], subgridMarker, possibleValues);

      cells.add(cell);
    }

    _gridCells.add(cells);
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

    _emptyCellCount -= solvedCells;
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
    mutableCells.sort(
        (a, b) => b._cellPossibilityCount.compareTo(a._cellPossibilityCount));

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

  bool checkCellLegality(int row, int column) {
    var cellValue = _gridCells[row][column].getValue();

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

  // Calculate LCV score for cell
  int calculateLcvScore(int row, int column) {
    var cellValue = _gridCells[row][column].getValue();

    return 0;
  }

  // Returns true if move was successful, false if move failed
  bool backtrackStep() {
    if (_cellsToSolve.isEmpty) {
      return true;
    }
    _backtrackingStepCount += 1;

    var moveSuccessful = false;
    var currentOperation = _cellsToSolve.pop();
    _solvedCells.push(currentOperation);

    var movesLeft = _gridCells[currentOperation._cellRowPosition]
            [currentOperation._cellColumnPosition]
        .adjustValue();

    while (movesLeft) {
      if (checkCellLegality(currentOperation._cellRowPosition,
          currentOperation._cellColumnPosition)) {
        moveSuccessful = backtrackStep();
        if (moveSuccessful) {
          break;
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

  int getRemainingCellsToSolveCount() => _emptyCellCount;
  int getBacktrackingStepCount() => _backtrackingStepCount;
}

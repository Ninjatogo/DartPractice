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
    if (_currentValue == 0) {
      _mutable = true;
      _possibleValues = possibleValues.toList();
    }
  }

  int getValue() => _currentValue;
  bool getMutability() => _mutable;
  int getSubGridMarker() => _subGridMarker;

  // Returns bool representing whether there are any possible moves left
  bool adjustValue() {
    bool movesLeft = false;

    if (!_mutable) {
      return movesLeft;
    }

    if (_possibleValues.isNotEmpty &&
        (_possibleValueSelection + 1 < _possibleValues.length)) {
      _possibleValueSelection += 1;
      _currentValue = _possibleValues[_possibleValueSelection];
      movesLeft = true;
    } else {
      _possibleValueSelection = -1;
      _currentValue = 0;
    }

    return movesLeft;
  }

  // Use strictly for initial possibility pruning
  bool removePossibility(int value) {
    if (_possibleValues.length > 1) {
      _possibleValues.remove(value);
    }
    if (_possibleValues.length == 1 && _mutable) {
      _currentValue = _possibleValues.first;
      _mutable = false;

      return true;
    }

    return false;
  }
}

class OperationHistory {
  OperationHistory(cellRowPosition, cellColumnPosition) {
    //
  }

  var cellRowPosition = 0;
  var cellColumnPosition = 0;
}

/// Sudoku puzzle object - Use this to 2D array of cell objects
/// Uses 2D array to store objects for easy addressing when doing move checking
class Grid {
  var _gridDiameter = 3;
  var _emptyCellCount = 0;
  List<List<Cell>> _gridCells = [];
  Stack<OperationHistory> _solvedCells = Stack<OperationHistory>();
  Stack<OperationHistory> _cellsToSolve = Stack<OperationHistory>();

  Grid(this._gridDiameter);

  void loadLine(List<int> inputCells) {
    List<Cell> cells = [];
    var row = 1;
    var possibleValues = [for (var i = 1; i < inputCells.length + 1; i++) i];

    if (_gridCells.isNotEmpty && (_gridCells.length ~/ _gridDiameter) > 0) {
      row += (_gridCells.length ~/ _gridDiameter);
    }

    for (var i = 0; i < inputCells.length; i++) {
      var column = 1;

      if (i > 0 && ((i) ~/ _gridDiameter > 0)) {
        column += ((i) ~/ _gridDiameter);
      }

      var subgridMarker = int.parse(row.toString() + column.toString());

      if (inputCells[i] == 0) {
        _emptyCellCount++;
      }

      var cell = Cell(inputCells[i], subgridMarker, possibleValues);

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
          if (_gridCells[row][column].removePossibility(rowValues[i])) {
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
            if (_gridCells[row][column].removePossibility(cellValue)) {
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
              if (_gridCells[row][column].removePossibility(cellValue)) {
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

  void resetOperationHistoryStacks() {
    if (_solvedCells.isNotEmpty) {
      _solvedCells = Stack<OperationHistory>();
    }
    if (_cellsToSolve.isNotEmpty) {
      _cellsToSolve = Stack<OperationHistory>();
    }
  }

  // Returns true once puzzle is solved, false if puzzle is impossible to solve
  bool solveViaBacktracking() {
    var puzzleSolved = false;
    resetOperationHistoryStacks();

    // Record locations of all unsolved mutable cells in the grid
    for (var row = 0; row < _gridCells.length; row++) {
      for (var column = 0; column < _gridCells[row].length; column++) {
        if (_gridCells[row][column].getMutability() &&
            _gridCells[row][column].getValue() == 0) {
          _cellsToSolve.push(OperationHistory(row, column));
        }
      }
    }

    puzzleSolved = backtrackStep();

    return puzzleSolved;
  }

  bool checkCellLagality(int row, int column) {
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

  // Returns true if move was successful, false if move failed
  bool backtrackStep() {
    if (_cellsToSolve.isEmpty) {
      return true;
    }

    var moveSuccessful = false;
    var currentOperation = _cellsToSolve.pop();
    _solvedCells.push(currentOperation);

    var movesLeft = _gridCells[currentOperation.cellRowPosition]
            [currentOperation.cellColumnPosition]
        .adjustValue();

    while (movesLeft) {
      if (checkCellLagality(currentOperation.cellRowPosition,
          currentOperation.cellColumnPosition)) {
        moveSuccessful = backtrackStep();
        if (moveSuccessful) {
          break;
        }
      }

      movesLeft = _gridCells[currentOperation.cellRowPosition]
              [currentOperation.cellColumnPosition]
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

  int getRemainingCellsToSolveCount() {
    return _emptyCellCount;
  }
}

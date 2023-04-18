import 'Stack.dart';
import 'dart:io';
import 'package:tuple/tuple.dart';

/// Cell - This is the smallest object of the puzzle
/// Use this to store the current value and the list of possible values
class _Cell {
  int _currentValue = 0;
  bool _mutable = false;
  List<int> _possibleValues = [];
  int _possibleValueSelection = -1;
  int _subGridMarker = -1;

  _Cell(this._currentValue, this._subGridMarker, List<int> possibleValues) {
    if (_currentValue == 0) {
      _mutable = true;
      _possibleValues = possibleValues.toList();
    }
  }

  int getValue() => _currentValue;
  void setValue(int value) {
    _currentValue = value;
  }

  bool getMutability() => _mutable;
  int getSubGridMarker() => _subGridMarker;
  List<int> getPossibilities() => _possibleValues;
  int getPossibilityCount() => _possibleValues.length;
  void setPossibleValues(List<int> possibleValues) {
    _possibleValues = possibleValues;
  }

  void resetMutableCell() {
    if (_mutable) {
      _currentValue = 0;
      _possibleValueSelection = -1;
    }
  }

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

class _OperationHistory {
  _OperationHistory(
      this.cellRowPosition, this.cellColumnPosition, this.cellPossibilityCount);

  var cellRowPosition = 0;
  var cellColumnPosition = 0;
  var cellPossibilityCount = 0;
}

/// Sudoku puzzle object - Use this to 2D array of cell objects
/// Uses 2D array to store objects for easy addressing when doing move checking
class Grid {
  var gridDiameter = 3;
  var _emptyCellCount = 0;
  var _backtrackingStepCount = 0;
  var useMrv = false;
  var useLcv = false;
  var useForwardChecking = false;
  var puzzlePruned = false;
  List<List<_Cell>> _gridCells = [];
  Stack<_OperationHistory> _solvedCells = Stack<_OperationHistory>();
  Stack<_OperationHistory> _cellsToSolve = Stack<_OperationHistory>();
  int getRemainingCellsToSolveCount() => _emptyCellCount;
  int getBacktrackingStepCount() => _backtrackingStepCount;
  List<List<int>> getGridCellValues() {
    List<List<int>> cellValues = [];

    for (var row = 0; row < _gridCells.length; row++) {
      List<int> rowValues = [];
      for (var column = 0; column < _gridCells[row].length; column++) {
        rowValues.add(_gridCells[row][column].getValue());
      }
      cellValues.add(rowValues);
    }

    return cellValues;
  }

  Grid(
      {this.gridDiameter = 3,
      this.useMrv = false,
      this.useLcv = false,
      this.useForwardChecking = false});

  void loadLine(List<int> inputCells) {
    List<_Cell> cells = [];
    var row = 1;
    var possibleValues = [for (var i = 1; i < inputCells.length + 1; i++) i];

    if (_gridCells.isNotEmpty && (_gridCells.length ~/ gridDiameter) > 0) {
      row += (_gridCells.length ~/ gridDiameter);
    }

    for (var i = 0; i < inputCells.length; i++) {
      var column = 1;

      if (i > 0 && ((i) ~/ gridDiameter > 0)) {
        column += ((i) ~/ gridDiameter);
      }

      var subgridMarker = int.parse(row.toString() + column.toString());

      if (inputCells[i] == 0) {
        _emptyCellCount++;
      }

      var cell = _Cell(inputCells[i], subgridMarker, possibleValues);

      cells.add(cell);
    }

    _gridCells.add(cells);
  }

  void _pruneCells() {
    if (puzzlePruned) {
      return;
    }

    var solvedCells = 0;
    do {
      solvedCells = _pruneCellPossibilities();
    } while (solvedCells > 0);
    puzzlePruned = true;
  }

  int _pruneCellPossibilities() {
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

        var outerCellSubGridMarker = _gridCells[row][column].getSubGridMarker();

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
                    outerCellSubGridMarker) {
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

  // Record locations of all unsolved mutable cells in the grid
  void _setupMutableCellStack() {
    List<_OperationHistory> mutableCells = [];

    for (var row = 0; row < _gridCells.length; row++) {
      for (var column = 0; column < _gridCells[row].length; column++) {
        if (_gridCells[row][column].getMutability() &&
            _gridCells[row][column].getValue() == 0) {
          mutableCells.add(_OperationHistory(
              row, column, _gridCells[row][column].getPossibilityCount()));
        }
      }
    }

    // Sort mutable cells by descending order of possibility count
    // This is to ensure that operation history stack can be used with MRV hueristic in backtracking
    if (useMrv) {
      mutableCells.sort(
          (a, b) => b.cellPossibilityCount.compareTo(a.cellPossibilityCount));
    }

    for (var cell in mutableCells) {
      _cellsToSolve.push(cell);
    }
  }

  void _resetOperationHistoryStacks() {
    if (_solvedCells.isNotEmpty) {
      _solvedCells = Stack<_OperationHistory>();
    }
    if (_cellsToSolve.isNotEmpty) {
      _cellsToSolve = Stack<_OperationHistory>();
    }
  }

  // Returns true once puzzle is solved, false if puzzle is impossible to solve
  bool solveViaBacktracking() {
    _pruneCells();

    resetPuzzle();

    var puzzleSolved = _backtrackStep();

    return puzzleSolved;
  }

  bool _checkCellLegality(int row, int column, int cellValue) {
    // Check whether cell is legal in row
    for (var i = 0; i < _gridCells[row].length; i++) {
      if (i == column) {
        continue;
      }
      if (cellValue == _gridCells[row][i].getValue()) {
        return false;
      }
    }

    // Check whether cell is legal in column
    for (var j = 0; j < _gridCells.length; j++) {
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

  void _lcvSortCellPossibilities(int row, int column) {
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
        if (_gridCells[row][i].getMutability()) {
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
        if (_gridCells[j][column].getMutability()) {
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

          if (_gridCells[rowInner][columnInner].getMutability() &&
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

  bool _forwardCheckLegalityCheck(int row, int column) {
    var targetCellPossibilities = _gridCells[row][column].getPossibilities();
    var legalMovesLeft = false;
    for (var possibility in targetCellPossibilities) {
      if (_checkCellLegality(row, column, possibility) == true) {
        legalMovesLeft = true;
        break;
      }
    }
    return legalMovesLeft;
  }

  bool _forwardCheckPossibilities(int row, int column) {
    // For each mutable cell related to the current cell
    // Check if they have any legal moves left at this point in the game
    // If any cell reports 0 moves left, then return false
    var outerCellSubGridMarker = _gridCells[row][column].getSubGridMarker();

    for (var i = 0; i < _gridCells[row].length; i++) {
      if (i == column) {
        continue;
      }
      if (_gridCells[row][i].getMutability() &&
          _gridCells[row][i].getValue() == 0) {
        if (_gridCells[row][i].getSubGridMarker() == outerCellSubGridMarker) {
          continue;
        }

        var targetLegalMovesLeft = _forwardCheckLegalityCheck(row, i);
        if (targetLegalMovesLeft == false) {
          return false;
        }
      }
    }

    for (var j = 0; j < _gridCells.length; j++) {
      if (j == row) {
        continue;
      }
      if (_gridCells[j][column].getMutability() &&
          _gridCells[j][column].getValue() == 0) {
        if (_gridCells[j][column].getSubGridMarker() ==
            outerCellSubGridMarker) {
          continue;
        }

        var targetLegalMovesLeft = _forwardCheckLegalityCheck(j, column);
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

        if (_gridCells[rowInner][columnInner].getMutability() &&
            _gridCells[rowInner][columnInner].getSubGridMarker() ==
                outerCellSubGridMarker) {
          var targetLegalMovesLeft =
              _forwardCheckLegalityCheck(rowInner, columnInner);
          if (targetLegalMovesLeft == false) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // Returns true if move was successful, false if move failed
  bool _backtrackStep() {
    if (_cellsToSolve.isEmpty) {
      return true;
    }
    _backtrackingStepCount += 1;

    var moveSuccessful = false;
    var currentOperation = _cellsToSolve.pop();
    _solvedCells.push(currentOperation);

    // Adjust current cell possibilities via LCV score-based possibility sorting
    if (useLcv) {
      _lcvSortCellPossibilities(currentOperation.cellRowPosition,
          currentOperation.cellColumnPosition);
    }

    var movesLeft = _gridCells[currentOperation.cellRowPosition]
            [currentOperation.cellColumnPosition]
        .adjustValue();

    while (movesLeft) {
      var cellValue = _gridCells[currentOperation.cellRowPosition]
              [currentOperation.cellColumnPosition]
          .getValue();

      if (_checkCellLegality(currentOperation.cellRowPosition,
          currentOperation.cellColumnPosition, cellValue)) {
        var safeToStepForward = true;
        if (useForwardChecking) {
          safeToStepForward = _forwardCheckPossibilities(
              currentOperation.cellRowPosition,
              currentOperation.cellColumnPosition);
        }

        if (safeToStepForward) {
          moveSuccessful = _backtrackStep();
          if (moveSuccessful) {
            break;
          }
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
    }
  }

  void resetPuzzle() {
    _resetOperationHistoryStacks();

    _setupMutableCellStack();

    for (var row = 0; row < _gridCells.length; row++) {
      for (var column = 0; column < _gridCells[row].length; column++) {
        _gridCells[row][column].resetMutableCell();
      }
    }

    _backtrackingStepCount = 0;
  }
}

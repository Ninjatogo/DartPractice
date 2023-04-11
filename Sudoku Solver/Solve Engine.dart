import 'Puzzle.dart';

/**
 * Evil difficulty puzzle
 * 9 0 0 0 0 0 4 0 0
 * 0 0 0 5 0 0 0 0 0
 * 0 0 6 0 1 7 0 0 2
 * 6 0 0 0 8 5 0 9 0
 * 0 0 5 2 0 0 0 0 0
 * 0 0 0 3 0 0 0 0 8
 * 0 0 0 0 3 0 0 0 0
 * 0 1 0 0 0 0 0 2 0
 * 0 0 7 0 6 8 0 0 1
 */

void main() {
  var puzzle = Grid(3);

  puzzle.loadLine([9, 0, 0, 0, 0, 0, 4, 0, 0]);
  puzzle.loadLine([0, 0, 0, 5, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 6, 0, 1, 7, 0, 0, 2]);
  puzzle.loadLine([6, 0, 0, 0, 8, 5, 0, 9, 0]);
  puzzle.loadLine([0, 0, 5, 2, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 0, 3, 0, 0, 0, 0, 8]);
  puzzle.loadLine([0, 0, 0, 0, 3, 0, 0, 0, 0]);
  puzzle.loadLine([0, 1, 0, 0, 0, 0, 0, 2, 0]);
  puzzle.loadLine([0, 0, 7, 0, 6, 8, 0, 0, 1]);

  //print('Cells to solve: ${puzzle.getRemainingCellsToSolveCount()}');
  var solvedCells = 0;
  do {
    solvedCells = puzzle.pruneCellPossibilities();
    //print('Cells to solve: ${puzzle.getRemainingCellsToSolveCount()}');
  } while (solvedCells > 0);

  puzzle.solveViaBacktracking();
  //print('Cells to solve: ${puzzle.getRemainingCellsToSolveCount()}');
  puzzle.printPuzzle();
}

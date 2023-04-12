import 'Puzzle.dart';
import 'dart:core';

/*
  Evil difficulty puzzle
  9 0 0 0 0 0 4 0 0
  0 0 0 5 0 0 0 0 0
  0 0 6 0 1 7 0 0 2
  6 0 0 0 8 5 0 9 0
  0 0 5 2 0 0 0 0 0
  0 0 0 3 0 0 0 0 8
  0 0 0 0 3 0 0 0 0
  0 1 0 0 0 0 0 2 0
  0 0 7 0 6 8 0 0 1

  puzzle.loadLine([9, 0, 0, 0, 0, 0, 4, 0, 0]);
  puzzle.loadLine([0, 0, 0, 5, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 6, 0, 1, 7, 0, 0, 2]);
  puzzle.loadLine([6, 0, 0, 0, 8, 5, 0, 9, 0]);
  puzzle.loadLine([0, 0, 5, 2, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 0, 3, 0, 0, 0, 0, 8]);
  puzzle.loadLine([0, 0, 0, 0, 3, 0, 0, 0, 0]);
  puzzle.loadLine([0, 1, 0, 0, 0, 0, 0, 2, 0]);
  puzzle.loadLine([0, 0, 7, 0, 6, 8, 0, 0, 1]);

  No heuristics: 120,552
  MRV: 3,777
  LCV: 18,595
  MRV+LCV: 50,768
  ForwardChecking: 14,689
  MRV+ForwardChecking: 149
  LCV+ForwardChecking: 3,238
  MRV+LCV+ForwardChecking: 875
 */

/*
  Hard difficulty puzzle
  0 1 0 0 8 9 2 0 0
  0 8 0 0 0 5 0 3 0
  0 9 0 0 0 0 0 7 0
  0 0 6 0 0 2 0 4 0
  0 0 5 4 0 0 7 0 0
  0 0 0 9 7 0 0 0 0
  0 0 0 0 0 0 0 0 0
  0 0 3 0 0 8 0 2 0
  0 5 0 0 0 4 0 0 1

  puzzle.loadLine([0, 1, 0, 0, 8, 9, 2, 0, 0]);
  puzzle.loadLine([0, 8, 0, 0, 0, 5, 0, 3, 0]);
  puzzle.loadLine([0, 9, 0, 0, 0, 0, 0, 7, 0]);
  puzzle.loadLine([0, 0, 6, 0, 0, 2, 0, 4, 0]);
  puzzle.loadLine([0, 0, 5, 4, 0, 0, 7, 0, 0]);
  puzzle.loadLine([0, 0, 0, 9, 7, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 0, 0, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 3, 0, 0, 8, 0, 2, 0]);
  puzzle.loadLine([0, 5, 0, 0, 0, 4, 0, 0, 1]);

  No heuristics: 1,560,403
  MRV: 33,554
  LCV: 4,793,228
  MRV+LCV: 721,062
  ForwardChecking: 86,271
  MRV+ForwardChecking: 1,769
  LCV+ForwardChecking: 575,803
  MRV+LCV+ForwardChecking: 28,461
*/

/*
  Hard difficulty puzzle
  0 7 0 0 9 0 0 6 0
  0 0 0 0 1 7 0 0 0
  9 0 0 2 0 0 0 8 0
  7 0 0 0 0 0 0 0 1
  0 2 0 1 0 4 0 0 3
  5 0 0 6 0 0 0 0 4
  0 0 3 9 0 0 0 0 6
  0 0 0 0 0 0 0 0 0
  2 0 0 4 0 0 0 5 0

  puzzle.loadLine([0, 7, 0, 0, 9, 0, 0, 6, 0]);
  puzzle.loadLine([0, 0, 0, 0, 1, 7, 0, 0, 0]);
  puzzle.loadLine([9, 0, 0, 2, 0, 0, 0, 8, 0]);
  puzzle.loadLine([7, 0, 0, 0, 0, 0, 0, 0, 1]);
  puzzle.loadLine([0, 2, 0, 1, 0, 4, 0, 0, 3]);
  puzzle.loadLine([5, 0, 0, 6, 0, 0, 0, 0, 4]);
  puzzle.loadLine([0, 0, 3, 9, 0, 0, 0, 0, 6]);
  puzzle.loadLine([0, 0, 0, 0, 0, 0, 0, 0, 0]);
  puzzle.loadLine([2, 0, 0, 4, 0, 0, 0, 5, 0]);

  No heuristics: 779,109
  MRV: 310,393
  LCV: 853,565
  MRV+LCV: 318,234
  ForwardChecking: 223,777
  MRV+ForwardChecking: 13,704
  LCV+ForwardChecking: 216,954
  MRV+LCV+ForwardChecking: 14,191
*/

/*
  Expert difficulty puzzle
  0 0 3 0 9 2 0 8 0
  4 0 0 0 0 0 0 6 0
  0 0 8 5 0 0 0 0 4
  0 5 0 0 2 3 4 0 6
  0 0 0 1 0 0 0 0 0
  0 9 0 0 0 0 0 0 0
  0 7 2 0 0 8 5 0 0
  0 0 0 0 3 0 0 0 7
  8 0 0 0 0 0 0 0 0

  puzzle.loadLine([0, 0, 3, 0, 9, 2, 0, 8, 0]);
  puzzle.loadLine([4, 0, 0, 0, 0, 0, 0, 6, 0]);
  puzzle.loadLine([0, 0, 8, 5, 0, 0, 0, 0, 4]);
  puzzle.loadLine([0, 5, 0, 0, 2, 3, 4, 0, 6]);
  puzzle.loadLine([0, 0, 0, 1, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 9, 0, 0, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 7, 2, 0, 0, 8, 5, 0, 0]);
  puzzle.loadLine([0, 0, 0, 0, 3, 0, 0, 0, 7]);
  puzzle.loadLine([8, 0, 0, 0, 0, 0, 0, 0, 0]);

  No heuristics: 1,907,713
  MRV: 20,154
  LCV: 1,312,414
  MRV+LCV: 29,087
  ForwardChecking: 247,792
  MRV+ForwardChecking: 2,499
  LCV+ForwardChecking: 161,605
  MRV+LCV+ForwardChecking: 4,005
*/

void main() {
  var puzzle = Grid(
      gridDiameter: 3, useMrv: true, useLcv: false, useForwardChecking: true);

  puzzle.loadLine([9, 0, 0, 0, 0, 0, 4, 0, 0]);
  puzzle.loadLine([0, 0, 0, 5, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 6, 0, 1, 7, 0, 0, 2]);
  puzzle.loadLine([6, 0, 0, 0, 8, 5, 0, 9, 0]);
  puzzle.loadLine([0, 0, 5, 2, 0, 0, 0, 0, 0]);
  puzzle.loadLine([0, 0, 0, 3, 0, 0, 0, 0, 8]);
  puzzle.loadLine([0, 0, 0, 0, 3, 0, 0, 0, 0]);
  puzzle.loadLine([0, 1, 0, 0, 0, 0, 0, 2, 0]);
  puzzle.loadLine([0, 0, 7, 0, 6, 8, 0, 0, 1]);

  puzzle.pruneCells();

  var puzzleSolved = false;

  var benchmarkIterations = 1;
  Stopwatch stopwatch = Stopwatch();

  // Warm up the function to make the benchmark more accurate
  puzzle.solveViaBacktracking();

  stopwatch.start();

  // Call the function you want to benchmark
  for (var i = 0; i < benchmarkIterations; i++) {
    puzzle.resetPuzzle();
    puzzleSolved = puzzle.solveViaBacktracking();
  }

  stopwatch.stop();

  // Print the elapsed time in milliseconds
  print('Elapsed time: ${stopwatch.elapsedMilliseconds} ms');

  //puzzle.printPuzzle();
  if (puzzleSolved) {
    print('Backtracking steps taken: ${puzzle.getBacktrackingStepCount()}');
  }
}

void stringInterpolation() {
  print("Strings can be interpolated using \${i} within a string");
}

void loopPractice() {
  while (true) {
    print("Printed from while loop");
    break;
  }

  for (int i = 0; i < 3; i++) {
    print("Printed from a for loop - ${i}");
  }
}

void main() {
  print("Hello world from Dart");
  stringInterpolation();
}

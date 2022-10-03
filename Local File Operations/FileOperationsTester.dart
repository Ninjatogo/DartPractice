import 'package:path/path.dart' as p;
import 'dart:io';

void main() {
  print("Program execution started at ${DateTime.now()}");
}

class FileOperator {
  // List directory where program is running from.
  Directory getCurrentDirectory() => Directory.current;
  // Organize files and directories based on the type
  void printOrganizedFiles(Directory directory) {
    var files = directory.list(recursive: false);

    for (var file in files.) {
      var name = file.name;
      }
  }

// Navigate up the directory tree
  // List files and directories, along with their contents.

// Create new directory and subdirectory

// Display current date and time
  // Display yesterdays date

// Compare dates to compute time difference
  // If date difference is greater than 1 week, return true

// Retrieve file metadata from directory listing

// Open file and read contents

// Create new file and save contents
}

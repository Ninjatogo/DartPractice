import 'package:path/path.dart' as p;
import 'dart:io';

void main() {
  var fileOperator = FileOperator();

  ///fileOperator
  //.printOrganizedDirectoryListing(fileOperator.getCurrentDirectory());
  //fileOperator.printParentDirectory(fileOperator.getCurrentDirectory());
  //fileOperator.createNewDirectory("testDirectory");
  //fileOperator.printCurrentDateAndTime();
  //fileOperator.printYesterdayDateAndTime();
}

class FileOperator {
  // List directory where program is running from.
  Directory getCurrentDirectory() => Directory.current;

  // Organize files and directories based on the type
  void printOrganizedDirectoryListing(Directory directory) async {
    var folders = List.empty(growable: true);
    var files = List.empty(growable: true);
    var symlinkedFiles = List.empty(growable: true);
    var directoryListing = directory.list(recursive: false);

    await for (var directoryEntry in directoryListing) {
      var entityType = await FileSystemEntity.type(directoryEntry.path);

      switch (entityType) {
        case FileSystemEntityType.directory:
          folders.add(directoryEntry.path);
          break;
        case FileSystemEntityType.file:
          files.add(directoryEntry.path);
          break;
        case FileSystemEntityType.link:
          symlinkedFiles.add(directoryEntry.path);
          break;
        default:
      }
    }

    folders.sort();
    files.sort();

    for (var folder in folders) {
      print(folder);
    }
    for (var file in files) {
      print(file);
    }
    for (var symlinkedFile in symlinkedFiles) {
      print(symlinkedFile);
    }
  }

  // Navigate up the directory tree
  void printParentDirectory(Directory directory) async {
    // Navigate up one directory
    var parentDir = Directory(getCurrentDirectory().path + '/..');
    printOrganizedDirectoryListing(parentDir);
  }

  // Create new directory
  void createNewDirectory(String directoryName) async {
    var newDirectory = Directory(directoryName);
    newDirectory.create();
  }

  // Display current date and time
  void printCurrentDateAndTime() async {
    print("Current date and time is ${DateTime.now()}");
  }

  // Display yesterdays date
  void printYesterdayDateAndTime() async {
    print(
        "Yesterday's date and time is ${DateTime.now().add(const Duration(days: -1))}");
  }

  // Compare dates to compute time difference
  // If date difference is greater than 1 week, return true

  // Retrieve file metadata from directory listing

  // Open file and read contents

  // Create new file and save contents
}

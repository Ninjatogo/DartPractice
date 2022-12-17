import 'package:path/path.dart' as path;
import 'dart:io';

void main() async {
  var fileOperator = FileOperator();

  ///fileOperator
  //.printOrganizedDirectoryListing(fileOperator.getCurrentDirectory());
  //fileOperator.printParentDirectory(fileOperator.getCurrentDirectory());
  //fileOperator.createNewDirectory("testDirectory");
  //var timeDifference = fileOperator.printDateDiff(
  //await fileOperator.printCurrentDateAndTime(),
  //await fileOperator.printYesterdayDateAndTime());
  //fileOperator.printGreaterThanOneWeek(await timeDifference);

  // Create new directory
  var newDirectory = await fileOperator.createNewDirectory('testDirectory');
  // Create new file, named KeepMe.txt inside of directory
  // Write "Hello World" inside of new file
  await fileOperator.writeFile(newDirectory, 'KeepMe.txt', ['Hello World']);
  // Create new file, named DeleteMe.txt inside of directory
  // Write "You shouldn't see this" inside of new file
  await fileOperator
      .writeFile(newDirectory, 'DeleteMe.txt', ['You shouldn' 't see this']);
  // Delete file labelled "DeleteMe.txt"
  await fileOperator.deleteFile(newDirectory, 'DeleteMe.txt');

  //fileOperator.writeFile(, contents)
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
  Future<Directory> createNewDirectory(String directoryName) async {
    var newDirectory = Directory(directoryName);
    return newDirectory.create();
  }

  // Display current date and time
  Future<DateTime> printCurrentDateAndTime() async {
    var todaysDate = DateTime.now();
    print("Current date and time is ${DateTime.now()}");
    return todaysDate;
  }

  // Display yesterdays date
  Future<DateTime> printYesterdayDateAndTime() async {
    var yesterdayDate = DateTime.now().add(const Duration(days: -1));
    print("Yesterday's date and time is ${yesterdayDate}");
    return yesterdayDate;
  }

  // Compare dates to compute time difference
  Future<Duration> printDateDiff(DateTime startDate, DateTime endDate) async {
    var difference = endDate.difference(startDate);
    print("Difference is ${difference}");
    return difference;
  }

  // If date difference is greater than 1 week, return true
  Future<bool> printGreaterThanOneWeek(Duration inDuration) async {
    if (inDuration.inDays >= 7) {
      print('One week!');

      return true;
    }
    print('Not one week');

    return false;
  }

  // Retrieve file metadata from directory listing
  Future<FileStat> getFileMetadata(Directory dir, String fileName) async {
    var targetFileName = path.join(dir.path, fileName);

    var file = File(targetFileName);

    return await file.stat();
  }

  // Open file and read contents and return as a list of strings
  Future<List<String>> readFile(Directory dir, String fileName) async {
    var targetFileName = path.join(dir.path, fileName);

    var file = File(targetFileName);

    return await file.readAsLines();
  }

  // Create new file and write list contents to it, in append mode
  void writeFile(Directory dir, String fileName, List<String> contents) async {
    var file = File(path.join(dir.path, fileName));

    var sink = file.openWrite(mode: FileMode.append);

    sink.writeAll(contents, "\n");

    await sink.close();
  }

  // Delete file
  void deleteFile(Directory dir, String fileName) async {
    var file = File(path.join(dir.path, fileName));

    if (await file.exists()) {
      await file.delete();
      print('File ${file} deleted!');
    } else {
      print('File ${file} does not exist');
    }
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FSService {
  /// Pick file
  /// pass allowedExtns array to add accepted file types
  /// pass allowedMultiple = true if you want to pick multiple files
  static Future<PickFileResp> pickFile([List<String> allowedExtns = const [], bool allowMultiple = false]) async {
    try {
      // Check if allowedExtns is empty
      FilePickerResult? result = allowedExtns.isEmpty
          ? await FilePicker.platform.pickFiles(allowMultiple: allowMultiple)
          : await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: allowedExtns,
              allowMultiple: allowMultiple,
            );
      if (result != null) {
        File file = File(result.files.single.path ?? '');
        return PickFileResp(file: file, status: true);
      } else {
        return PickFileResp(file: File('dummy_path'), status: false);
      }
    } catch (e) {
      return PickFileResp(file: File('dummy_path'), status: false);
    }
  }

  /// Pick a directory form filesystem
  static Future<PickDirResp> pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // User canceled the picker
        return PickDirResp(path: '', status: false, message: 'Picker cancelled');
      }
      return PickDirResp(path: selectedDirectory, status: true, message: 'Success');
    } catch (e) {
      return PickDirResp(path: '', status: false, message: e.toString());
    }
  }

  /// Read file contents
  /// Pass the file to be read a parameter
  static Future<ReadFileResp> readFileContents(File file) async {
    try {
      // Read the file
      final contents = await file.readAsString();
      return ReadFileResp(contents: contents, status: true);
    } catch (e) {
      // If encountering an error, return status = false
      return ReadFileResp(contents: '', status: false);
    }
  }

  /// Write contents to a file
  /// Pass the file to be written a parameter
  static Future<WriteFileResp> writeFileContents(File file, String text) async {
    // Write the file
    try {
      File writtenFile = await file.writeAsString(text);
      return WriteFileResp(file: writtenFile, status: true, message: 'Success');
    } catch (e) {
      return WriteFileResp(file: file, status: false, message: e.toString());
    }
  }

  static Future<SaveFileResp> saveStringToFile(String fileData, String filename) async {
    if (filename.isEmpty) {
      return SaveFileResp(file: File('dummy_path'), status: false, message: 'Empty file name');
    }
    String filePath = '/$filename';
    if (Platform.isIOS) {
      Directory docsDir = await getApplicationDocumentsDirectory();
      filePath = '${docsDir.path}$filePath';
    } else {
      PickDirResp dirResp = await pickDirectory();
      if (!dirResp.status) {
        return SaveFileResp(file: File('dummy_path'), status: false, message: dirResp.message);
      }
      filePath = '${dirResp.path}$filePath';
    }
    WriteFileResp writeFileResp = await writeFileContents(File(filePath), fileData);
    if (!writeFileResp.status) {
      return SaveFileResp(file: File('dummy_path'), status: false, message: writeFileResp.message);
    }
    return SaveFileResp(file: File(filePath), status: true, message: 'Success');
  }

  // static Future<SaveFileResp> saveFile(File file) async {
  //   PickDirResp dirResp = await pickDirectory();
  //   if (!dirResp.status) {
  //     return SaveFileResp(
  //       file: file,
  //       status: false,
  //       message: dirResp.message,
  //     );
  //   }
  //   await file.copy('${dirResp.path}/${file.uri.path}');
  // }
}

class PickFileResp {
  final bool status;
  final File file;
  PickFileResp({required this.file, required this.status});
}

class CreateFileResp {
  final bool status;
  final File file;
  CreateFileResp({required this.file, required this.status});
}

class PickDirResp {
  final bool status;
  final String path;
  final String message;
  PickDirResp({
    required this.path,
    required this.status,
    required this.message,
  });
}

class ReadFileResp {
  final String contents;
  final bool status;
  ReadFileResp({required this.contents, required this.status});
}

class WriteFileResp {
  final File file;
  final bool status;
  final String message;
  WriteFileResp({
    required this.file,
    required this.status,
    required this.message,
  });
}

class SaveFileResp {
  final File file;
  final bool status;
  final String message;
  SaveFileResp({
    required this.file,
    required this.status,
    required this.message,
  });
}

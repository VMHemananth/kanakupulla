// Stub for web where dart:io is not available.
// Provides minimal File and XFile classes so code that references them compiles on web.
// Runtime use should be guarded by `kIsWeb` checks; methods here throw when called on unsupported platforms.
import 'dart:async';
import 'dart:convert';

class File {
  final String _path;
  File(this._path);
  String get path => _path;
  Future<void> writeAsString(String contents, {Encoding encoding = utf8, bool flush = false}) async {
    throw UnsupportedError('File operations are not supported on web');
  }
}

class XFile {
  final String path;
  XFile(this.path);
}

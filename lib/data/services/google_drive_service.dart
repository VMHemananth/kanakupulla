import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as path;

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final httpClient = await _googleSignIn.authenticatedClient();
        if (httpClient != null) {
          _driveApi = drive.DriveApi(httpClient);
        }
      }
      return _currentUser;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
    _driveApi = null;
  }

  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;

  Future<void> uploadBackup(File file) async {
    if (_driveApi == null) await signIn();
    if (_driveApi == null) throw Exception('Not authenticated');

    final fileName = path.basename(file.path);
    
    // Check if file already exists in AppData
    final fileList = await _driveApi!.files.list(
      q: "name = '$fileName' and 'appDataFolder' in parents",
      spaces: 'appDataFolder',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Update existing
      final fileId = fileList.files!.first.id!;
      final driveFile = drive.File(); // Metadata updates if any
      
      await _driveApi!.files.update(
        driveFile,
        fileId,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );
    } else {
      // Create new
      final driveFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];

      await _driveApi!.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );
    }
  }

  Future<List<drive.File>> listBackups() async {
    if (_driveApi == null) await signIn();
    if (_driveApi == null) throw Exception('Not authenticated');

    final result = await _driveApi!.files.list(
      q: "'appDataFolder' in parents and trash = false",
      spaces: 'appDataFolder',
      orderBy: 'modifiedTime desc',
    );
    return result.files ?? [];
  }

  Future<File> downloadBackup(String fileId, String savePath) async {
    if (_driveApi == null) await signIn();
    if (_driveApi == null) throw Exception('Not authenticated');

    final drive.Media media = await _driveApi!.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final file = File(savePath);
    final sink = file.openWrite();
    await media.stream.pipe(sink);
    await sink.close();
    return file;
  }
}

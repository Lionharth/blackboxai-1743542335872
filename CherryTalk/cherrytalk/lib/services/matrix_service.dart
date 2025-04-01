import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MatrixService extends ChangeNotifier {
  Client? client;
  bool get isLoggedIn => client?.isLoggedIn ?? false;
  final _secureStorage = const FlutterSecureStorage();

  Future<void> initialize() async {
    try {
      client = Client(
        'CherryTalk',
        databaseBuilder: (client) => HiveCollectionsDatabase(client),
      );
      
      // Load existing credentials if available
      final credentials = await _loadCredentials();
      if (credentials != null) {
        await client?.checkHomeserver(credentials.homeserver.toString());
        await client?.restore(credentials);
      }
    } catch (e) {
      debugPrint('Matrix initialization error: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<Credentials?> _loadCredentials() async {
    try {
      final data = await _secureStorage.read(key: 'matrix_credentials');
      return data != null ? Credentials.fromJson(data) : null;
    } catch (e) {
      debugPrint('Error loading credentials: $e');
      return null;
    }
  }

  Future<void> _saveCredentials(Credentials credentials) async {
    await _secureStorage.write(
      key: 'matrix_credentials',
      value: credentials.toJson(),
    );
  }

  Future<void> login(String username, String password, String homeserver) async {
    try {
      await client?.checkHomeserver(homeserver);
      final credentials = await client?.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: username),
        password: password,
      );
      if (credentials != null) {
        await _saveCredentials(credentials);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await client?.logout();
    await _secureStorage.delete(key: 'matrix_credentials');
    notifyListeners();
  }

  Future<void> register(String username, String password, {String? email}) async {
    try {
      final response = await client?.register(
        username: username,
        password: password,
        initialDeviceDisplayName: 'CherryTalk Mobile',
      );
      if (response != null) {
        await _saveCredentials(response);
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
    notifyListeners();
  }

  Future<List<Room>> fetchChatRooms() async {
    if (client == null) throw Exception('Client not initialized');
    return client!.rooms.where((room) => room.isJoined).toList();
  }

  Future<void> sendMessage(String roomId, String message) async {
    try {
      final room = client?.getRoomById(roomId);
      if (room != null) {
        await room.sendTextEvent(message);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> sendFile(
    String roomId, 
    String filePath, 
    String fileName,
  ) async {
    try {
      final room = client?.getRoomById(roomId);
      if (room != null) {
        await room.sendFileEvent(
          filePath,
          name: fileName,
        );
      }
    } catch (e) {
      debugPrint('Error sending file: $e');
      rethrow;
    }
  }

  Future<void> sendImage(
    String roomId, 
    String filePath, 
    String fileName,
  ) async {
    try {
      final room = client?.getRoomById(roomId);
      if (room != null) {
        await room.sendImageEvent(
          filePath,
          name: fileName,
        );
      }
    } catch (e) {
      debugPrint('Error sending image: $e');
      rethrow;
    }
  }
}

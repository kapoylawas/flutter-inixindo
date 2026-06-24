import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inixindo_flutter/modules/login/models/loginResponseModel.dart';

class LoginDb {
  // Singleton instance
  static final LoginDb instance = LoginDb._init();
  static Database? _database;

  LoginDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('login_session.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Dinaikkan ke versi 4 untuk menyimpan semua field User
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS session');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tokens TEXT NOT NULL,
        userId INTEGER,
        documentId TEXT,
        username TEXT,
        email TEXT,
        provider TEXT,
        confirmed INTEGER,
        blocked INTEGER,
        nip TEXT,
        name TEXT,
        birthDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        publishedAt TEXT
      )
    ''');
  }

  // Menyimpan session login
  Future<void> saveSession(LoginResponseModel response) async {
    final db = await instance.database;

    // Hapus session lama terlebih dahulu agar hanya ada 1 session yang aktif
    await clearSession();

    await db.insert('session', {
      'tokens': response.jwt,
      'userId': response.user?.id,
      'documentId': response.user?.documentId,
      'username': response.user?.username,
      'email': response.user?.email,
      'provider': response.user?.provider,
      'confirmed': response.user?.confirmed == true ? 1 : 0,
      'blocked': response.user?.blocked == true ? 1 : 0,
      'nip': response.user?.nip,
      'name': response.user?.name,
      'birthDate': response.user?.birthDate,
      'createdAt': response.user?.createdAt,
      'updatedAt': response.user?.updatedAt,
      'publishedAt': response.user?.publishedAt,
    });
  }

  // Mengambil session login yang aktif
  Future<LoginResponseModel?> getSession() async {
    final db = await instance.database;
    final maps = await db.query('session', limit: 1);

    if (maps.isNotEmpty) {
      final sessionData = maps.first;
      return LoginResponseModel(
        jwt: sessionData['tokens'] as String?,
        user: User(
          id: sessionData['userId'] as int?,
          documentId: sessionData['documentId'] as String?,
          username: sessionData['username'] as String?,
          email: sessionData['email'] as String?,
          provider: sessionData['provider'] as String?,
          confirmed: sessionData['confirmed'] == 1,
          blocked: sessionData['blocked'] == 1,
          nip: sessionData['nip'] as String?,
          name: sessionData['name'] as String?,
          birthDate: sessionData['birthDate'] as String?,
          createdAt: sessionData['createdAt'] as String?,
          updatedAt: sessionData['updatedAt'] as String?,
          publishedAt: sessionData['publishedAt'] as String?,
        ),
      );
    }
    return null;
  }

  // Menghapus session (digunakan saat Logout)
  Future<void> clearSession() async {
    final db = await instance.database;
    await db.delete('session');
  }

  // Cek status apakah user sedang login atau tidak
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null && session.jwt != null;
  }

  // Menutup koneksi database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

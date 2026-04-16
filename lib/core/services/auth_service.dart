import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/constants/enums.dart';

class AuthService {
  final UserRepository _userRepo = UserRepository();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  static const _currentUserKey = 'current_user_id';

  // ── Google Sign-In ──────────────────────────────────────────────

  Future<UserModel?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    // Check if user already exists
    var user = await _userRepo.getByEmail(account.email);

    if (user == null) {
      user = UserModel(
        id: _uuid.v4(),
        username: account.email.split('@').first,
        displayName: account.displayName,
        email: account.email,
        avatarUrl: account.photoUrl,
        authMethod: AuthMethod.google,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _userRepo.insert(user);
    } else {
      user = user.copyWith(
        lastLoginAt: DateTime.now(),
        displayName: account.displayName,
        avatarUrl: account.photoUrl,
      );
      await _userRepo.update(user);
    }

    await _setCurrentUser(user.id);
    return user;
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _clearCurrentUser();
  }

  // ── Local Auth (Username + PIN/Pattern) ─────────────────────────

  Future<UserModel> createLocalUser({
    required String username,
    required String displayName,
    String? pin,
    String? pattern,
  }) async {
    final existing = await _userRepo.getByUsername(username);
    if (existing != null) {
      throw Exception('Username already exists');
    }

    final user = UserModel(
      id: _uuid.v4(),
      username: username,
      displayName: displayName,
      authMethod: AuthMethod.local,
      pinHash: pin != null ? _hashPin(pin) : null,
      patternHash: pattern != null ? _hashPattern(pattern) : null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await _userRepo.insert(user);
    await _setCurrentUser(user.id);
    return user;
  }

  Future<UserModel?> signInWithPin(String username, String pin) async {
    final user = await _userRepo.getByUsername(username);
    if (user == null) return null;

    if (user.pinHash != _hashPin(pin)) return null;

    final updated = user.copyWith(lastLoginAt: DateTime.now());
    await _userRepo.update(updated);
    await _setCurrentUser(updated.id);
    return updated;
  }

  Future<UserModel?> signInWithPattern(String username, String pattern) async {
    final user = await _userRepo.getByUsername(username);
    if (user == null) return null;

    if (user.patternHash != _hashPattern(pattern)) return null;

    final updated = user.copyWith(lastLoginAt: DateTime.now());
    await _userRepo.update(updated);
    await _setCurrentUser(updated.id);
    return updated;
  }

  Future<bool> verifyPin(String userId, String pin) async {
    final user = await _userRepo.getById(userId);
    return user?.pinHash == _hashPin(pin);
  }

  Future<bool> verifyPattern(String userId, String pattern) async {
    final user = await _userRepo.getById(userId);
    return user?.patternHash == _hashPattern(pattern);
  }

  // ── Session Management ──────────────────────────────────────────

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) return null;
    return await _userRepo.getById(userId);
  }

  Future<List<UserModel>> getAllUsers() async {
    return await _userRepo.getAllUsers();
  }

  Future<void> switchUser(String userId) async {
    await _setCurrentUser(userId);
  }

  Future<void> signOut() async {
    final user = await getCurrentUser();
    if (user?.authMethod == AuthMethod.google) {
      await _googleSignIn.signOut();
    }
    await _clearCurrentUser();
  }

  // ── Helpers ─────────────────────────────────────────────────────

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode('optracker_pin_$pin')).toString();
  }

  String _hashPattern(String pattern) {
    return sha256.convert(utf8.encode('optracker_pattern_$pattern')).toString();
  }

  Future<void> _setCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  Future<void> _clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}

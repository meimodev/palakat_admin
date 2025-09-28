
import 'dart:developer' as dev show log;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat_admin/core/models/auth_response.dart';
import 'package:palakat_admin/core/models/auth_tokens.dart';

/// Auth persistence service backed by Hive. Stores the full AuthResponse
/// (tokens + account) as JSON, enabling session restore and account caching.
class LocalStorageService {
  static const _kAuthBox = 'auth';
  static const _kAuthKey = 'auth.response';

  AuthResponse? _auth;

  // Consider presence of cached AuthResponse as logged-in state
  bool get isAuthenticated => _auth != null;
  String? get accessToken => _auth?.tokens.accessToken;
  String? get refreshToken => _auth?.tokens.refreshToken;
  DateTime? get expiresAt => _auth?.tokens.expiresAt;
  AuthResponse? get currentAuth => _auth;

  Future<void> init() async {
    await _ensureBoxOpen();
    dev.log('AuthService.init: loading cached auth from Hive', name: 'AuthService');
    _loadFromBox();
  }

  /// Synchronously load cached auth when Hive box is already open.
  /// Use this during app startup after Hive.openBox('auth') to avoid races.
  void loadFromCacheSync() {
    if (!Hive.isBoxOpen(_kAuthBox)) return;
    _loadFromBox();
  }

  Future<void> saveAuth(AuthResponse auth) async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _auth = auth;
    await box.put(_kAuthKey, auth.toJson());
    dev.log('AuthService.saveAuth: saved auth to Hive', name: 'AuthService');
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    if (_auth == null) return; // Refresh should only occur when authed
    final updated = _auth!.copyWith(tokens: tokens);
    await saveAuth(updated);
  }

  Future<void> clear() async {
    await _ensureBoxOpen();
    final box = Hive.box(_kAuthBox);
    _auth = null;
    await box.delete(_kAuthKey);
  }

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_kAuthBox);
    dev.log('LocalStorageService.initHive: Hive initialized and auth box opened', name: 'LocalStorageService');
  }

  Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_kAuthBox)) {
      await Hive.openBox(_kAuthBox);
    }
  }

  void _loadFromBox() {
    final box = Hive.box(_kAuthBox);
    final data = box.get(_kAuthKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _auth = AuthResponse.fromJson(normalized);
        dev.log('AuthService._loadFromBox: $_auth', name: 'AuthService');
      } catch (_) {
        _auth = null;
        dev.log('AuthService._loadFromBox: failed to parse cached auth, ignoring', name: 'AuthService');
      }
    }
  }

  dynamic _normalizeJson(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.toString()] = _normalizeJson(v);
      });
      return result;
    } else if (value is List) {
      return value.map(_normalizeJson).toList();
    }
    return value;
  }
}


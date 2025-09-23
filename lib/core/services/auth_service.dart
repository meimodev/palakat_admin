import 'package:hive_flutter/hive_flutter.dart';
import 'package:palakat_admin/core/models/auth_response.dart';
import 'package:palakat_admin/core/models/auth_tokens.dart';

/// Auth persistence service backed by Hive. Stores the full AuthResponse
/// (tokens + account) as JSON, enabling session restore and account caching.
class AuthService {
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
    // Assumes Hive.initFlutter() and box opening are handled in main().
    // If the box is not opened yet, open it here as a fallback.
    if (!Hive.isBoxOpen(_kAuthBox)) {
      await Hive.openBox(_kAuthBox);
    }
    final box = Hive.box(_kAuthBox);
    final data = box.get(_kAuthKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _auth = AuthResponse.fromJson(normalized);
      } catch (e, st) {
        _auth = null;
      }
    }
  }

  /// Synchronously load cached auth when Hive box is already open.
  /// Use this during app startup after Hive.openBox('auth') to avoid races.
  void loadFromCacheSync() {
    if (!Hive.isBoxOpen(_kAuthBox)) return;
    final box = Hive.box(_kAuthBox);
    final data = box.get(_kAuthKey);
    if (data is Map) {
      try {
        final normalized = _normalizeJson(data) as Map<String, dynamic>;
        _auth = AuthResponse.fromJson(normalized);
      } catch (e, st) {
        _auth = null;
      }
    }
  }

  /// Recursively convert dynamic Maps/Lists (e.g., LinkedMap<dynamic, dynamic>) into
  /// Map<String, dynamic> and List<dynamic> trees suitable for json_serializable.
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

  Future<void> saveAuth(AuthResponse auth) async {
    if (!Hive.isBoxOpen(_kAuthBox)) {
      await Hive.openBox(_kAuthBox);
    }
    final box = Hive.box(_kAuthBox);
    _auth = auth;
    await box.put(_kAuthKey, auth.toJson());
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    if (_auth == null) return; // Refresh should only occur when authed
    final updated = _auth!.copyWith(tokens: tokens);
    await saveAuth(updated);
  }

  Future<void> clear() async {
    if (!Hive.isBoxOpen(_kAuthBox)) {
      await Hive.openBox(_kAuthBox);
    }
    final box = Hive.box(_kAuthBox);
    _auth = null;
    await box.delete(_kAuthKey);
  }

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_kAuthBox);
  }
}

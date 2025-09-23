/// Centralized authentication endpoints for the API
///
/// These are relative paths appended to the configured API base URL.
/// If your backend uses different routes, update them here in one place.
class AuthEndpoints {
  const AuthEndpoints._();

  static const String signIn = '/auth/sign-in';
  static const String refresh = '/auth/refresh';
  static const String signOut = '/auth/sign-out';
}

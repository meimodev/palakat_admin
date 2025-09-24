/// Centralized API endpoint paths
/// Update these constants in one place to propagate across the app.
class Endpoints {

  static const String signIn = '/auth/sign-in';
  static const String refresh = '/auth/refresh';
  static const String signOut = '/auth/sign-out';

  static const String churches = '/church';
  static String church({required int churchId}) => '/church/$churchId';

  // Members
  static const String members = '/members';
  static String member(String memberId) => '/members/$memberId';

  // Activities
  static const String activities = '/activities';
  static String activity(String activityId) => '/activities/$activityId';

  // Approvals (rules, requests, etc.)
  static const String approvals = '/approvals';
  static String approval(String approvalId) => '/approvals/$approvalId';

  // Church sub-resources (columns and positions)
  static String churchColumns(String churchId) => '/church/$churchId/columns';
  static String churchColumn(String churchId, String columnId) =>
      '/church/$churchId/columns/$columnId';
  static String churchPositions(String churchId) => '/church/$churchId/positions';
  static String churchPosition(String churchId, String positionId) =>
      '/church/$churchId/positions/$positionId';

}

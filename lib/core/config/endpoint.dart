/// Centralized API endpoint paths
/// Update these constants in one place to propagate across the app.
class Endpoints {

  static const String signIn = '/auth/sign-in';
  static const String refresh = '/auth/refresh';
  static const String signOut = '/auth/sign-out';

  static const String churches = '/church';
  static String church({required int churchId}) => '/church/$churchId';

  // Location
  static String location({required int locationId}) => '/location/$locationId';

  // Column
  static String column({required int columnId}) => '/column/$columnId';
  static const String columns = '/column';

  // Account (Members)
  static const String accounts = '/account';
  static const String accountCount = '/account/count';
  static String account(int accountId) => '/account/$accountId';

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

  // Membership positions root (query by churchId)
  static const String membershipPositions = '/membership-position';
  static String membershipPosition({required int positionId}) => '/membership-position/$positionId';

}

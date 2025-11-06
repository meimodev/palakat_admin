
import 'package:palakat_admin/core/constants/enums.dart';
import 'package:palakat_admin/core/extension/account_extension.dart';
import 'package:palakat_admin/core/models/membership.dart';

extension XMembership on Membership {
  Bipra? get bipra {
    if (account == null) {
      return null;
    }

    return account!.calculateBipra;
  }
}

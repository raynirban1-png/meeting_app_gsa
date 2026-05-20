import 'member_model.dart';

class CurrentUserStore {

  static MemberModel?
  currentUser;

  static bool get isAdmin {

    return currentUser?.accessRole == "Admin";
  }
}
import 'package:gignow/model/user.dart';

class Global {
  static final Global _instance = Global._internal();

  factory Global() => _instance;

  Global._internal() {
    _userModel = UserModel.empty();
  }

  UserModel _userModel;

  UserModel get currentUserModel => _userModel;

  set currentUserModel(UserModel userModel) {
    _userModel = userModel;
  }
}

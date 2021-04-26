import 'package:gignow/model/user.dart';

class Global {
  static final Global _instance = Global._internal();

  factory Global() => _instance;

  Global._internal() {
    _userModel = UserModel.empty();
    previousSelection = 0;
  }

  UserModel _userModel;

  UserModel get currentUserModel => _userModel;

  set currentUserModel(UserModel userModel) {
    _userModel = userModel;
  }

  int prevSelection;

  int get previousSelection => prevSelection;

  set previousSelection(int selection) {
    prevSelection = selection;
  }
}

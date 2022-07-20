import 'package:unistapp/socialLogin.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class loginViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  User? user;

  loginViewModel(this._socialLogin);

  Future loginCheck() async{
    isLogined = await _socialLogin.loginCheck();
    if (isLogined) {
      user = await UserApi.instance.me();
      print("체크완료");
      print(user);
    }
  }

  Future login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      user = await UserApi.instance.me();
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    isLogined = false;
    user = null;
  }
}
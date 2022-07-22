import 'package:shared_preferences/shared_preferences.dart';
import 'package:unistapp/socialLogin.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class loginViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  User? user;
  String profileUrl = '';
  loginViewModel(this._socialLogin);

  void getProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    profileUrl = prefs.getString("profileUrl")!;
  }

  void setProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("profileUrl", profileUrl);
  }

  Future loginCheck() async{
    isLogined = await _socialLogin.loginCheck();
    if (isLogined) {
      user = await UserApi.instance.me();
      profileUrl = (user?.kakaoAccount?.profile?.profileImageUrl)!;
      setProfileUrl();
    }
  }

  Future login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      user = await UserApi.instance.me();
      profileUrl = (user?.kakaoAccount?.profile?.profileImageUrl)!;
      setProfileUrl();
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    isLogined = false;
    user = null;
    profileUrl = '';
    setProfileUrl();
  }
}
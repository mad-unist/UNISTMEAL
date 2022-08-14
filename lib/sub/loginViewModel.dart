import 'package:shared_preferences/shared_preferences.dart';
import 'package:unistapp/socialLogin.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class loginViewModel {
  final SocialLogin _socialLogin;
  bool isLogined = false;
  User? user;
  List<String> profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다'];
  loginViewModel(this._socialLogin);

  void getProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    profileUrl = prefs.getStringList("profileUrl")!;
  }

  void setProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("profileUrl", profileUrl);
  }

  Future loginCheck() async{
    isLogined = await _socialLogin.loginCheck();
    if (isLogined) {
      user = await UserApi.instance.me();
      profileUrl = [(user?.kakaoAccount?.profile?.profileImageUrl)!, (user?.kakaoAccount?.profile?.nickname)!, user?.kakaoAccount?.email ?? '이메일 정보가 없습니다'];
      setProfileUrl();
    }
  }

  Future login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      user = await UserApi.instance.me();
      print((user?.id)!);
      profileUrl = [(user?.kakaoAccount?.profile?.profileImageUrl)!, (user?.kakaoAccount?.profile?.nickname)!, user?.kakaoAccount?.email ?? '이메일 정보가 없습니다'];
      setProfileUrl();
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    isLogined = false;
    user = null;
    profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다'];
    setProfileUrl();
  }
}
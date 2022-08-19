import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unistapp/sub/loginViewModel.dart';
import 'package:unistapp/sub/tutorialPage.dart';

class SideBarApp extends StatefulWidget {
  final loginViewModel viewModel;
  const SideBarApp({Key? key, required this.viewModel}) : super(key: key);
  @override
  _SideBarAppState createState() => _SideBarAppState(viewModel);
}


class _SideBarAppState extends State<SideBarApp> {
  final loginViewModel viewModel;
  List<String> profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다'];
  int currentIndex = 0;
  _SideBarAppState(this.viewModel);

  void initState() {
    super.initState();
    getProfileUrl();
    _loginCheck();
  }

  _loginCheck() async{
    if (viewModel.user == null) {
      await viewModel.loginCheck();
      setState(() {});
    }
  }

  void getProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileUrl = prefs.getStringList("profileUrl")!;
    });
  }

  void setProfileUrl() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList("profileUrl", profileUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(viewModel.user?.kakaoAccount?.profile?.nickname ?? profileUrl[1]),
            accountEmail: Text(viewModel.user?.kakaoAccount?.email ?? profileUrl[2]),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? profileUrl[0],
                    placeholder: (context, url) => new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/sidebarpicture.png"),
              ),
            ),
          ),
          if (profileUrl[0] == '') IconButton(
              icon: Image.asset(
                "assets/images/kakao_login_large_wide.png",
                fit: BoxFit.cover,
              ),
              iconSize: 40,
              onPressed: () async{
                await viewModel.login();
                setState(() {
                  profileUrl = [(viewModel.user?.kakaoAccount?.profile?.profileImageUrl)!, (viewModel.user?.kakaoAccount?.profile?.nickname)!, viewModel.user?.kakaoAccount?.email ?? '이메일 정보가 없습니다'];
                  setProfileUrl();
                });
              },
            ) else ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: () async{
                await viewModel.logout();
                setState(() {
                  profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다'];
                  setProfileUrl();
                });
              },
            ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('앱 버전 정보'),
            onTap: () {
              Fluttertoast.showToast(
                  msg: "현재 버전: 2.0.0",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.redAccent,
                  textColor: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('개발자에게 문의하기'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.question_mark),
            title: Text('튜토리얼'),
            onTap: () {
              Navigator.pop(context, "Cancel");
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) => TutorialDialog(),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Policies'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Exit'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => null,
          ),
        ],
      ),
    );
  }

}
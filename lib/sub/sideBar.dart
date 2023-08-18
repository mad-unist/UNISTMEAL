import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:unistapp/sub/loginViewModel.dart';
import 'package:unistapp/sub/noticePage.dart';
import 'package:unistapp/sub/tutorialPage.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class SideBarApp extends StatefulWidget {
  final loginViewModel viewModel;
  final Function callbackFunction;
  const SideBarApp({Key? key, required this.viewModel, required this.callbackFunction}) : super(key: key);
  @override
  _SideBarAppState createState() => _SideBarAppState(viewModel, callbackFunction);
}


class _SideBarAppState extends State<SideBarApp> {
  final loginViewModel viewModel;
  final Function callbackFunction;
  List<String> profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다',''];
  int currentIndex = 0;
  _SideBarAppState(this.viewModel, this.callbackFunction);

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
      profileUrl = prefs.getStringList("profileUrl") ?? ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다',''];
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
                profileUrl = [(viewModel.user?.kakaoAccount?.profile?.profileImageUrl)!, (viewModel.user?.kakaoAccount?.profile?.nickname)!, viewModel.user?.kakaoAccount?.email ?? '이메일 정보가 없습니다', sha256.convert(utf8.encode((viewModel.user?.id)!.toString())).toString()];
                setProfileUrl();
                callbackFunction(true);
              });
            },
          ) else ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
            onTap: () async{
              await viewModel.logout();
              setState(() {
                profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다', ''];
                setProfileUrl();
                callbackFunction(false);
              });
            },
          ),
          if (profileUrl[0] == '' && Platform.isIOS) IconButton(
            padding: EdgeInsets.only(left: 18, right: 18),
            icon: SignInWithAppleButton(
              onPressed: () async{
                try {
                  final AuthorizationCredentialAppleID credential =
                  await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: "2JPD37VSBU.unistbab.wjddnwls7879.com",
                      redirectUri: Uri.parse(
                        "https://pear-kind-bubble.glitch.me/callbacks/sign_in_with_apple",
                      ),
                    ),
                  );

                  print('credential.state = $credential');
                  print('credential.state = ${credential.email}');
                  print('credential.state = ${credential.userIdentifier}');

                  setState(() {
                    profileUrl = ['apple', (credential.givenName)! , credential.email ?? '이메일 정보가 없습니다', sha256.convert(utf8.encode((credential.userIdentifier)!)).toString()];
                    setProfileUrl();
                    postApple(profileUrl[3], credential.email);
                    callbackFunction(true);
                  });
                } catch (error) {
                  print('error = $error');
                }
              },
            ),
            iconSize: 40,
            onPressed: () {

            },
          ) else if (profileUrl[0] != '' && Platform.isIOS) ListTile(
            leading: Icon(Icons.logout),
            title: Text('회원 탈퇴'),
            onTap: () async{
              Navigator.pop(context, "Cancel");
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("회원 탈퇴", textAlign: TextAlign.center,),
                      content: Text("지금까지 평가한 데이터가 모두 삭제됩니다.\n 정말 탈퇴하시겠습니까?", textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, color: Colors.redAccent)),
                      actions: [
                        MaterialButton(
                          child: Text('취소'),
                          minWidth: 0.5,
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                        MaterialButton(
                          child: Text('탈퇴'),
                          minWidth: 0.5,
                          onPressed: () async {
                            Navigator.pop(context, "Cancel");
                            await deleteApple(profileUrl[3]);
                            await viewModel.logout();
                            setState(() {
                              profileUrl = ['','카카오 로그인이 필요합니다','이메일 정보가 없습니다', ''];
                              setProfileUrl();
                              callbackFunction(false);
                            });
                          },
                        )
                      ],
                    );
                  }
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('앱 버전 정보'),
            onTap: () {
              Fluttertoast.showToast(
                  msg: "현재 버전: 2.0.2",
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
            onTap: () async {
              Navigator.pop(context, "Cancel");
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("개발자 문의", textAlign: TextAlign.center,),
                      content: Text("밥먹어U 카카오톡 채널로 연결됩니다.\n\n Developed by 정우진 박종서", textAlign: TextAlign.center, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035,)),
                      actions: [
                        MaterialButton(
                          child: Text('취소'),
                          minWidth: 0.5,
                          onPressed: () {
                            Navigator.pop(context, "Cancel");
                          },
                        ),
                        MaterialButton(
                          child: Text('확인'),
                          minWidth: 0.5,
                          onPressed: () async {
                            Navigator.pop(context, "Cancel");
                            Uri url = await TalkApi.instance.channelChatUrl('_xcaYlxj');
                            try {
                              await launchBrowserTab(url);
                            } catch (error) {
                              print("error");
                            }
                          },
                        )
                      ],
                    );
                  }
              );
            },
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
          ListTile(
            leading: Icon(Icons.description),
            title: Text('공지사항'),
            onTap: () {
              Navigator.pop(context, "Cancel");
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) => NoticeDialog(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
            onTap: () {
              Fluttertoast.showToast(
                  msg: "추후 업데이트 예정",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.redAccent,
                  textColor: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  Future<http.Response> postApple(userId, email) async{
    return await http.post(
      Uri.parse('https://unist-meal-backend.herokuapp.com/account/v1/users'),
      headers:{
        'Content-Type': "application/json",
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": userId,
        "email": email
      }),
    );
  }

  Future<http.Response> deleteApple(userId) async{
    return await http.post(
      Uri.parse('https://unist-meal-backend.herokuapp.com/account/v1/delete-user'),
      headers:{
        'Content-Type': "application/json",
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": userId,
      }),
    );
  }

}
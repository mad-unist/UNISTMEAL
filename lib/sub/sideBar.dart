import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unistapp/kakaoLogin.dart';
import 'package:unistapp/sub/loginViewModel.dart';

class SideBarApp extends StatefulWidget {
  const SideBarApp({Key? key}) : super(key: key);

  @override
  _SideBarAppState createState() => _SideBarAppState();
}


class _SideBarAppState extends State<SideBarApp> {
  final viewModel = loginViewModel(KakaoLogin());
  void initState() {
    super.initState();
    _loginCheck();
  }

  _loginCheck() async{
    if (viewModel.user == null) {
      await viewModel.loginCheck();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(viewModel.user?.kakaoAccount?.profile?.nickname ?? '카카오 로그인이 필요합니다.'),
            accountEmail: Text(viewModel.user?.kakaoAccount?.email ?? '이메일 정보가 없습니다.'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? '',
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
                  image: NetworkImage('https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')
              ),
            ),
          ),
          if (viewModel.user == null) IconButton(
              icon: Image.asset("assets/images/kakao_login_medium_narrow.png"),
              iconSize: 50,
              onPressed: () async{
                await viewModel.login();
                setState(() {});
              },
            ) else ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: () async{
                await viewModel.logout();
                setState(() {});
              },
            ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Request'),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unistapp/meal.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unistapp/sub/sideBar.dart';

class MealApp extends StatefulWidget {
  final List<Meal>? list;
  const MealApp({Key? key, this.list}) : super(key: key);

  @override
  _MealAppState createState() => _MealAppState(list);
}

class _MealAppState extends State<MealApp> with SingleTickerProviderStateMixin{
  TabController? controller;
  ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(1);
  PageController pagecontroller = PageController();
  final List<Meal>? list;
  List<String> goodList = [];
  List<String> badList = [];
  List<String> prefList = ["기숙사식당", "학생식당","교직원식당"];
  List<Meal>? sortList = [];
  List pageList = [];
  _MealAppState(this.list);

  void getGoodList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goodList = prefs.getStringList("goodList")!;
    });
  }
  void getBadList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      badList = prefs.getStringList("badList")!;
    });
  }
  void getPrefList() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefList = prefs.getStringList("prefList")!;
    });
  }
  void setPrefList(setList) async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList("prefList", setList);
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 1, length: 3, vsync: this);
    for (var i = 0; i < 9; i++) {
      var d = DateTime.now().add(Duration(days: i));
      pageList.add(d);
    }
    getGoodList();
    getBadList();
    getPrefList();
  }

  createAlertDialog(BuildContext context){
    List<String> tempList = [];
    bool _dormitory = false;
    bool _student = false;
    bool _employee = false;
    return showDialog(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("선호도 입력"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SwitchListTile(
                  title: Text("기숙사식당"),
                  value: _dormitory,
                  onChanged: (value) {
                    setState(() {
                      _dormitory = value;
                      if (_dormitory) {
                        tempList.add("기숙사식당");
                      } else {
                        tempList.remove("기숙사식당");
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text("학생식당"),
                  value: _student,
                  onChanged: (value) {
                    setState(() {
                      _student = value;
                      if (_student) {
                        tempList.add("학생식당");
                      } else {
                        tempList.remove("학생식당");
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: Text("교직원식당"),
                  value: _employee,
                  onChanged: (value) {
                    setState(() {
                      _employee = value;
                      if (_employee) {
                        tempList.add("교직원식당");
                      } else {
                        tempList.remove("교직원식당");
                      }
                    });
                  },
                ),
                tempList.isNotEmpty ?
                tempList.length == 1 ?
                Text('${tempList.join(",\n")}\n 만 표시됩니다.', softWrap: true, textAlign: TextAlign.center,)
                    :Text('${tempList.join(",\n")}\n 순으로 정렬됩니다.', softWrap: true, textAlign: TextAlign.center,)
                    : Text("정렬을 원하는 것만\n순서대로 선택해주세요.", softWrap: true, textAlign: TextAlign.center,)
              ],
            ),
            actions: [
              MaterialButton(
                child: Text('취소'),
                minWidth: 0.3,
                onPressed: () {
                  Navigator.pop(context, "Cancel");
                },
              ),
              MaterialButton(
                child: Text('확인'),
                minWidth: 0.3,
                onPressed: () {
                  Navigator.pop(context, "confirm");
                  if (tempList.isEmpty) {
                    tempList = ['기숙사식당', '교직원식당', '학생식당'];
                    Fluttertoast.showToast(
                        msg: "미선택으로 디폴트로 정렬됩니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.04
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "${tempList.join(", ")} 순 정렬완료",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.04
                    );
                  }
                  setPrefList(tempList);
                  getPrefList();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
        future: tillGetSource(
            Stream<double>.periodic(
                Duration(milliseconds: 100),
                    (x) => MediaQuery.of(context).size.height
            )
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Material(
              child: Scaffold(
                drawer: SideBarApp(),
                appBar: AppBar(
                  title: Text('유니스트 식단표'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        createAlertDialog(context);
                      },
                      child: FaIcon(
                          FontAwesomeIcons.rankingStar,
                          color: Theme.of(context).colorScheme.onPrimary
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                        child: PageView.builder(
                          controller: pagecontroller,
                          itemCount: pageList.length,
                          itemBuilder: (context, position) {
                            return exampleTabView(pageList[position].month, pageList[position].day, DateFormat.E('ko_KR').format(pageList[position]), context);
                          },
                          onPageChanged: (index){
                            setState(() {
                              _pageNotifier.value = index;
                            });
                          },
                        )
                    ),
                    SmoothPageIndicator(
                      controller: pagecontroller,
                      count:  9,
                      effect:  WormEffect(
                        dotHeight: 15,
                        dotWidth: 15,
                        spacing: 15,
                      ),
                      onDotClicked: (index){
                        setState(() {
                          _pageNotifier.value = index;
                          pagecontroller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
                        });
                      },
                    )
                  ],
                ),
              ),
            );
          } else {
            return Material(
              child: Scaffold(
                appBar: AppBar(
                  title: Text('유니스트 식단표'),
                  actions: [
                    TextButton(
                      onPressed: () {
                      createAlertDialog(context);
                      },
                      child: FaIcon(
                      FontAwesomeIcons.rankingStar,
                      color: Theme.of(context).colorScheme.onPrimary
                      ),
                    ),
                  ],
                ),
                body: Container(),
              ),
            );
          }
        }
    );
  }

  exampleTabView(month, day, koreanDay, context) {
    sortList = list?.where((element) => prefList.contains(element.place)).toList();
    sortList?.sort((a, b) => prefList.indexOf(a.place!).compareTo(prefList.indexOf(b.place!)));
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    double multiplier = 3;
    List<Meal>? newlist = sortList?.where((data) => data.month == month && data.day == day).toList();
    return Scaffold(
      body: Column(
        children: [
          Text('${month}월 ${day}일 (${koreanDay})', textAlign: TextAlign.center, style: TextStyle(fontSize: multiplier * unitHeightValue)),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: const [
                    Tab(text: '아침',),
                    Tab(text: '점심',),
                    Tab(text: '저녁',),
                  ],
                  controller: controller,
                ),
                toolbarHeight: 0,
              ),
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  exampleGridview(newlist?.where((data) => data.time == "아침").toList(), koreanDay, context),
                  exampleGridview(newlist?.where((data) => data.time == "점심").toList(), koreanDay, context),
                  exampleGridview(newlist?.where((data) => data.time == "저녁").toList(), koreanDay, context),
                ],
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<double> tillGetSource(Stream<double> source) async{
    await for (double value in source){
      if(value > 0)
        return value;
    }
    return await tillGetSource(source);
  }

  exampleGridview(List<Meal>? glist, koreanDay, context) {
    return Container(
      child: GridView.builder(
        primary: true,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          double uniWidthValue = MediaQuery.of(context).size.width * 0.01;
          double multiplier = 3.5;
          return Container(
            child: GestureDetector(
              onLongPress: () {
                createPopupMenu(context, glist?[position], koreanDay);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                ),
                color: goodList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.lightGreen[50] : badList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.pink[50] : Colors.lightBlue[50],
                child:  Stack(
                  children: <Widget>[
                    Container(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Text('  ${glist?[position].place}  ${glist?[position].type}', textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 4 * uniWidthValue,),),
                            Divider(
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                              color: goodList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.lightGreen : badList.any((element) => (glist?[position].content)!.contains(element)) ? Colors.pink : Colors.lightBlue,
                            )
                          ],
                        ),
                      ),
                      padding: EdgeInsets.only(top: 10, bottom: 5,),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text((glist?[position].content)!, textAlign: TextAlign.center, style: TextStyle(height: 1.5, fontSize: multiplier * uniWidthValue,),),
                      ),
                      padding: EdgeInsets.only(top: 5,),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text('${glist![position].calorie!}Kcal',  style: TextStyle(fontSize: multiplier * uniWidthValue,),),
                      ),
                      padding: EdgeInsets.only(bottom: 1.5 * uniWidthValue,),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: glist!.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 1.5, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 0.01 * MediaQuery.of(context).size.width, //수평 Padding
          crossAxisSpacing: 0.01 * MediaQuery.of(context).size.width, //수직 Padding
        ),
      ),
    );
  }

  kakaoShare(element, koreanDay) async{
    TextTemplate defaultText = TextTemplate(
      text:
      '${element.place} ${element.type} ${element.month}/${element.day} (${koreanDay})\n\n${element.content}',
      link: Link(
        androidExecutionParams: {'':''},
        iosExecutionParams: {'':''},
      ),
      buttonTitle: '앱으로 보기',
    );
    bool result = await ShareClient.instance.isKakaoTalkSharingAvailable();
    if (result) {
      Uri uri =
          await ShareClient.instance.shareDefault(template: defaultText);
      await ShareClient.instance.launchKakaoTalk(uri);
      print('카카오톡으로 공유 가능');
    } else {
      print('카카오톡 미설치: 웹 공유 기능 사용 권장');
      Fluttertoast.showToast(
          msg: "카카오톡이 설치되어있지 않습니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.width * 0.04
      );
    }
  }

  createPopupMenu(BuildContext context, element, koreanDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title:  Text("일일 식단표 행동 선택", textAlign: TextAlign.center,),
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('공유하기'),
              onTap: () {
                kakaoShare(element, koreanDay);
                Navigator.pop(context, "Cancel");
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('복사하기'),
              onTap: () {
                Clipboard.setData(ClipboardData(
                  text: '${element.place} ${element.type} ${element.month}/${element.day} (${koreanDay})\n\n${element.content}',
                ));
                Fluttertoast.showToast(
                    msg: "클립보드 복사완료",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.04
                );
                Navigator.pop(context, "Cancel");
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('평가하기'),
              onTap: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }

}
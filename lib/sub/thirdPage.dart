import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unistapp/restaurant.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:unistapp/sub/detailMenu.dart';

class RecommendationApp extends StatefulWidget {
  final List<Restaurant>? list;
  const RecommendationApp({Key? key, this.list}) : super(key: key);

  @override
  _RecommendationAppState createState() => _RecommendationAppState(list);
}

class _RecommendationAppState extends State<RecommendationApp> with SingleTickerProviderStateMixin {
  TabController? controller;
  final List<Restaurant>? list;
  _RecommendationAppState(this.list);
  List<Restaurant>? listSearch;
  final FocusNode _textFocusNode = FocusNode();
  TextEditingController? _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _textEditingController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textEditingController!.text.isNotEmpty
        ? listSearch
        : listSearch = List.from(list!);
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(20)),
            child: TextField(
              controller: _textEditingController,
              focusNode: _textFocusNode,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: '유니스트 맛집 검색',
                  contentPadding: EdgeInsets.all(8)),
              onChanged: (value) {
                setState(() {
                  listSearch = list?.where((element) => (element.name! + element.content! + element.place! + element.phone!).contains(value.toLowerCase())).toList();
                  if (_textEditingController!.text.isNotEmpty &&
                      listSearch!.length == 0) {
                    print('foodListSearch length ${listSearch!.length}');
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _textEditingController!.clear();
                setState(() {
                  _textEditingController!.text = '';
                });
              },
              child: Icon(
                Icons.close_sharp,
                color: Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: '홀',),
              Tab(text: '배달',),
            ],
            controller: controller,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            exampleListview(listSearch?.where((data) => data.type!.contains("홀")).toList()),
            exampleListview(listSearch?.where((data) => data.type!.contains("배달")).toList()),
          ],
          controller: controller,
        ),
      ),
    );
  }

  exampleListview(List <Restaurant>? restaurantList){
    return Container(
      child: ListView.builder(
        itemBuilder: (context, position) {
          MediaQueryData queryData = MediaQuery.of(context);
          double uniWidthValue = MediaQuery.of(context).size.width * 0.01;
          double multiplier = 4;
          return Container(
            height: 0.35 * queryData.size.width,
            child: Slidable(
              startActionPane: ActionPane(
                extentRatio: 0.25,
                motion: ScrollMotion(),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.025 * queryData.size.width, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        if ((restaurantList?[position].url)!.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> detailMenu(shopName: restaurantList![position])));
                        } else {
                          Fluttertoast.showToast(
                              msg: "메뉴 사진이 존재하지 않습니다.\n개발자 문의하기를 통해 사진을 제보해주세요.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.redAccent,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      },
                      child: Container(
                        width: queryData.size.width * 0.2,
                        height: 0.2 * queryData.size.width,
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.restaurant_menu, color: Colors.white,),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              endActionPane: ActionPane(
                extentRatio: 0.25,
                motion: ScrollMotion(),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.025 * queryData.size.width, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        FlutterPhoneDirectCaller.callNumber((restaurantList?[position].phone)!);
                      },
                      child: Container(
                        width: queryData.size.width * 0.2,
                        height: 0.2 * queryData.size.width,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.phone, color: Colors.white,),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.lightBlue[50],
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              child: Text((restaurantList?[position].name)!, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: multiplier * uniWidthValue,),),
                              padding: EdgeInsets.fromLTRB(0.1 * queryData.size.width, 0.02 * queryData.size.width, 0, 0),
                            ),
                            Spacer(),
                            Container(
                              child: Text((restaurantList?[position].place)!, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: multiplier * uniWidthValue,),),
                              padding: EdgeInsets.fromLTRB(0, 0.02 * queryData.size.width, 0.1 * queryData.size.width, 0),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                          color: Colors.lightBlue,
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            color: Colors.lightBlue,
                          ),
                          Text("  ${(restaurantList?[position].content)!}", textAlign: TextAlign.left, style: TextStyle(height: 1, fontSize: multiplier * uniWidthValue,),),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(0.05 * queryData.size.width, 0, 0, 0),
                    ),
                    Spacer(),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(
                          Icons.phone,
                          color: Colors.lightBlue,
                          ),
                          Text("  ${(restaurantList?[position].phone)!}", textAlign: TextAlign.left, style: TextStyle(height: 1, fontSize: multiplier * uniWidthValue,),),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(0.05 * queryData.size.width, 0, 0, 0),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.only(bottom: 0.03 * queryData.size.width,),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: restaurantList!.length,
      ),
    );
  }


}
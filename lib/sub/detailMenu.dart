import 'package:flutter/material.dart';
import '../restaurant.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class detailMenu extends StatefulWidget {
  final Restaurant shopName;
  const detailMenu({Key? key, required this.shopName}) : super(key: key);

  @override
  _detailMenuState createState() => _detailMenuState(shopName);
}

class _detailMenuState extends State<detailMenu> {
  final Restaurant shopName;
  _detailMenuState(this.shopName);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  List<String>? urlList = [];

  final imageList = [
    'assets/images/loading.gif',
    'assets/images/loading.png',
  ];

  void initState() {
    super.initState();
    urlList = shopName.url;
    print(urlList);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("메뉴 사진"),
      ),
      // add this body tag with container and photoview widget
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PhotoViewGallery.builder(
              itemCount: urlList?.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(
                    urlList![index],
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Theme.of(context).canvasColor,
              ),
              enableRotation: false,
              onPageChanged: onPageChanged,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.orange,
                    value: event == null
                        ? 0
                        : 0,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "${currentIndex + 1} / ${urlList?.length}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  decoration: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
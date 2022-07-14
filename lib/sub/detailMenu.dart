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

  final imageList = [
    'assets/images/loading.gif',
    'assets/images/loading.png',
  ];

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        child: PhotoViewGallery.builder(
          itemCount: imageList.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: AssetImage(
                imageList[index],
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
      ),
    );
  }
}
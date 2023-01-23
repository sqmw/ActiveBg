import 'package:flutter/material.dart';

/// 用来全屏展示图片，右上角有一个X用来关闭图片
class ImageView extends StatefulWidget {
  const ImageView({Key? key,required this.image}) : super(key: key);
  final Image image;
  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: widget.image,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
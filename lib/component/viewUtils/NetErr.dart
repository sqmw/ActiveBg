import 'package:flutter/cupertino.dart';

class NetErr extends StatelessWidget {
  const NetErr({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("404，请检查网络"),
    );
  }
}

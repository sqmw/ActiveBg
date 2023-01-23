import 'package:flutter/material.dart';
import '../../utils/NetUtil.dart' as net_util show isNetConnecting;
import './NetErr.dart';

class NetCheck extends StatelessWidget {
  final Widget child;
  const NetCheck({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: net_util.isNetConnecting(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.data){
            return child;
          }else{
            return const NetErr();
          }
        }else{
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

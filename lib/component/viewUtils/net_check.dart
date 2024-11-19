import 'package:active_bg/component/viewUtils/net_err.dart';
import 'package:flutter/material.dart';
import 'package:active_bg/utils/net_util.dart' as net_util show isNetConnecting;

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

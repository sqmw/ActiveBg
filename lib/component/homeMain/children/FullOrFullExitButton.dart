import 'package:flutter/material.dart';


class FullOrFullExitButton extends StatefulWidget {
  const FullOrFullExitButton({Key? key}) : super(key: key);

  @override
  State<FullOrFullExitButton> createState() => _FullOrFullExitButtonState();
}

class _FullOrFullExitButtonState extends State<FullOrFullExitButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        setState(() {
          // Win32Util.setFullScreenOrOutFullScreen();
        });
      },
      icon: true ? const Icon(Icons.fullscreen_exit): const Icon(Icons.fullscreen),
    );
  }
}

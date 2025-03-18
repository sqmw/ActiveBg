import 'package:flutter/material.dart';

class TimerWallpaper extends StatefulWidget {
  const TimerWallpaper({Key? key}) : super(key: key);

  @override
  State<TimerWallpaper> createState() => _TimerWallpaperState();
}

class _TimerWallpaperState extends State<TimerWallpaper> {
  bool _isEnabled = false;
  int _interval = 30; // 默认30分钟

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 开关
          SwitchListTile(
            title: const Text('启用定时切换'),
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
          ),
          // 间隔设置
          ListTile(
            title: const Text('切换间隔'),
            subtitle: Slider(
              value: _interval.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '$_interval 分钟',
              onChanged: _isEnabled ? (value) {
                setState(() {
                  _interval = value.round();
                });
              } : null,
            ),
          ),
        ],
      ),
    );
  }
}

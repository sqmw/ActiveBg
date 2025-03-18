import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoStart = false;
  bool _minimizeToTray = true;
  final String _selectedLanguage = '简体中文';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('基本设置', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('开机自启'),
            subtitle: const Text('启动系统时自动运行程序'),
            value: _autoStart,
            onChanged: (bool value) {
              setState(() {
                _autoStart = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('最小化到托盘'),
            subtitle: const Text('关闭窗口时最小化到系统托盘'),
            value: _minimizeToTray,
            onChanged: (bool value) {
              setState(() {
                _minimizeToTray = value;
              });
            },
          ),
          ListTile(
            title: const Text('语言'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 实现语言选择
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('关于', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            title: Text('版本'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('检查更新'),
            onTap: () {
              // TODO: 实现检查更新
            },
          ),
        ],
      ),
    );
  }
} 
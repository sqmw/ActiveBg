import 'package:flutter/material.dart';

class LinkParser extends StatefulWidget {
  const LinkParser({Key? key}) : super(key: key);

  @override
  State<LinkParser> createState() => _LinkParserState();
}

class _LinkParserState extends State<LinkParser> {
  final TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _linkController,
            decoration: InputDecoration(
              hintText: '输入壁纸链接...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () {
                  // TODO: 实现粘贴功能
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现解析功能
            },
            child: const Text('解析链接'),
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Text('解析结果将显示在这里'),
            ),
          ),
        ],
      ),
    );
  }
}

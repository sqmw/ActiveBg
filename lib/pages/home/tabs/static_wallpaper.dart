import 'package:flutter/material.dart';

class StaticWallpaper extends StatefulWidget {
  const StaticWallpaper({Key? key}) : super(key: key);

  @override
  State<StaticWallpaper> createState() => _StaticWallpaperState();
}

class _StaticWallpaperState extends State<StaticWallpaper> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 搜索栏
          TextField(
            decoration: InputDecoration(
              hintText: '搜索壁纸...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 壁纸网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 16/9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return Card(
                  child: Stack(
                    children: [
                      Center(
                        child: Text('壁纸 ${index + 1}'),
                      ),
                    ],
                  ),
                );
              },
              itemCount: 12,
            ),
          ),
        ],
      ),
    );
  }
}

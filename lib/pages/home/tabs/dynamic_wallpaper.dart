import 'package:flutter/material.dart';

class DynamicWallpaper extends StatefulWidget {
  const DynamicWallpaper({Key? key}) : super(key: key);

  @override
  State<DynamicWallpaper> createState() => _DynamicWallpaperState();
}

class _DynamicWallpaperState extends State<DynamicWallpaper> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 搜索栏
          TextField(
            decoration: InputDecoration(
              hintText: '搜索动态壁纸...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 动态壁纸网格
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
                        child: Text('动态壁纸 ${index + 1}'),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
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

import 'package:flutter/material.dart';

class PalettePage extends StatefulWidget {
  const PalettePage({Key? key}) : super(key: key);

  @override
  State<PalettePage> createState() => _PalettePageState();
}

class _PalettePageState extends State<PalettePage> {
  double _opacity = 1.0;
  Color _selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调色板'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('透明度调节', style: TextStyle(fontSize: 16)),
            Slider(
              value: _opacity,
              onChanged: (value) {
                setState(() {
                  _opacity = value;
                });
              },
              min: 0.0,
              max: 1.0,
            ),
            const SizedBox(height: 20),
            const Text('颜色选择', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.yellow,
                Colors.orange,
              ].map((color) => _buildColorButton(color)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}

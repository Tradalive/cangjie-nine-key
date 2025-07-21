import 'package:flutter/material.dart';

/// Mapping of nine keys to their corresponding Cangjie radicals (字根)
const Map<String, List<String>> nineKeyRadicalMap = {
  'A': const ['一', '丨', '丶'],
  'B': const ['口', '日', '月'],
  'C': const ['木', '水', '火'],
  'D': const ['人', '心', '手'],
  'E': const ['土', '山', '田'],
  'F': const ['金', '竹', '弓'],
  'G': const ['大', '中', '小'],
  'H': const ['女', '子', '身'],
  'I': const ['示', '衣', '門'],
};

class NineKeyKeyboard extends StatelessWidget {
  final void Function(int) onKeyPressed;

  const NineKeyKeyboard({Key? key, required this.onKeyPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smaller of width or height for the keyboard size
        double size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        double spacing = 8.0;
        double totalSpacing = spacing * 2; // 3 columns: 2 spaces
        double keySize = (size - totalSpacing) / 3;
        return Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              children: List.generate(9, (index) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: ElevatedButton(
                    onPressed: () => onKeyPressed(index),
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 24)),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
} 
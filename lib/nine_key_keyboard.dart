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
    // Key labels and secondary labels for 4x4 grid
    final List<Map<String, String>> keys = [
      {'main': '1', 'sub': ''},
      {'main': '2', 'sub': 'ABC'},
      {'main': '3', 'sub': 'DEF'},
      {'main': '⌫', 'sub': ''}, // Backspace
      {'main': '4', 'sub': 'GHI'},
      {'main': '5', 'sub': 'JKL'},
      {'main': '6', 'sub': 'MNO'},
      {'main': '重輸', 'sub': ''}, // Clear
      {'main': '7', 'sub': 'PQRS'},
      {'main': '8', 'sub': 'TUV'},
      {'main': '9', 'sub': 'WXYZ'},
      {'main': '空格', 'sub': ''}, // Space bar
      {'main': '123', 'sub': ''}, // Number flag
      {'main': '0', 'sub': ''},
      {'main': '↵', 'sub': ''}, // Enter
      {'main': '', 'sub': ''}, // Placeholder for symmetry
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonHeight = constraints.maxHeight / 4;
        double buttonWidth = constraints.maxWidth / 4;
        double mainFontSize = buttonHeight * 0.32;
        double subFontSize = buttonHeight * 0.16;
        return Column(
          children: List.generate(4, (row) {
            return Expanded(
              child: Row(
                children: List.generate(4, (col) {
                  int index = row * 4 + col;
                  final key = keys[index];
                  bool isBackspace = key['main'] == '⌫';
                  bool isClear = key['main'] == '重輸';
                  bool isSpace = key['main'] == '空格';
                  bool isEnter = key['main'] == '↵';
                  bool isNumberFlag = key['main'] == '123';
                  bool isPlaceholder = key['main'] == '' && key['sub'] == '';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: isPlaceholder
                          ? const SizedBox.shrink()
                          : Semantics(
                              label: isBackspace
                                  ? 'Backspace'
                                  : isClear
                                      ? 'Clear'
                                      : isSpace
                                          ? 'Space'
                                          : isEnter
                                              ? 'Enter'
                                              : isNumberFlag
                                                  ? 'Number flag'
                                                  : 'Key ${key['main']}',
                              button: true,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  if (isBackspace) {
                                    onKeyPressed(-1); // Backspace
                                  } else if (isClear) {
                                    onKeyPressed(-2); // Clear
                                  } else if (isSpace) {
                                    onKeyPressed(-3); // Space
                                  } else if (isEnter) {
                                    onKeyPressed(-4); // Enter
                                  } else if (isNumberFlag) {
                                    onKeyPressed(-5); // Number flag
                                  } else {
                                    onKeyPressed(index);
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      key['main']!,
                                      style: TextStyle(
                                        fontSize: mainFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (key['sub']!.isNotEmpty)
                                      Text(
                                        key['sub']!,
                                        style: TextStyle(
                                          fontSize: subFontSize,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
} 
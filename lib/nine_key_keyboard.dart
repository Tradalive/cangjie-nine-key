import 'package:flutter/material.dart';
import 'main.dart' show KeyboardMode;

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
  final KeyboardMode keyboardMode;
  final VoidCallback? onToggleMode;
  final VoidCallback? onExit;

  const NineKeyKeyboard({Key? key, required this.onKeyPressed, required this.keyboardMode, this.onToggleMode, this.onExit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> cangjieNumbers = ['一','口','木','水','火','土','竹','戈','十','大'];
    final List<String> enLetters = ['A','B','C','D','E','F','G','H','I','J'];
    final List<String> digits = ['1','2','3','4','5','6','7','8','9','0'];
    final List<String> modeLabels = ['中', 'EN', '123'];
    late final List<String> mainLabels;
    switch (keyboardMode) {
      case KeyboardMode.cangjie:
        mainLabels = cangjieNumbers;
        break;
      case KeyboardMode.en:
        mainLabels = enLetters;
        break;
      case KeyboardMode.digit:
        mainLabels = digits;
        break;
    }

    // 4x4 grid: 0-2,3; 4-6,7; 8-10,11; 12-14,15
    final List<Map<String, dynamic>> keys = [
      {'main': mainLabels[0]},
      {'main': mainLabels[1]},
      {'main': mainLabels[2]},
      {'main': '⌫'},
      {'main': mainLabels[3]},
      {'main': mainLabels[4]},
      {'main': mainLabels[5]},
      {'main': '重輸'},
      {'main': mainLabels[6]},
      {'main': mainLabels[7]},
      {'main': mainLabels[8]},
      {'main': '空格'},
      // Left bottom: mode button
      {'main': modeLabels[keyboardMode.index]},
      {'main': mainLabels[9]},
      {'main': '標點'},
      {'main': '↵'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonHeight = constraints.maxHeight / 4;
        double buttonWidth = constraints.maxWidth / 4;
        double mainFontSize = buttonHeight * 0.32;
        return Column(
          children: [
            ...List.generate(4, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(4, (col) {
                    int index = row * 4 + col;
                    final key = keys[index];
                    bool isBackspace = key['main'] == '⌫';
                    bool isClear = key['main'] == '重輸';
                    bool isSpace = key['main'] == '空格';
                    bool isEnter = key['main'] == '↵';
                    bool isModeButton = (row == 3 && col == 0);
                    bool isPunctuation = key['main'] == '標點';
                    bool isPlaceholder = key['main'] == '';
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
                                                : isModeButton
                                                    ? 'Mode'
                                                    : isPunctuation
                                                        ? 'Punctuation'
                                                        : 'Key ${key['main']}',
                                button: true,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (index == 3 || index == 7 || index == 11 || index == 12 || index == 14 || index == 15)
                                        ? Colors.blue
                                        : Colors.white,
                                    foregroundColor: (index == 3 || index == 7 || index == 11 || index == 12 || index == 14 || index == 15)
                                        ? Colors.white
                                        : Colors.black87,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    if (isModeButton && onToggleMode != null) {
                                      onToggleMode!();
                                    } else if (isBackspace) {
                                      onKeyPressed(-1); // Backspace
                                    } else if (isClear) {
                                      onKeyPressed(-2); // Clear
                                    } else if (isSpace) {
                                      onKeyPressed(-3); // Space
                                    } else if (isEnter) {
                                      onKeyPressed(-4); // Enter
                                    } else if (isPunctuation) {
                                      onKeyPressed(-6); // Punctuation
                                    } else {
                                      onKeyPressed(index);
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      key['main']!,
                                      style: TextStyle(
                                        fontSize: mainFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        );
      },
    );
  }
} 
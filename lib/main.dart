import 'package:flutter/material.dart';
import 'nine_key_keyboard.dart';
import 'cangjie_dictionary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum KeyboardMode { cangjie, en, digit }

class _MyHomePageState extends State<MyHomePage> {
  int? _lastKeyPressed;
  // Input buffer for storing the sequence of key presses (as key codes A-I)
  final List<String> _inputBuffer = [];
  List<String> _candidates = [];
  String _committedText = '';
  KeyboardMode _keyboardMode = KeyboardMode.cangjie;

  // Map index (0-9) to key code (A-Y)
  static const List<String> cangjieCodes = ['A','B','C','D','E','F','G','H','I','J'];
  static const List<String> enCodes = ['A','B','C','D','E','F','G','H','I','J'];
  static const List<String> digitCodes = ['1','2','3','4','5','6','7','8','9','0'];
  static const List<String> punctuationKeys = ['，', '。', '！', '？', '、', '；', '：', '「', '」', '（', '）', '…', '—', '《', '》', '．'];

  static const List<String> punctuationCandidates = ['，', '。', '！', '？', '、', '；', '：', '「', '」', '（', '）', '…', '—', '《', '》', '．'];

  // Map index in keyboard layout to code/letter/digit
  static const List<int> mainKeyIndices = [0, 1, 2, 4, 5, 6, 8, 9, 10, 13];

  void _toggleMode() {
    setState(() {
      _keyboardMode = KeyboardMode.values[(_keyboardMode.index + 1) % KeyboardMode.values.length];
    });
  }

  void _handleKeyPressed(int index) async {
    setState(() {
      // Special keys
      if (index == -1) {
        switch (_keyboardMode) {
          case KeyboardMode.cangjie:
            if (_inputBuffer.isNotEmpty) {
              _inputBuffer.removeLast();
              final code = _inputBuffer.join();
              _candidates = cangjieDictionary[code] ?? [];
            }
            break;
          case KeyboardMode.en:
          case KeyboardMode.digit:
            if (_committedText.isNotEmpty) {
              _committedText = _committedText.substring(0, _committedText.length - 1);
            }
            break;
        }
        return;
      } else if (index == -2) {
        // Clear (重輸)
        switch (_keyboardMode) {
          case KeyboardMode.cangjie:
            _inputBuffer.clear();
            _candidates = [];
            break;
          case KeyboardMode.en:
          case KeyboardMode.digit:
            _committedText = '';
            break;
        }
        return;
      } else if (index == -3) {
        // Space
        _committedText += ' ';
        return;
      } else if (index == -4) {
        // Enter
        _committedText += '\n';
        return;
      } else if (index == -6) {
        // Show punctuation candidates in the unified candidate view
        _inputBuffer.clear();
        _candidates = punctuationCandidates;
        return;
      }

      // Map UI index to logical key index (0-9)
      int logicalKeyIndex = mainKeyIndices.indexOf(index);
      if (logicalKeyIndex == -1) return; // Not a main key

      switch (_keyboardMode) {
        case KeyboardMode.cangjie:
          if (logicalKeyIndex >= 0 && logicalKeyIndex < cangjieCodes.length) {
            _inputBuffer.add(cangjieCodes[logicalKeyIndex]);
            final code = _inputBuffer.join();
            _candidates = cangjieDictionary[code] ?? [];
          }
          break;
        case KeyboardMode.en:
          if (logicalKeyIndex >= 0 && logicalKeyIndex < enCodes.length) {
            _committedText += enCodes[logicalKeyIndex];
          }
          break;
        case KeyboardMode.digit:
          if (logicalKeyIndex >= 0 && logicalKeyIndex < digitCodes.length) {
            _committedText += digitCodes[logicalKeyIndex];
          }
          break;
      }
    });
  }

  void _handleCandidateSelected(String candidate) {
    setState(() {
      _committedText += candidate;
      _inputBuffer.clear();
      _candidates = [];
    });
  }

  void _showPunctuationDialog() async {
    final List<String> punctuations = ['，', '。', '！', '？', '、', '；', '：', '「', '」', '（', '）'];
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('選擇標點'),
        children: punctuations.map((p) => SimpleDialogOption(
          child: Text(p, style: const TextStyle(fontSize: 24)),
          onPressed: () => Navigator.pop(context, p),
        )).toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _committedText += selected;
      });
    }
  }

  void _handleBackspace() {
    setState(() {
      if (_inputBuffer.isNotEmpty) {
        _inputBuffer.removeLast();
        final code = _inputBuffer.join();
        _candidates = cangjieDictionary[code] ?? [];
      }
    });
  }

  void _handleClear() {
    setState(() {
      _inputBuffer.clear();
      _candidates = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Removed Hello World
            // const Text('Hello World', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 16),
            Text('已輸入: $_committedText', style: const TextStyle(fontSize: 20, color: Colors.black)),
            const SizedBox(height: 8),
            if (_keyboardMode == KeyboardMode.cangjie)
              Text('Input buffer:  ${_inputBuffer.join(" ")}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            _candidates.isNotEmpty
                ? SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _candidates.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 1,
                          side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                        ),
                        onPressed: () => _handleCandidateSelected(_candidates[idx]),
                        child: Text(_candidates[idx], style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  )
                : const Text('Candidates: (none)', style: TextStyle(fontSize: 18, color: Colors.blue)),
            if (_keyboardMode == KeyboardMode.digit)
              const Text('數字輸入模式', style: TextStyle(fontSize: 18, color: Colors.blue)),
            if (_keyboardMode == KeyboardMode.en)
              const Text('英文輸入模式', style: TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 360, // Ensures keyboard has a non-zero height
                child: NineKeyKeyboard(
                  onKeyPressed: _handleKeyPressed,
                  keyboardMode: _keyboardMode,
                  onToggleMode: _toggleMode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

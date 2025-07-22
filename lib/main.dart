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

class _MyHomePageState extends State<MyHomePage> {
  int? _lastKeyPressed;
  // Input buffer for storing the sequence of key presses (as key codes A-I)
  final List<String> _inputBuffer = [];
  List<String> _candidates = [];
  String _committedText = '';
  bool _numberMode = false;
  bool _punctuationMode = false;

  // Map index (0-8) to key code (A-I)
  static const List<String> keyCodes = ['A','B','C','D','E','F','G','H','I'];
  static const List<String> numberKeys = ['1','2','3','4','5','6','7','8','9','0'];
  static const List<String> punctuationKeys = ['，', '。', '！', '？', '、', '；', '：', '「', '」', '（', '）', '…', '—', '《', '》', '．'];

  void _handleKeyPressed(int index) async {
    setState(() {
      if (_punctuationMode) {
        // In punctuation mode, commit punctuation directly
        if (index >= 0 && index < punctuationKeys.length) {
          _committedText += punctuationKeys[index];
        } else if (index == -6) {
          // Toggle back to normal mode
          _punctuationMode = false;
        } else if (index == -7) {
          // Back button
          _punctuationMode = false;
        } else if (index == -1) {
          // Backspace
          if (_committedText.isNotEmpty) {
            _committedText = _committedText.substring(0, _committedText.length - 1);
          }
        } else if (index == -3) {
          _committedText += ' ';
        } else if (index == -4) {
          _committedText += '\n';
        } else if (index == -5) {
          _numberMode = true;
          _punctuationMode = false;
        }
        return;
      }
      if (_numberMode) {
        // In number mode, commit numbers directly
        if (index >= 0 && index < 10) {
          _committedText += numberKeys[index];
        } else if (index == -5) {
          // Toggle back to normal mode
          _numberMode = false;
        } else if (index == -1) {
          // Backspace
          if (_committedText.isNotEmpty) {
            _committedText = _committedText.substring(0, _committedText.length - 1);
          }
        } else if (index == -3) {
          _committedText += ' ';
        } else if (index == -4) {
          _committedText += '\n';
        } else if (index == -6) {
          _punctuationMode = true;
          _numberMode = false;
        }
        return;
      }
      if (index == -1) {
        // Backspace
        if (_inputBuffer.isNotEmpty) {
          _inputBuffer.removeLast();
          final code = _inputBuffer.join();
          _candidates = cangjieDictionary[code] ?? [];
        }
      } else if (index == -2) {
        // Clear (重輸)
        _inputBuffer.clear();
        _candidates = [];
      } else if (index == -3) {
        // Space
        _committedText += ' ';
      } else if (index == -4) {
        // Enter
        _committedText += '\n';
      } else if (index == -5) {
        // Number flag: switch to number mode
        _numberMode = true;
        _punctuationMode = false;
      } else if (index == -6) {
        // Punctuation: switch to punctuation mode
        _punctuationMode = true;
        _numberMode = false;
      } else {
        // Add key code to buffer (for 0-8, mapping to A-I)
        if (index >= 0 && index < keyCodes.length) {
          _lastKeyPressed = index + 1;
          _inputBuffer.add(keyCodes[index]);
          final code = _inputBuffer.join();
          _candidates = cangjieDictionary[code] ?? [];
        }
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
            if (!_numberMode && !_punctuationMode)
              Text('Input buffer:  ${_inputBuffer.join(" ")}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (!_numberMode && !_punctuationMode)
              _candidates.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      children: _candidates.map((c) => ElevatedButton(
                        onPressed: () => _handleCandidateSelected(c),
                        child: Text(c, style: const TextStyle(fontSize: 20)),
                      )).toList(),
                    )
                  : const Text('Candidates: (none)', style: TextStyle(fontSize: 18, color: Colors.blue)),
            if (_numberMode)
              const Text('數字輸入模式', style: TextStyle(fontSize: 18, color: Colors.blue)),
            if (_punctuationMode)
              const Text('標點輸入模式', style: TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 360, // Ensures keyboard has a non-zero height
                child: NineKeyKeyboard(
                  onKeyPressed: _handleKeyPressed,
                  numberMode: _numberMode,
                  punctuationMode: _punctuationMode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'nine_key_keyboard.dart';
import 'cangjie_dictionary.dart';
import 'fake_freq.dart';
import 'fake_freq.dart' show incrementFakeFrequency, serializeFakeFreq, deserializeFakeFreq;
import 'package:shared_preferences/shared_preferences.dart';
import 'phrase_dictionary.dart';

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
  String? _lastCommittedChar; // For phrase suggestion
  List<String> _recentMemory = [];
  bool _isEnUpperCase = true;
  double _keyboardHeight = 360;

  static const String _fakeFreqKey = 'fake_freq';
  static const String _recentMemoryKey = 'recent_memory';

  @override
  void initState() {
    super.initState();
    _loadPersistence();
  }

  Future<void> _loadPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    final fakeFreqJson = prefs.getString(_fakeFreqKey);
    if (fakeFreqJson != null) {
      deserializeFakeFreq(fakeFreqJson);
    }
    final recent = prefs.getStringList(_recentMemoryKey);
    if (recent != null) {
      _recentMemory = List<String>.from(recent);
    }
    setState(() {});
  }

  Future<void> _savePersistence() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fakeFreqKey, serializeFakeFreq());
    await prefs.setStringList(_recentMemoryKey, _recentMemory);
  }

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
      _inputBuffer.clear();
      _candidates = [];
      _lastCommittedChar = null;
    });
  }

  void _handleKeyPressed(int index) async {
    setState(() {
      // Special keys
      if (index == -1) {
        if (_keyboardMode == KeyboardMode.cangjie) {
          if (_inputBuffer.isNotEmpty) {
            _inputBuffer.removeLast();
            final code = _inputBuffer.join();
            _candidates = _getCandidatesWithPhrases(code);
          }
          else if (_committedText.isNotEmpty) {
            _committedText = _committedText.substring(0, _committedText.length - 1);
          }
        } else {
          if (_committedText.isNotEmpty) {
            _committedText = _committedText.substring(0, _committedText.length - 1);
          }
        }
        _lastCommittedChar = null;
        return;
      } else if (index == -2) {
        // Clear (重輸)
        _inputBuffer.clear();
        _candidates = [];
        _lastCommittedChar = null;
        return;
      } else if (index == -3) {
        // Space
        _committedText += ' ';
        _lastCommittedChar = null;
        return;
      } else if (index == -4) {
        // Enter
        _committedText += '\n';
        _lastCommittedChar = null;
        return;
      } else if (index == -6) {
        // Show punctuation candidates in the unified candidate view
        _inputBuffer.clear();
        _candidates = punctuationCandidates;
        _lastCommittedChar = null;
        return;
      }

      // Map UI index to logical key index (0-9)
      int logicalKeyIndex = mainKeyIndices.indexOf(index);
      if (logicalKeyIndex == -1) return; // Not a main key

      switch (_keyboardMode) {
        case KeyboardMode.cangjie:
          if (logicalKeyIndex >= 0 && logicalKeyIndex < cangjieCodes.length) {
            // If input buffer is empty, show radicals for this key for selection
            if (_inputBuffer.isEmpty) {
              // Map cangjieCodes[logicalKeyIndex] to radicals
              String code = cangjieCodes[logicalKeyIndex];
              List<String> radicals = nineKeyRadicalMap[code] ?? [];
              if (radicals.isNotEmpty) {
                _candidates = radicals;
                _inputBuffer.add(code); // Mark which key is being selected
                return;
              }
            }
            _inputBuffer.add(cangjieCodes[logicalKeyIndex]);
            final code = _inputBuffer.join();
            _candidates = _getCandidatesWithPhrases(code);
          }
          break;
        case KeyboardMode.en:
          if (logicalKeyIndex >= 0 && logicalKeyIndex < enCodes.length) {
            // If input buffer is empty, show letter choices for this key
            if (_inputBuffer.isEmpty) {
              // Map logicalKeyIndex to enLettersUpper or enLettersLower
              final enLetters = _isEnUpperCase
                ? ['ABC', 'DEF','GHI','JKL','MNO','PQR','STU','VWX','YZ', '^A']
                : ['abc', 'def','ghi','jkl','mno','pqr','stu','vwx','yz', '^a'];
              String group = enLetters[logicalKeyIndex];
              List<String> letters = group.split('');
              _candidates = letters;
              _inputBuffer.add(enCodes[logicalKeyIndex]); // Mark which key is being selected
              return;
            }
            _committedText += (_isEnUpperCase
              ? enCodes[logicalKeyIndex]
              : enCodes[logicalKeyIndex].toLowerCase());
            _lastCommittedChar = null;
          }
          break;
        case KeyboardMode.digit:
          if (logicalKeyIndex >= 0 && logicalKeyIndex < digitCodes.length) {
            _committedText += digitCodes[logicalKeyIndex];
            _lastCommittedChar = null;
          }
          break;
      }
    });
  }

  // Helper: get phrase and single-character candidates
  List<String> _getCandidatesWithPhrases(String code) {
    final List<String> candidates = [];
    // 1. Phrase candidates (if any, after a character is committed)
    if (_lastCommittedChar != null && phraseDictionary.containsKey(_lastCommittedChar!)) {
      candidates.addAll(phraseDictionary[_lastCommittedChar!]!); // Only suffixes
    }
    // 2. Single-character candidates (from Cangjie code)
    final singleChars = List<String>.from(cangjieDictionary[code] ?? []);
    singleChars.sort((a, b) => getFakeFrequency(b).compareTo(getFakeFrequency(a)));
    candidates.addAll(singleChars);
    return candidates;
  }

  void _handleCandidateSelected(String candidate) {
    setState(() {
      // 判斷是否為詞語（由 lastCommittedChar 產生的候選）
      final isPhrase = _lastCommittedChar != null && (phraseDictionary[_lastCommittedChar!]?.contains(candidate) ?? false);
      // If candidate selection is for EN or Cangjie key group, commit the letter/radical
      if (_keyboardMode == KeyboardMode.en && _inputBuffer.length == 1 && _candidates.contains(candidate)) {
        _committedText += candidate;
        _inputBuffer.clear();
        _candidates = [];
        _lastCommittedChar = null;
        return;
      }
      if (_keyboardMode == KeyboardMode.cangjie && _inputBuffer.length == 1 && _candidates.contains(candidate)) {
        _committedText += candidate;
        _inputBuffer.clear();
        _candidates = [];
        _lastCommittedChar = null;
        return;
      }
      if (isPhrase) {
        // 用詞語取代最後一個單字，詞語為 lastCommittedChar + candidate
        if (_committedText.isNotEmpty) {
          _committedText = _committedText.substring(0, _committedText.length - _lastCommittedChar!.length);
        }
        final phrase = _lastCommittedChar! + candidate;
        _committedText += phrase;
        // 動態更新詞語和每個字的頻率
        incrementFakeFrequency(phrase);
        for (var char in phrase.runes) {
          incrementFakeFrequency(String.fromCharCode(char));
        }
        _addToRecentMemory(phrase);
        _lastCommittedChar = null;
        _inputBuffer.clear();
        _candidates = [];
      } else {
        // 單字被選中，暫存該字以便配詞
        _committedText += candidate;
        incrementFakeFrequency(candidate);
        _addToRecentMemory(candidate);
        _lastCommittedChar = candidate;
        _inputBuffer.clear();
        // 產生以此字開頭的詞語候選
        _candidates = _getCandidatesWithPhrases('');
      }
      _savePersistence().catchError((e) {
        // 可以 log 或顯示錯誤提示
        print('Persistence error: $e');
      });
    });
  }

  void _addToRecentMemory(String text) {
    _recentMemory.remove(text);
    _recentMemory.insert(0, text);
    if (_recentMemory.length > 10) {
      _recentMemory = _recentMemory.sublist(0, 10);
    }
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

  void _toggleEnCase() {
    setState(() {
      _isEnUpperCase = !_isEnUpperCase;
    });
  }

  void _handleBackspaceLongPress() {
    setState(() {
      _committedText = '';
      _lastCommittedChar = null;
      _inputBuffer.clear();
      _candidates = [];
    });
  }

  void _handleHeightDrag(double delta) {
    setState(() {
      _keyboardHeight = (_keyboardHeight + delta).clamp(200, 600);
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
            // Debug info: print to console instead of UI
            (() {
              // ignore: avoid_print
              print('已輸入: $_committedText');
              if (_keyboardMode == KeyboardMode.cangjie) {
                // ignore: avoid_print
                print('Input buffer:  ${_inputBuffer.join(" ")}');
              }
              return const SizedBox.shrink();
            })(),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Close button and candidate list row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Candidate buttons (take most of the row, leave space for close button)
                        Expanded(
                          flex: 8,
                          child: _candidates.isNotEmpty
                              ? SizedBox(
                                  height: 48,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _candidates.length,
                                    separatorBuilder: (context, idx) => const SizedBox(width: 8),
                                    itemBuilder: (context, idx) {
                                      final candidate = _candidates[idx];
                                      // Phrase candidates are those found in phraseDictionary for the current buffer
                                      final isPhrase = _lastCommittedChar != null && (phraseDictionary[_lastCommittedChar!]?.contains(candidate) ?? false);
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          backgroundColor: isPhrase ? Colors.lightBlue[100] : Colors.white,
                                          foregroundColor: Colors.black87,
                                          elevation: 1,
                                          side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                                        ),
                                        onPressed: () => _handleCandidateSelected(candidate),
                                        child: Text(
                                          isPhrase ? candidate : candidate,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox(height: 48),
                        ),
                        // Close button (right-aligned)
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Keyboard exited!')),
                                );
                              },
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: _keyboardHeight,
                      child: NineKeyKeyboard(
                        onKeyPressed: _handleKeyPressed,
                        keyboardMode: _keyboardMode,
                        onToggleMode: _toggleMode,
                        onExit: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Keyboard exited!')),
                          );
                        },
                        isEnUpperCase: _isEnUpperCase,
                        onEnCaseToggle: _keyboardMode == KeyboardMode.en ? _toggleEnCase : null,
                        onBackspaceLongPress: _handleBackspaceLongPress,
                        onHeightDrag: _handleHeightDrag,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

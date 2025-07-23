// lib/fake_freq.dart

final Map<String, int> _fakeFreq = {
  '一': 1000,
  '口': 800,
  '木': 600,
  '人': 900,
  '天': 700,
  '明': 1200,
  '想': 500,
  '神': 300,
  '語': 400,
  '地': 1100,
  '愛': 950,
  '英': 850,
  '音': 750,
  '安': 650,
  '衣': 550,
  '意': 450,
  // ... add more as needed
};

int getFakeFrequency(String word) {
  return _fakeFreq[word] ?? 100;
}

/// Increment frequency for a word (for dynamic learning)
void incrementFakeFrequency(String word) {
  _fakeFreq[word] = (_fakeFreq[word] ?? 100) + 1;
} 
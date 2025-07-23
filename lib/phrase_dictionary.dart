// lib/phrase_dictionary.dart

/// Sample phrase dictionary: maps a character to a list of phrase suffixes (not including the head character itself).
/// For example, '明': ['天', '白'] means the phrases '明天', '明白' can be formed after '明'.
const Map<String, List<String>> phraseDictionary = {
  '明': ['天', '白', '亮'],
  '想': ['像', '法', '念'],
  '語': ['言', '音', '法'],
  '天': ['氣', '使', '才'],
  '大': ['學', '樓', '海'],
  '中': ['國', '心', '間'],
  // Add more as needed for demo
}; 
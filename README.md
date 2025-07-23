# 📝 功能更新日誌 / Feature Changelog

- 2024-06-09
  - 鍵盤高度可調整（候選區上方可拖曳 emoji ≡）
  - 重輸按鈕僅清除 input buffer，並以橙色底白字顯示
  - Backspace 長按可清空所有已輸入文字
  - EN/Cangjie 模式下主鍵首按顯示候選，選擇後才輸入
  - 切換模式時自動清空 input buffer
  - UI/交互細節優化（按鈕顏色、間距、卡片陰影、emoji 位置等）

### 🍎 App 名稱 **九倉**

### 🧩 功能模組現狀

#### 1️⃣ 九鍵輸入介面  
- 🟦 九個按鍵，每鍵對應一組字根
- 🔁 支援連續輸入、刪除、候選字選擇
- 🕹️ 進階手勢操作（規劃中）

#### 2️⃣ 候選字/詞排序邏輯  
- 🧠 使用頻率分析（已支援 fake 頻率動態學習）
- 💾 本地持久化 fake 頻率與最近輸入記憶（規劃中）
- 🕓 最近輸入記憶、語境預測（規劃中）

#### 3️⃣ 教學與挑戰模式  
- 📚 新手教學、挑戰賽、成就系統（規劃中）

---

### 📦 技術現狀

| 模組 | 技術方向 |
|------|-----------|
| 前端 | Flutter（已實作） |
| 後端 | Firebase／Node.js（未來規劃） |
| 倉頡資料庫 | 自建字根映射表 |
| 輸入引擎 | 倉頡拆碼、fake 頻率排序 |
| 本地資料 | fake 頻率與最近輸入記憶持久化（規劃中） |

---

### 🍎 App Name :  **\"NineCang\"**

### 🧩 Feature Modules (Current Status)

#### 1️⃣ Nine-Key Input Interface  
- 🟦 Nine keys, each mapped to a group of radicals
- 🔁 Supports continuous input, deletion, and candidate selection
- 🕹️ Advanced gesture support (planned)

#### 2️⃣ Candidate Character/Word Sorting Logic  
- 🧠 Frequency analysis (dynamic fake frequency supported)
- 💾 Local persistence of fake frequency and recent input memory (planned)
- 🕓 Recent input memory, context prediction (planned)

#### 3️⃣ Tutorial & Challenge Modes  
- 📚 Beginner tutorial, challenge, achievements (planned)

---

### 📦 Technical Status

| Module | Technology Direction |
|--------|---------------------|
| Frontend | Flutter (implemented) |
| Backend | Firebase/Node.js (future) |
| Cangjie Database | Custom radical mapping table |
| Input Engine | Cangjie decomposition, fake frequency sorting |
| Local Data | Local persistence of fake frequency and recent input memory (planned) |

---

# ninecang

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
### 🍎 App 名稱 **九倉**

### 🧩 功能模組設計

#### 1️⃣ 九鍵輸入介面  
- 🟦 九個按鍵，每鍵對應一組字根（可參考你先前嘅 Markdown 排版）
- 🅰️ 每鍵點擊可顯示字根提示動畫，幫助學習
- 🔁 支援連續輸入、刪除、候選字選擇

#### 2️⃣ 倉頡碼拆解輔助  
- 🔍 用戶可以查詢任何漢字嘅拆碼過程
- 👀 拆碼動畫演示（每個字根閃爍顯示）

#### 3️⃣ 候選字排序邏輯  
- 🧠 使用頻率分析 + 語境預測  
- 🕓 最近輸入字記憶、手勢優先

#### 4️⃣ 教學與挑戰模式  
- 📚 新手教學：由基本字根開始、互動練習關卡  
- 🎮 「倉頡挑戰賽」：限時輸入指定詞語，提升熟練度  
- 🏆 排行榜與進度成就

---

### 🎨 視覺風格構想

| 元素 | 設計方向 |
|------|----------|
| 主色調 | 中式墨黑＋簡潔白底（亦可選擇古風或科技感） |
| 字型 | 粵字體或金萱體，兼顧美感與識別性 |
| 動畫 | 每次點擊鍵位有波紋動畫、字根閃爍提示 |

---

### 📦 技術架構建議

| 模組 | 技術方向 |
|------|-----------|
| 前端 | SwiftUI（原生 iOS）、或 React Native |
| 後端 | Firebase／Node.js（儲存詞頻與使用紀錄） |
| 倉頡資料庫 | 自建字根映射表、或引用開源倉頡碼庫 |
| 輸入引擎 | 拆碼邏輯 + 候選字排序演算法 |

---

### 🍎 App Name :  **"NineCang"** 

### 🧩 Feature Modules

#### 1️⃣ Nine-Key Input Interface  
- 🟦 Nine keys, each mapped to a group of radicals (refer to your previous Markdown layout)
- 🅰️ Tap any key to show radical hint animations for learning support
- 🔁 Supports continuous input, deletion, and candidate selection

#### 2️⃣ Cangjie Code Decomposition Assistant  
- 🔍 Users can look up the decomposition process for any Chinese character
- 👀 Animated demonstration of decomposition (each radical flashes in sequence)

#### 3️⃣ Candidate Character Sorting Logic  
- 🧠 Frequency analysis + context prediction  
- 🕓 Recent input memory and gesture prioritization

#### 4️⃣ Tutorial & Challenge Modes  
- 📚 Beginner tutorial: start from basic radicals, with interactive practice levels  
- 🎮 "Cangjie Challenge": input given words within a time limit to boost proficiency  
- 🏆 Leaderboards and achievement tracking

---

### 🎨 Visual Style Concepts

| Element | Design Direction |
|---------|------------------|
| Main Color | Classic Chinese ink black + clean white background (optionally vintage or tech style) |
| Font | Cantonese or Jin Xuan font, balancing aesthetics and readability |
| Animation | Ripple effect on key tap, radical hint flashing |

---

### 📦 Technical Architecture Suggestions

| Module | Technology Direction |
|--------|---------------------|
| Frontend | SwiftUI (native iOS), or React Native |
| Backend | Firebase/Node.js (for storing word frequency and usage records) |
| Cangjie Database | Custom radical mapping table, or open-source Cangjie code library |
| Input Engine | Decomposition logic + candidate sorting algorithm |

---

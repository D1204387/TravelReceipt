# 旅行記帳 TravelReceipt

> iOS 旅遊支出管理應用程式

## 📋 專案概述

TravelReceipt 是一款專為旅行者設計的 iOS 應用程式，協助使用者在旅途中輕鬆記錄、管理及分析支出。透過智慧掃描發票功能與多幣別支援，讓旅行財務管理變得簡單直覺。

---

## 🎯 開發動機與目標

### 問題分析
- 旅行時常會累積大量收據，難以整理
- 跨國旅行涉及多種貨幣換算，計算繁瑣
- 事後統計支出費時費力

### 解決方案
本專案開發一款整合型旅遊記帳 App，提供：
- 即時記錄支出
- 自動掃描辨識發票
- 多幣別自動換算
- 圖表化統計分析

---

## 🛠️ 使用技術

### 開發環境
| 項目 | 版本/規格 |
|------|-----------|
| 開發工具 | Xcode 15+ |
| 程式語言 | Swift 5.9 |
| 最低支援版本 | iOS 17.0 |
| 專案類型 | SwiftUI App |

### 核心框架

| 框架名稱 | 用途說明 |
|----------|----------|
| **SwiftUI** | 宣告式 UI 框架，建構使用者介面 |
| **SwiftData** | 資料持久化框架，管理本地資料庫 |
| **CloudKit** | iCloud 雲端同步服務 |
| **WidgetKit** | 主畫面小工具開發 |
| **Vision** | OCR 文字辨識（發票掃描） |
| **Charts** | 資料視覺化圖表 |

### 第三方套件

| 套件名稱 | 用途說明 |
|----------|----------|
| **SwiftDate** | 日期計算與格式化工具 |

---

## 📱 功能特色

### 1. 行程管理
- 建立/編輯/刪除旅行行程
- 分段顯示：進行中、即將開始、已結束
- 搜尋功能：依名稱或目的地搜尋

### 2. 支出記錄
- 快速新增支出項目
- 8 種分類：餐飲、交通、住宿、通信、雜支等
- 支援附加收據照片

### 3. 智能掃描
- OCR 自動辨識發票金額
- 自動擷取商家名稱
- 台灣電子發票 QR Code 解析

### 4. 多幣別支援
- 支援 TWD、USD、JPY、EUR、CNY 等貨幣
- 自訂匯率設定
- 自動換算統計

### 5. 統計分析
- 圓餅圖顯示支出分布
- 日均支出計算
- CSV 匯出功能

### 6. 雲端同步
- iCloud 即時同步
- 多裝置資料一致

### 7. 主畫面小工具
- 三種尺寸：小、中、大
- 即時顯示行程統計
- 互動式重新整理按鈕

---

## 🏗️ 系統架構

```
TravelReceipt/
├── Models/                 # 資料模型
│   ├── Trip.swift          # 行程模型
│   ├── Expense.swift       # 支出模型
│   ├── ExpenseCategory.swift
│   └── SharedTripData.swift
│
├── Views/                  # 視圖層
│   ├── ContentView.swift   # 主視圖
│   ├── TripListView.swift  # 行程列表
│   ├── TripDetailView.swift
│   ├── AddTripView.swift
│   ├── AddExpenseView.swift
│   ├── StatisticsView.swift
│   └── SettingsView.swift
│
├── Components/             # 可重用元件
│   ├── OCRService.swift    # OCR 服務
│   ├── ImagePicker.swift
│   └── ReceiptPhotoManager.swift
│
├── Scanner/                # 掃描功能
│   ├── ReceiptScannerView.swift
│   └── ScanResult.swift
│
├── Parser/                 # 文字解析
│   └── ReceiptTextParser.swift
│
├── Utils/                  # 工具類
│   └── Double+Format.swift
│
└── TravelReceiptWidget/    # Widget 擴展
    ├── TravelReceiptWidget.swift
    ├── SharedTripData.swift
    └── RefreshIntent.swift
```

---

## 📊 資料模型設計

### Trip（行程）
```swift
@Model
class Trip {
    var id: UUID
    var name: String
    var destination: String?
    var startDate: Date
    var endDate: Date
    var totalBudget: Double?
    var primaryCurrency: String
    var exchangeRates: [String: Double]
    @Relationship var expenses: [Expense]?
}
```

### Expense（支出）
```swift
@Model
class Expense {
    var id: UUID
    var amount: Double
    var currency: String
    var date: Date
    var storeName: String?
    var category: ExpenseCategory
    var receiptImage: Data?
    @Relationship var trip: Trip?
}
```

---

## 🔧 關鍵技術實作

### 1. SwiftData + CloudKit 同步
```swift
let config = ModelConfiguration(
    schema: schema,
    cloudKitDatabase: .private("iCloud.com.app.TravelReceipt")
)
let container = try ModelContainer(for: schema, configurations: [config])
```

### 2. App Groups 資料共享
主 App 與 Widget 透過共享容器交換資料：
```swift
let containerURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.app.TravelReceipt"
)
```

### 3. Widget 互動按鈕 (App Intents)
```swift
struct RefreshWidgetIntent: AppIntent {
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
```

### 4. OCR 文字辨識 (Vision)
```swift
let request = VNRecognizeTextRequest { request, error in
    let observations = request.results as? [VNRecognizedTextObservation]
    // 處理辨識結果
}
```

---

## 📸 應用程式截圖

| 行程列表 | 支出明細 | 統計圖表 | 小工具 |
|:--------:|:--------:|:--------:|:------:|
| 分段顯示 | 分類記錄 | 圓餅圖 | 三種尺寸 |

---

## 🚀 安裝與執行

### 環境需求
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ 裝置或模擬器
- Apple Developer 帳號（iCloud 功能需要）

### 建置步驟
1. Clone 專案
   ```bash
   git clone https://github.com/your-repo/TravelReceipt.git
   ```

2. 開啟專案
   ```bash
   open TravelReceipt.xcodeproj
   ```

3. 設定簽署
   - 選擇您的 Team
   - 確認 Bundle Identifier

4. 執行
   - 選擇目標裝置
   - 按下 Run (⌘R)

---

## 📝 開發心得與困難

### 遇到的挑戰

1. **SwiftData + CloudKit 整合**
   - 需要正確設定 iCloud Container 和 App Groups
   - 同步機制需要時間理解

2. **Widget 資料共享**
   - Widget 無法直接存取主 App 資料庫
   - 透過 App Groups 共享容器解決

3. **OCR 辨識準確度**
   - 不同格式發票辨識率差異大
   - 需要針對常見格式優化解析邏輯

### 學習收穫
- 深入理解 SwiftUI 宣告式程式設計
- 掌握 SwiftData 資料持久化技術
- 了解 iOS Extension 開發模式
- 實作 CloudKit 雲端同步

---

## 🔮 未來展望

- [ ] 加入預算警示通知
- [ ] 支援更多貨幣即時匯率 API
- [ ] 整合系統行事曆 (EventKit)
- [ ] 加入行程地圖標記
- [ ] Apple Watch 版本

---

## 👥 開發團隊

| 姓名 | 學號 | 負責項目 |
|------|------|----------|
| YiJou | XXXXXXXX | 全端開發 |

---

## 📄 授權條款

本專案僅供學術研究使用。

---

## 📚 參考資料

1. [Apple Developer Documentation - SwiftUI](https://developer.apple.com/documentation/swiftui)
2. [Apple Developer Documentation - SwiftData](https://developer.apple.com/documentation/swiftdata)
3. [Apple Developer Documentation - WidgetKit](https://developer.apple.com/documentation/widgetkit)
4. [SwiftDate GitHub Repository](https://github.com/malcommac/SwiftDate)

---

*最後更新：2025 年 12 月*
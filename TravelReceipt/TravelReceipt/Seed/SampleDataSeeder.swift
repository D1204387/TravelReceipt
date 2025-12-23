// Seed/SampleDataSeeder.swift
import Foundation
import SwiftData
import SwiftDate

struct SampleDataSeeder {
    
    /// 檢查是否需要載入，有資料就跳過
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Trip>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return
        }
        createSampleData(context: context)
    }
    
    /// 強制載入範例資料（不檢查）
    static func seedSampleData(context: ModelContext) -> Bool {
        createSampleData(context: context)
        return true
    }
    
    /// 建立範例資料
    private static func createSampleData(context: ModelContext) {
        
        // ========================================
        // 行程 1：東京自由行（已結束）
        // ========================================
        let tokyoStart = Date() - 30.days
        let tokyoEnd = tokyoStart + 6.days
        
        let tokyoTrip = Trip(
            name: "東京自由行",
            destination: "東京",
            startDate: tokyoStart,
            endDate: tokyoEnd,
            totalBudget: 80000.0,
            notes: "年末日本旅遊",
            primaryCurrency: "TWD",
            exchangeRates: ["JPY": 0.22, "USD": 32.0]  // 1 JPY = 0.22 TWD
        )
        context.insert(tokyoTrip)
        
        // 東京支出
        let tokyoExpenses = [
            Expense(amount: 15000, currency: "JPY", date: tokyoStart,
                    storeName: "成田機場快線", notes: "N'EX 來回票", trip: tokyoTrip, category: .transport),
            Expense(amount: 45000, currency: "JPY", date: tokyoStart + 1.days,
                    storeName: "新宿華盛頓酒店", notes: "3晚住宿", trip: tokyoTrip, category: .lodging),
            Expense(amount: 8500, currency: "JPY", date: tokyoStart + 1.days,
                    storeName: "一蘭拉麵", notes: nil, trip: tokyoTrip, category: .food),
            Expense(amount: 12000, currency: "JPY", date: tokyoStart + 2.days,
                    storeName: "淺草寺周邊", notes: "紀念品", trip: tokyoTrip, category: .miscellaneous),
            Expense(amount: 6800, currency: "JPY", date: tokyoStart + 3.days,
                    storeName: "築地市場", notes: "海鮮丼", trip: tokyoTrip, category: .food),
            Expense(amount: 3500, currency: "JPY", date: tokyoStart + 4.days,
                    storeName: "東京地鐵", notes: "一日券", trip: tokyoTrip, category: .transport),
            Expense(amount: 2800, currency: "JPY", date: tokyoStart + 5.days,
                    storeName: "b-mobile", notes: "SIM卡", trip: tokyoTrip, category: .telecom)
        ]
        tokyoExpenses.forEach { context.insert($0) }
        
        // ========================================
        // 行程 2：首爾出差（進行中）
        // ========================================
        let seoulStart = Date() - 2.days
        let seoulEnd = Date() + 3.days
        
        let seoulTrip = Trip(
            name: "首爾商務出差",
            destination: "首爾",
            startDate: seoulStart,
            endDate: seoulEnd,
            totalBudget: 50000.0,
            notes: "年終會議",
            primaryCurrency: "TWD",
            exchangeRates: ["KRW": 0.024, "USD": 32.0]  // 1 KRW = 0.024 TWD
        )
        context.insert(seoulTrip)
        
        // 首爾支出
        let seoulExpenses = [
            Expense(amount: 85000, currency: "KRW", date: seoulStart,
                    storeName: "仁川機場快線", notes: "AREX直通車", trip: seoulTrip, category: .transport),
            Expense(amount: 280000, currency: "KRW", date: seoulStart,
                    storeName: "明洞樂天酒店", notes: "5晚商務房", trip: seoulTrip, category: .lodging),
            Expense(amount: 45000, currency: "KRW", date: seoulStart + 1.days,
                    storeName: "景福宮附近餐廳", notes: "韓式烤肉", trip: seoulTrip, category: .food),
            Expense(amount: 15000, currency: "KRW", date: seoulStart + 2.days,
                    storeName: "KT Telecom", notes: "eSIM 5天", trip: seoulTrip, category: .telecom)
        ]
        seoulExpenses.forEach { context.insert($0) }
        
        // ========================================
        // 行程 3：峇里島度假（即將開始）
        // ========================================
        let baliStart = Date() + 14.days
        let baliEnd = baliStart + 8.days
        
        let baliTrip = Trip(
            name: "峇里島蜜月旅行",
            destination: "峇里島",
            startDate: baliStart,
            endDate: baliEnd,
            totalBudget: 120000.0,
            notes: "結婚週年慶祝",
            primaryCurrency: "TWD",
            exchangeRates: ["IDR": 0.002, "USD": 32.0]  // 1 IDR = 0.002 TWD
        )
        context.insert(baliTrip)
        
        // 峇里島預計支出（預付項目）
        let baliExpenses = [
            Expense(amount: 35000, currency: "TWD", date: Date(),
                    storeName: "長榮航空", notes: "來回機票(已付)", trip: baliTrip, category: .transport),
            Expense(amount: 48000, currency: "TWD", date: Date(),
                    storeName: "Ayana Resort", notes: "Villa 8晚(已付)", trip: baliTrip, category: .lodging)
        ]
        baliExpenses.forEach { context.insert($0) }
        
        // 存檔
        do {
            try context.save()
            print("✅ 範例資料建立成功！共 3 個行程")
        } catch {
            print("❌ Seed save error: \(error)")
        }
    }
}

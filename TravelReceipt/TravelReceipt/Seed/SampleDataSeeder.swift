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
            // 建立日期
        let start = Date()
        let end = start + 5.days
        
            // 建立 Trip
        let trip = Trip(
            name: "上海出差(範例)",
            destination: "上海",
            startDate: start,
            endDate: end,
            totalBudget: 50000.0,
            notes: "範例資料"
        )
        context.insert(trip)
        
            // 建立支出
        let r1 = Expense(
            amount: 350.0,
            currency: "CNY",
            date: start,
            storeName: "浦東機場地鐵",
            notes: "機場→市區",
            trip: trip,
            category: .transport
        )
        
        let day2 = start + 1.days
        let r2 = Expense(
            amount: 980.0,
            currency: "CNY",
            date: day2,
            storeName: "商務午餐",
            notes: nil,
            trip: trip,
            category: .food
        )
        
        let day3 = start + 2.days
        let r3 = Expense(
            amount: 2100.0,
            currency: "CNY",
            date: day3,
            storeName: "商旅飯店",
            notes: "2晚",
            trip: trip,
            category: .lodging
        )
        
        let r4 = Expense(
            amount: 120.0,
            currency: "CNY",
            date: day3,
            storeName: "數據漫遊",
            notes: nil,
            trip: trip,
            category: .telecom
        )
        
        [r1, r2, r3, r4].forEach { context.insert($0) }
        
            // 存檔
        do {
            try context.save()
            print("✅ 範例資料建立成功！")
        } catch {
            print("❌ Seed save error: \(error)")
        }
    }
}

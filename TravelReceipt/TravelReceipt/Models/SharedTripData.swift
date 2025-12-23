//
//  SharedTripData.swift
//  TravelReceipt
//
//  用於主 App 和 Widget 之間共享資料
//

import Foundation

/// 共享行程資料結構（用於 Widget）
struct SharedTripData: Codable, Identifiable {
    let id: UUID
    let name: String
    let destination: String?
    let startDate: Date
    let endDate: Date
    let totalExpenses: Double      // 已轉換為主貨幣
    let expenseCount: Int
    let primaryCurrency: String
    let categoryBreakdown: [String: Double]  // 分類名稱 -> 金額
    
    /// 行程是否正在進行中
    var isActive: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }
    
    /// 行程天數
    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
    
    /// 日均支出
    var dailyExpense: Double {
        let days = Double(durationInDays)
        return days > 0 ? totalExpenses / days : 0
    }
}

/// 共享資料管理器
struct SharedDataManager {
    static let appGroupID = "group.com.buildwithharry.TravelReceipt"
    static let tripDataKey = "recentTripData"
    
    /// 獲取共享容器 URL
    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
    
    /// 資料檔案 URL
    static var dataFileURL: URL? {
        sharedContainerURL?.appendingPathComponent("widget_trip_data.json")
    }
    
    /// 儲存行程資料到共享容器
    static func saveTripData(_ trips: [SharedTripData]) {
        guard let fileURL = dataFileURL else {
            print("❌ 無法取得共享容器 URL")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(trips)
            try data.write(to: fileURL)
            print("✅ Widget 資料已儲存：\(trips.count) 個行程")
        } catch {
            print("❌ 儲存 Widget 資料失敗：\(error)")
        }
    }
    
    /// 從共享容器讀取行程資料
    static func loadTripData() -> [SharedTripData] {
        guard let fileURL = dataFileURL else {
            print("❌ 無法取得共享容器 URL")
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let trips = try decoder.decode([SharedTripData].self, from: data)
            print("✅ Widget 資料已載入：\(trips.count) 個行程")
            return trips
        } catch {
            print("⚠️ 載入 Widget 資料失敗或尚無資料：\(error)")
            return []
        }
    }
    
    /// 獲取最近的行程（優先顯示進行中的行程）
    static func getMostRecentTrip() -> SharedTripData? {
        let trips = loadTripData()
        
        // 優先返回進行中的行程
        if let activeTrip = trips.first(where: { $0.isActive }) {
            return activeTrip
        }
        
        // 否則返回最近建立的行程（按開始日期排序）
        return trips.sorted { $0.startDate > $1.startDate }.first
    }
}

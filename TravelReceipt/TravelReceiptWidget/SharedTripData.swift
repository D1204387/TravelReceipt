//
//  SharedTripData.swift
//  TravelReceiptWidget
//
//  共享資料結構（Widget 專用副本）
//

import Foundation

/// 共享行程資料結構（用於 Widget）
struct SharedTripData: Codable, Identifiable {
    let id: UUID
    let name: String
    let destination: String?
    let startDate: Date
    let endDate: Date
    let totalExpenses: Double
    let expenseCount: Int
    let primaryCurrency: String
    let categoryBreakdown: [String: Double]
    
    var isActive: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }
    
    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
    
    var dailyExpense: Double {
        let days = Double(durationInDays)
        return days > 0 ? totalExpenses / days : 0
    }
}

/// 共享資料管理器
struct SharedDataManager {
    static let appGroupID = "group.com.buildwithharry.TravelReceipt"
    static let tripDataKey = "recentTripData"
    
    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
    
    static var dataFileURL: URL? {
        sharedContainerURL?.appendingPathComponent("widget_trip_data.json")
    }
    
    static func saveTripData(_ trips: [SharedTripData]) {
        guard let fileURL = dataFileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(trips)
            try data.write(to: fileURL)
        } catch {
            print("❌ 儲存 Widget 資料失敗：\(error)")
        }
    }
    
    static func loadTripData() -> [SharedTripData] {
        guard let fileURL = dataFileURL else { return [] }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([SharedTripData].self, from: data)
        } catch {
            return []
        }
    }
    
    static func getMostRecentTrip() -> SharedTripData? {
        let trips = loadTripData()
        
        if let activeTrip = trips.first(where: { $0.isActive }) {
            return activeTrip
        }
        
        return trips.sorted { $0.startDate > $1.startDate }.first
    }
}

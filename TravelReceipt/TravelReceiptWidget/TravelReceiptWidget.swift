//
//  TravelReceiptWidget.swift
//  TravelReceiptWidget
//
//  最近行程資料與統計小工具
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct TripEntry: TimelineEntry {
    let date: Date
    let tripData: SharedTripData?
    
    static var placeholder: TripEntry {
        TripEntry(
            date: Date(),
            tripData: SharedTripData(
                id: UUID(),
                name: "東京之旅",
                destination: "東京",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 5),
                totalExpenses: 45600,
                expenseCount: 12,
                primaryCurrency: "JPY",
                categoryBreakdown: [
                    "交通": 12000,
                    "住宿": 18000,
                    "餐飲": 10000,
                    "通信": 2600,
                    "雜支": 3000
                ]
            )
        )
    }
}

// MARK: - Timeline Provider
struct TripProvider: TimelineProvider {
    func placeholder(in context: Context) -> TripEntry {
        TripEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TripEntry) -> Void) {
        let entry = TripEntry(
            date: Date(),
            tripData: SharedDataManager.getMostRecentTrip()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TripEntry>) -> Void) {
        let tripData = SharedDataManager.getMostRecentTrip()
        let entry = TripEntry(date: Date(), tripData: tripData)
        
        // 每 30 分鐘更新一次
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views

/// 小型 Widget 視圖
struct SmallWidgetView: View {
    let entry: TripEntry
    
    var body: some View {
        if let trip = entry.tripData {
            VStack(alignment: .leading, spacing: 8) {
                // 頂部：行程圖標和名稱
                HStack(spacing: 6) {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                }
                
                if let destination = trip.destination, !destination.isEmpty {
                    Text(destination)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 底部：總支出
                VStack(alignment: .leading, spacing: 2) {
                    Text("總支出")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(formatAmount(trip.totalExpenses))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(trip.primaryCurrency)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("\(trip.expenseCount) 筆支出")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            // 無資料狀態
            VStack(spacing: 8) {
                Image(systemName: "suitcase")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                
                Text("尚無行程")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text("開啟 App 新增")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// 中型 Widget 視圖
struct MediumWidgetView: View {
    let entry: TripEntry
    
    var body: some View {
        if let trip = entry.tripData {
            VStack(alignment: .leading, spacing: 10) {
                // 頂部：行程資訊
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.blue)
                            
                            Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                                .font(.system(size: 15, weight: .semibold))
                                .lineLimit(1)
                        }
                        
                        if let destination = trip.destination, !destination.isEmpty {
                            Text(destination)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 日期範圍
                    Text(formatDateRange(start: trip.startDate, end: trip.endDate))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // 中部：統計資訊
                HStack(spacing: 16) {
                    // 總支出
                    VStack(alignment: .leading, spacing: 2) {
                        Text("總支出")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(formatAmount(trip.totalExpenses))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Text(trip.primaryCurrency)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // 支出筆數
                    VStack(alignment: .leading, spacing: 2) {
                        Text("支出筆數")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        
                        Text("\(trip.expenseCount)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    
                    // 日均支出
                    VStack(alignment: .leading, spacing: 2) {
                        Text("日均支出")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        
                        Text(formatAmount(trip.dailyExpense))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    
                    Spacer()
                }
                
                // 底部：分類進度條
                if !trip.categoryBreakdown.isEmpty {
                    CategoryBarView(breakdown: trip.categoryBreakdown, total: trip.totalExpenses)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            // 無資料狀態
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "suitcase")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    
                    Text("尚無行程資料")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("開啟 TravelReceipt 新增行程")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// 大型 Widget 視圖
struct LargeWidgetView: View {
    let entry: TripEntry
    
    var body: some View {
        if let trip = entry.tripData {
            VStack(alignment: .leading, spacing: 12) {
                // 頂部：行程資訊
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.blue)
                            
                            Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                                .font(.system(size: 17, weight: .semibold))
                                .lineLimit(1)
                        }
                        
                        if let destination = trip.destination, !destination.isEmpty {
                            Text(destination)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatDateRange(start: trip.startDate, end: trip.endDate))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        
                        Text("\(trip.durationInDays) 天")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.blue)
                    }
                }
                
                Divider()
                
                // 總支出卡片
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("總支出")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(formatAmount(trip.totalExpenses))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            
                            Text(trip.primaryCurrency)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 4) {
                            Text("\(trip.expenseCount)")
                                .font(.system(size: 16, weight: .bold))
                            Text("筆")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Text("日均")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(formatAmount(trip.dailyExpense))
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                
                Divider()
                
                // 分類明細
                Text("分類明細")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                if !trip.categoryBreakdown.isEmpty {
                    CategoryDetailView(breakdown: trip.categoryBreakdown, total: trip.totalExpenses, currency: trip.primaryCurrency)
                } else {
                    Text("尚無支出記錄")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            // 無資料狀態
            VStack(spacing: 12) {
                Image(systemName: "suitcase")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("尚無行程資料")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text("開啟 TravelReceipt App\n新增您的第一個行程")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Helper Views

/// 分類進度條視圖（用於中型 Widget）
struct CategoryBarView: View {
    let breakdown: [String: Double]
    let total: Double
    
    private let categoryColors: [String: Color] = [
        "交通": .blue,
        "住宿": .purple,
        "餐飲": .orange,
        "通信": .green,
        "雜支": .gray
    ]
    
    var sortedCategories: [(name: String, amount: Double)] {
        breakdown.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // 進度條
            GeometryReader { geometry in
                HStack(spacing: 1) {
                    ForEach(sortedCategories, id: \.name) { category in
                        let width = total > 0 ? (category.amount / total) * geometry.size.width : 0
                        RoundedRectangle(cornerRadius: 2)
                            .fill(categoryColors[category.name] ?? .gray)
                            .frame(width: max(width, 2))
                    }
                }
            }
            .frame(height: 6)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            
            // 圖例
            HStack(spacing: 8) {
                ForEach(sortedCategories.prefix(4), id: \.name) { category in
                    HStack(spacing: 3) {
                        Circle()
                            .fill(categoryColors[category.name] ?? .gray)
                            .frame(width: 6, height: 6)
                        Text(category.name)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        }
    }
}

/// 分類明細視圖（用於大型 Widget）
struct CategoryDetailView: View {
    let breakdown: [String: Double]
    let total: Double
    let currency: String
    
    private let categoryIcons: [String: String] = [
        "交通": "🚌",
        "住宿": "🏨",
        "餐飲": "🍽️",
        "通信": "📱",
        "雜支": "📦"
    ]
    
    private let categoryColors: [String: Color] = [
        "交通": .blue,
        "住宿": .purple,
        "餐飲": .orange,
        "通信": .green,
        "雜支": .gray
    ]
    
    var sortedCategories: [(name: String, amount: Double)] {
        breakdown.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(sortedCategories, id: \.name) { category in
                HStack {
                    // 圖標和名稱
                    HStack(spacing: 6) {
                        Circle()
                            .fill(categoryColors[category.name] ?? .gray)
                            .frame(width: 8, height: 8)
                        
                        Text(categoryIcons[category.name] ?? "📦")
                            .font(.system(size: 12))
                        
                        Text(category.name)
                            .font(.system(size: 13))
                    }
                    
                    Spacer()
                    
                    // 金額
                    Text(formatAmount(category.amount))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                    
                    // 百分比
                    Text(formatPercentage(category.amount, of: total))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
    
    private func formatPercentage(_ value: Double, of total: Double) -> String {
        guard total > 0 else { return "0%" }
        let percentage = (value / total) * 100
        return String(format: "%.0f%%", percentage)
    }
}

// MARK: - Helper Functions

private func formatAmount(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.groupingSeparator = ","
    return formatter.string(from: NSNumber(value: amount)) ?? "0"
}

private func formatDateRange(start: Date, end: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d"
    return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
}

// MARK: - Main Widget

struct TravelReceiptWidget: Widget {
    let kind: String = "TravelReceiptWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TripProvider()) { entry in
            TravelReceiptWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("旅行記帳")
        .description("顯示最近行程的支出統計")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TravelReceiptWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TripProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    TravelReceiptWidget()
} timeline: {
    TripEntry.placeholder
    TripEntry(date: .now, tripData: nil)
}

#Preview("Medium", as: .systemMedium) {
    TravelReceiptWidget()
} timeline: {
    TripEntry.placeholder
}

#Preview("Large", as: .systemLarge) {
    TravelReceiptWidget()
} timeline: {
    TripEntry.placeholder
}

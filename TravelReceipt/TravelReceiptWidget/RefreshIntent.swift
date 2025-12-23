//
//  RefreshIntent.swift
//  TravelReceiptWidget
//
//  Widget 重新整理 Intent
//

import AppIntents
import WidgetKit

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "重新整理 Widget"
    static var description = IntentDescription("重新載入 Widget 資料")
    
    func perform() async throws -> some IntentResult {
        // 觸發 Widget Timeline 重新載入
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

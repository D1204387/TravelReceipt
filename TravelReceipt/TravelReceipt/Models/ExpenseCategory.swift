//
//  ExpenseCategory.swift
//  TravelReceipt
//
//  Created by YiJou on 2025/11/13.
//

import Foundation
import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable {
    case transport
    case lodging
    case food
    case telecom
    case shopping       // 新增：購物
    case entertainment  // 新增：娛樂
    case attraction     // 新增：景點門票
    case miscellaneous
    
    var displayName: String {
        switch self {
        case .transport: return "交通"
        case .lodging: return "住宿"
        case .food: return "餐飲"
        case .telecom: return "通信"
        case .shopping: return "購物"
        case .entertainment: return "娛樂"
        case .attraction: return "景點"
        case .miscellaneous: return "雜支"
        }
    }
    
    var icon: String {
        switch self {
        case .transport: return "🚌"
        case .lodging: return "🏨"
        case .food: return "🍽️"
        case .telecom: return "📱"
        case .shopping: return "🛍️"
        case .entertainment: return "🎭"
        case .attraction: return "🎫"
        case .miscellaneous: return "📦"
        }
    }
    
    var color: Color {
        switch self {
        case .transport: return .blue
        case .lodging: return .purple
        case .food: return .orange
        case .telecom: return .green
        case .shopping: return .pink
        case .entertainment: return .indigo
        case .attraction: return .teal
        case .miscellaneous: return .gray
        }
    }
}

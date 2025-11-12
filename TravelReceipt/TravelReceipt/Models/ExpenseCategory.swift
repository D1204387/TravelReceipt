//
//  ExpenseCategory.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/13.
//

import Foundation
import SwiftData

@Model
final class ExpenseCategory {
    var name: String
    var iconName: String
    var sortOrder: Int = 0
    var expenses: [Expense] = []
    
    
    init(name: String, iconName: String, sortOrder: Int = 0) {
        self.name = name
        self.iconName = iconName
        self.sortOrder = sortOrder
        
    }
}
    
    

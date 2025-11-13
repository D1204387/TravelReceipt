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
    var iconName: String? = nil
    var color: String? = nil
    var sortOrder: Int = 0
    @Relationship(inverse: \Expense.category)
    var expenses: [Expense] = []
   
    init(name: String, iconName: String? = nil, color: String? = nil, sortOrder: Int = 0) {
        self.name = name
        self.iconName = iconName
        self.color = color
        self.sortOrder = sortOrder
        
    }
}
    
    

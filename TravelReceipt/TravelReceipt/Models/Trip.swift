//
//  Trip.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/13.
//

import Foundation
import SwiftData

@Model
final class Trip {
    // === 目前實現的基本功能 ===
    var id: UUID = UUID()
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var totalBudget: Double? = nil
    var notes: String? = nil
    
    // 一對多關聯：一個行程可以有多筆支出
    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var expenses: [Expense] = []
      
    init(name: String, destination: String, startDate: Date, endDate: Date, totalBudget: Double? = nil, notes: String? = nil) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.totalBudget = totalBudget
        self.notes = notes
    }
    
    // === 計算屬性 ===
    var totalExpenses: Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1 // 包含開始和結束日期
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        expense.trip = self
    }
        
    
    
}
    
    

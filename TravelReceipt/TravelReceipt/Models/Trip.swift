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
    // === 基本功能 ===
    var id: UUID = UUID()
    var name: String = ""
    var destination: String? = nil
    var startDate: Date = Date()
    var endDate: Date = Date()
    var totalBudget: Double? = nil
    var notes: String? = nil
    var createdAt: Date = Date()
    
    // === 貨幣管理 ===
    var primaryCurrency: String = "TWD"
    var exchangeRates: [String: Double] = [:] //匯率表
    
    // 一對多關聯：一個行程可以有多筆支出
    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var expenses: [Expense]? = nil
      
    init(
        name: String = "",
        destination: String? = nil,
        startDate: Date = Date(),
        endDate: Date = Date(),
        totalBudget: Double? = nil,
        notes: String? = nil,
        primaryCurrency: String = "TWD",
        exchangeRates: [String: Double] = [:]
    ) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.totalBudget = totalBudget
        self.notes = notes
        self.primaryCurrency = primaryCurrency
        self.exchangeRates = exchangeRates
    }
    
    // === 計算屬性 ===
    /// 總支出（原幣別）
    var totalExpenses: Double {
        return expenses?.reduce(0) { $0 + $1.amount } ?? 0
    }
    
    /// 總支出（轉換為主貨幣）
    var totalExpensesInPrimaryCurrency: Double {
        guard let expenses = expenses else { return 0 }
        return expenses.reduce(0) { sum, expense in
            sum + convertToPrimaryCurrency(amount: expense.amount, from: expense.currency)
        }
    }
    
    ///  日均支出（轉換為主貨幣）
    var dailyExpenseInPrimaryCurrency: Double {
        let days = Double(durationInDays)
        return days > 0 ? totalExpensesInPrimaryCurrency / days : 0
    }
        
    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1 // 包含開始和結束日期
    }
    
    /// 按幣別轉換金額至主貨幣
    var expensesByCurrencyInPrimaryCurrency: [String: Double] {
        guard let expenses = expenses else { return [:] }
        var result: [String: Double] = [:]
        for expense in expenses {
            let convertedAmount = convertToPrimaryCurrency(amount: expense.amount, from: expense.currency)
            result[expense.currency, default: 0] += convertedAmount
        }
        return result
    }
    
    // === 方法 ===
    /// 將指定幣別的金額轉換為主貨幣
    func convertToPrimaryCurrency(amount: Double, from currency: String) -> Double {
        guard currency != primaryCurrency else {
            return amount
        }
            // 獲取匯率，如果不存在則使用 1.0
        let rate = exchangeRates[currency] ?? 1.0
        return amount * rate
    }

    
    func addExpense(_ expense: Expense) {
        if expenses == nil {
            expenses = []
        }
        expenses!.append(expense)
    }
    
    /// 設置匯率
    func setExchangeRate(for currency: String, rate: Double) {
        exchangeRates[currency] = rate
        print("✅ 匯率已設置: 1 \(currency) = \(rate) \(primaryCurrency)")
    }
    
    /// 獲取匯率
    func getExchangeRate(for currency: String) -> Double? {
        return exchangeRates[currency] ?? 1.0
    }
}
    
    

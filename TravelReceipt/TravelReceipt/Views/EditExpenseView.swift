    //
    //  EditExpenseView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var expense: Expense
    
        // MARK: - Form State
    @State private var amount: String = ""
    @State private var currency: String = "TWD"
    @State private var date: Date = Date()
    @State private var category: ExpenseCategory = .miscellaneous
    @State private var storeName: String = ""
    @State private var notes: String = ""
    
        // 常用貨幣
    private let currencies = ["TWD", "CNY", "JPY", "USD", "EUR", "HKD", "KRW"]
    
        // 驗證
    private var isValid: Bool {
        guard let value = Double(amount), value > 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                    // MARK: - 金額
                Section("金額") {
                    HStack {
                        TextField("輸入金額", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                        
                        Picker("貨幣", selection: $currency) {
                            ForEach(currencies, id: \.self) { curr in
                                Text(curr).tag(curr)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                }
                
                    // MARK: - 分類
                Section("分類") {
                    Picker("選擇分類", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            HStack {
                                Text(cat.icon)
                                Text(cat.displayName)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                    // MARK: - 詳細資訊
                Section("詳細資訊") {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    
                    TextField("商家名稱", text: $storeName)
                    
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("編輯費用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadExpenseData()
            }
        }
    }
    
        // MARK: - Load Data
    private func loadExpenseData() {
        amount = String(format: "%.0f", expense.amount)
        currency = expense.currency ?? "TWD"
        date = expense.date
        category = expense.category
        storeName = expense.storeName ?? ""
        notes = expense.notes ?? ""
    }
    
        // MARK: - Save Changes
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        expense.amount = amountValue
        expense.currency = currency
        expense.date = date
        expense.category = category
        expense.storeName = storeName.isEmpty ? nil : storeName
        expense.notes = notes.isEmpty ? nil : notes
        
        dismiss()
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let expense = Expense(
        amount: 1500,
        currency: "TWD",
        date: Date(),
        storeName: "測試商家",
        category: .food
    )
    container.mainContext.insert(expense)
    
    return EditExpenseView(expense: expense)
        .modelContainer(container)
}

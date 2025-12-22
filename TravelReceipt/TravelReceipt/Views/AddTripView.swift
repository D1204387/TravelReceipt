    //
    //  AddTripView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData
import SwiftDate

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
        // MARK: - Form State
    @State private var name: String = ""
    @State private var destination: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()  // ✅ 預設同一天（允許一日行程）
    @State private var budgetString: String = ""
    @State private var notes: String = ""
    
    @State private var primaryCurrency: String = "TWD"
    @State private var exchangeRates: [String: Double] = [:]
    @State private var showingExchangeRateManager = false
    
        // 常用貨幣列表
    private let currencies = Constants.Currency.all
    
        // ✅ 修正驗證：只比較日期，忽略時間
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destination.trimmingCharacters(in: .whitespaces).isEmpty &&
        Calendar.current.compare(endDate, to: startDate, toGranularity: .day) != .orderedAscending
    }
    
    var body: some View {
        NavigationStack {
            Form {
                    // MARK: - 基本資訊
                Section("基本資訊") {
                    TextField("行程名稱", text: $name)
                    TextField("目的地", text: $destination)
                }
                
                    // MARK: - 日期
                Section {
                    DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { oldValue, newValue in
                                // ✅ 如果開始日期晚於結束日期，自動調整結束日期
                            if Calendar.current.compare(newValue, to: endDate, toGranularity: .day) == .orderedDescending {
                                endDate = newValue
                            }
                        }
                    
                    DatePicker("結束日期", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { oldValue, newValue in
                                // ✅ 如果結束日期早於開始日期，自動調整開始日期
                            if Calendar.current.compare(newValue, to: startDate, toGranularity: .day) == .orderedAscending {
                                startDate = newValue
                            }
                        }
                } header: {
                    Text("日期")
                } footer: {
                    Text("開始與結束日期可設為同一天（一日行程）")
                }
                
                    // MARK: - 預算（選填）
                Section {
                    HStack {
                        TextField("預算金額", text: $budgetString)
                            .keyboardType(.decimalPad)
                        Text("元")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("預算")
                } footer: {
                    Text("選填，可用於追蹤支出進度")
                }
                
                    // 🔴 MARK: - 貨幣設置（新增）
                Section {
                    Picker("主貨幣", selection: $primaryCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    
                    HStack {
                        Text("匯率設置")
                        Spacer()
                        Text("\(exchangeRates.count) 個已設置")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button(action: { showingExchangeRateManager = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("貨幣設置")
                } footer: {
                    Text("選擇主貨幣，設置各貨幣匯率用於自動轉換統計")
                }
                
                    // MARK: - 備註（選填）
                Section("備註") {
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("新增行程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveTrip()
                    }
                    .disabled(!isValid)
                }
            }
            
                // 🔴 新增：匯率管理 Sheet
            .sheet(isPresented: $showingExchangeRateManager) {
                ExchangeRateManager(
                    primaryCurrency: primaryCurrency,
                    exchangeRates: exchangeRates
                ) { rates in
                    exchangeRates = rates
                    showingExchangeRateManager = false
                }
            }
        }
    }
    
        // MARK: - Save Method
    private func saveTrip() {
        let budget: Double? = Double(budgetString)
        
            // ✅ 標準化日期（設為當天開始，避免時間問題）
        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: startDate)
        let normalizedEnd = calendar.startOfDay(for: endDate)
        
        let trip = Trip(
            name: name.trimmingCharacters(in: .whitespaces),
            destination: destination.trimmingCharacters(in: .whitespaces),
            startDate: normalizedStart,
            endDate: normalizedEnd,
            totalBudget: budget,
            notes: notes.isEmpty ? nil : notes,
            primaryCurrency: primaryCurrency,
            exchangeRates: exchangeRates
        )
        
        print("✅ 行程已建立: \(trip.name)")
        print("💱 主貨幣: \(trip.primaryCurrency)")
        print("📊 匯率: \(trip.exchangeRates)")
        
        modelContext.insert(trip)
        dismiss()
    }
}

    // MARK: - Preview
#Preview {
    AddTripView()
        .modelContainer(for: [Trip.self, Expense.self], inMemory: true)
}

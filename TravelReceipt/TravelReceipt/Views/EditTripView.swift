    //
    //  EditTripView.swift
    //  添加匯率編輯功能
    //
    //  Created by YiJou  on 2025/12/16.
    //

import SwiftUI
import SwiftData

struct EditTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var trip: Trip
    
        // MARK: - Form State
    @State private var name: String = ""
    @State private var destination: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var budgetString: String = ""
    @State private var notes: String = ""
    
        // ✅ 匯率相關
    @State private var primaryCurrency: String = "TWD"
    @State private var exchangeRates: [String: String] = [:]  // 幣別 -> 匯率字符串
    @State private var newCurrency: String = ""
    @State private var newRate: String = ""
    @State private var showingAddRate = false
    
    private let availableCurrencies = Constants.Currency.all
    
        // 驗證
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
                            if Calendar.current.compare(newValue, to: endDate, toGranularity: .day) == .orderedDescending {
                                endDate = newValue
                            }
                        }
                    
                    DatePicker("結束日期", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { oldValue, newValue in
                            if Calendar.current.compare(newValue, to: startDate, toGranularity: .day) == .orderedAscending {
                                startDate = newValue
                            }
                        }
                } header: {
                    Text("日期")
                } footer: {
                    Text("開始與結束日期可設為同一天（一日行程）")
                }
                
                    // MARK: - 預算
                Section {
                    HStack {
                        TextField("預算金額", text: $budgetString)
                            .keyboardType(.decimalPad)
                        Text(primaryCurrency)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("預算")
                } footer: {
                    Text("選填，可用於追蹤支出進度")
                }
                
                    // MARK: - 幣別設置
                Section {
                    Picker("主要貨幣", selection: $primaryCurrency) {
                        ForEach(availableCurrencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("貨幣設置")
                } footer: {
                    Text("選擇此行程的主要貨幣")
                }
                
                    // MARK: - 匯率管理
                Section {
                    if exchangeRates.isEmpty {
                        Text("尚無匯率設置")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(exchangeRates.keys.sorted()), id: \.self) { currency in
                            HStack {
                                HStack(spacing: 4) {
                                    Text("1 \(currency)")
                                        .font(.subheadline)
                                    Text("=")
                                        .foregroundStyle(.secondary)
                                    Text(exchangeRates[currency] ?? "")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(primaryCurrency)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    exchangeRates.removeValue(forKey: currency)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    Button(action: { showingAddRate = true }) {
                        Label("新增匯率", systemImage: "plus.circle")
                    }
                } header: {
                    Text("匯率設置")
                } footer: {
                    Text("設置費用中使用的各種貨幣匯率")
                }
                
                    // MARK: - 備註
                Section("備註") {
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("編輯行程")
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
                loadTripData()
            }
            .sheet(isPresented: $showingAddRate) {
                AddExchangeRateSheet(
                    isPresented: $showingAddRate,
                    primaryCurrency: primaryCurrency,
                    availableCurrencies: availableCurrencies,
                    existingCurrencies: Set(exchangeRates.keys),
                    onAdd: { currency, rate in
                        exchangeRates[currency] = rate
                    }
                )
            }
        }
    }
    
        // MARK: - Load Data
    private func loadTripData() {
        name = trip.name
        destination = trip.destination ?? ""
        startDate = trip.startDate
        endDate = trip.endDate
        if let budget = trip.totalBudget {
            budgetString = String(format: "%.0f", budget)
        }
        notes = trip.notes ?? ""
        
            // ✅ 加載匯率
        primaryCurrency = trip.primaryCurrency
        exchangeRates = trip.exchangeRates.mapValues { String(format: "%.2f", $0) }
    }
    
        // MARK: - Save Changes
    private func saveChanges() {
        let calendar = Calendar.current
        
        trip.name = name.trimmingCharacters(in: .whitespaces)
        trip.destination = destination.trimmingCharacters(in: .whitespaces)
        trip.startDate = calendar.startOfDay(for: startDate)
        trip.endDate = calendar.startOfDay(for: endDate)
        trip.totalBudget = Double(budgetString)
        trip.notes = notes.isEmpty ? nil : notes
        
            // ✅ 保存匯率
        trip.primaryCurrency = primaryCurrency
        var rates: [String: Double] = [:]
        for (currency, rateString) in exchangeRates {
            if let rate = Double(rateString), rate > 0 {
                rates[currency] = rate
            }
        }
        trip.exchangeRates = rates
        
        print("✅ 行程已更新")
        print("   主貨幣：\(trip.primaryCurrency)")
        print("   匯率：\(trip.exchangeRates)")
        
        dismiss()
    }
}

    // MARK: - Add Exchange Rate Sheet 
struct AddExchangeRateSheet: View {
    @Binding var isPresented: Bool
    
    let primaryCurrency: String
    let availableCurrencies: [String]
    let existingCurrencies: Set<String>
    let onAdd: (String, String) -> Void
    
    @State private var selectedCurrency: String = ""
    @State private var customCurrency: String = ""
    @State private var rateString: String = ""
    @State private var useCustom: Bool = false
    
    private var isValid: Bool {
        let currency = useCustom ? customCurrency.uppercased() : selectedCurrency
        return !currency.isEmpty &&
        !rateString.isEmpty &&
        Double(rateString) ?? 0 > 0 &&
        !existingCurrencies.contains(currency) &&
        currency != primaryCurrency &&
        (useCustom ? customCurrency.count == 3 : true)
    }
    
    private var availableCurrenciesForPicker: [String] {
        availableCurrencies.filter { $0 != primaryCurrency && !existingCurrencies.contains($0) }
    }
    
    private var displayCurrency: String {
        useCustom ? customCurrency.uppercased() : selectedCurrency
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("選擇方式", selection: $useCustom) {
                        Text("從列表選擇").tag(false)
                        Text("自訂貨幣代碼").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    if useCustom {
                            // ✅ 自訂輸入
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("貨幣代碼（例如：CHF）", text: $customCurrency)
                                .textContentType(.none)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                                .onChange(of: customCurrency) { oldValue, newValue in
                                        // 限制長度為 3
                                    if newValue.count > 3 {
                                        customCurrency = String(newValue.prefix(3))
                                    }
                                }
                            
                            Text("輸入 3 位貨幣代碼（例如：CHF、AUD、CAD）")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                            // ✅ 從列表選擇
                        if availableCurrenciesForPicker.isEmpty {
                            Text("所有預設貨幣都已添加，請使用「自訂貨幣代碼」")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Picker("貨幣", selection: $selectedCurrency) {
                                ForEach(availableCurrenciesForPicker, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    
                    HStack {
                        Text("1 \(displayCurrency.isEmpty ? "XXX" : displayCurrency)")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("=")
                            .foregroundStyle(.secondary)
                        
                        TextField("輸入匯率", text: $rateString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        
                        Text(primaryCurrency)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("新增匯率")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        if let rate = Double(rateString), rate > 0 {
                            Text("預覽：1 \(displayCurrency.isEmpty ? "XXX" : displayCurrency) = \(String(format: "%.2f", rate)) \(primaryCurrency)")
                        }
                        if useCustom && customCurrency.count != 3 && !customCurrency.isEmpty {
                            Text("⚠️ 貨幣代碼必須是 3 位")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .navigationTitle("新增匯率")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("新增") {
                        let currency = useCustom ? customCurrency.uppercased() : selectedCurrency
                        onAdd(currency, rateString)
                        isPresented = false
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if selectedCurrency.isEmpty && !availableCurrenciesForPicker.isEmpty {
                    selectedCurrency = availableCurrenciesForPicker.first ?? ""
                }
            }
        }
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let trip = Trip(
        name: "東京出差",
        destination: "東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 3),
        totalBudget: 500000,
        primaryCurrency: "JPY"
    )
    trip.exchangeRates["USD"] = 100
    trip.exchangeRates["EUR"] = 120
    container.mainContext.insert(trip)
    
    return EditTripView(trip: trip)
        .modelContainer(container)
}

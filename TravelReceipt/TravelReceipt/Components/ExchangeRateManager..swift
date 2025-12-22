    //
    //  ExchangeRateManager.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/12/22.
    //

import SwiftUI

struct ExchangeRateManager: View {
    @State private var exchangeRates: [String: Double]
    @State private var newCurrency: String = "USD"
    @State private var newRate: String = ""
    @State private var showingAddCurrency = false
    
    let primaryCurrency: String
    let onSave: ([String: Double]) -> Void
    
    private let commonCurrencies = Constants.Currency.all
    
        // 獲取尚未添加的貨幣列表
    private var availableCurrencies: [String] {
        commonCurrencies.filter { currency in
            currency != primaryCurrency && !exchangeRates.keys.contains(currency)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                    // MARK: - 主貨幣顯示
                VStack(alignment: .leading, spacing: 12) {
                    Label("主貨幣", systemImage: "dollarsign.circle.fill")
                        .font(.headline)
                    
                    HStack {
                        Text(primaryCurrency)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        Text("所有費用將轉換為此貨幣")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(16)
                
                Divider()
                
                    // MARK: - 已添加的匯率列表
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("已添加的匯率", systemImage: "list.bullet.circle.fill")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(exchangeRates.count) 個")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if exchangeRates.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray.fill")
                                .font(.title2)
                                .foregroundStyle(.gray)
                            Text("還沒有添加匯率")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(Array(exchangeRates.sorted { $0.key < $1.key }), id: \.key) { currency, rate in
                                    ExchangeRateRowWithDelete(
                                        currency: currency,
                                        rate: rate,
                                        primaryCurrency: primaryCurrency,
                                        onDelete: {
                                            exchangeRates.removeValue(forKey: currency)
                                        },
                                        onEdit: { newRate in
                                            exchangeRates[currency] = newRate
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(16)
                
                Divider()
                
                    // MARK: - 添加新匯率
                VStack(alignment: .leading, spacing: 12) {
                    Label("添加新匯率", systemImage: "plus.circle.fill")
                        .font(.headline)
                    
                    if availableCurrencies.isEmpty {
                        Text("所有常用貨幣都已添加")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 12) {
                            Picker("貨幣", selection: $newCurrency) {
                                ForEach(availableCurrencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 100)
                            
                            TextField("匯率", text: $newRate)
                                .keyboardType(.decimalPad)
                                .placeholder(when: newRate.isEmpty) {
                                    Text("0.0").foregroundColor(.gray)
                                }
                            
                            Button(action: addNewRate) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                            }
                            .disabled(newRate.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(16)
                
                Spacer()
                
                    // MARK: - 保存按鈕
                VStack(spacing: 12) {
                    Button(action: {
                        onSave(exchangeRates)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("保存匯率")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(16)
            }
            .navigationTitle("匯率管理")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addNewRate() {
        guard let rate = Double(newRate.trimmingCharacters(in: .whitespaces)), rate > 0 else {
            return
        }
        
        exchangeRates[newCurrency] = rate
        newRate = ""
        
            // 如果所有貨幣皆已新增，則重置選擇
        if availableCurrencies.isEmpty {
            newCurrency = "USD"
        } else {
            newCurrency = availableCurrencies.first ?? "USD"
        }
        
        print("✅ 已添加匯率: 1 \(newCurrency) = \(rate) \(primaryCurrency)")
    }
    
    init(
        primaryCurrency: String,
        exchangeRates: [String: Double] = [:],
        onSave: @escaping ([String: Double]) -> Void
    ) {
        self.primaryCurrency = primaryCurrency
        self._exchangeRates = State(initialValue: exchangeRates)
        self.onSave = onSave
    }
}

    // MARK: - 帶刪除功能的匯率行
struct ExchangeRateRowWithDelete: View {
    let currency: String
    let rate: Double
    let primaryCurrency: String
    let onDelete: () -> Void
    let onEdit: (Double) -> Void
    
    @State private var rateText: String = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currency)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("1 \(currency) = \(String(format: "%.4f", rate)) \(primaryCurrency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                        // 編輯按鈕
                    Button(action: { isEditing = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                    
                        // 刪除按鈕
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(12)
            .background(.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .sheet(isPresented: $isEditing) {
            EditRateSheet(
                currency: currency,
                rate: rate,
                primaryCurrency: primaryCurrency,
                isPresented: $isEditing,
                onSave: { newRate in
                    onEdit(newRate)
                    isEditing = false
                }
            )
        }
    }
}

    // MARK: - 編輯匯率的 Sheet
struct EditRateSheet: View {
    let currency: String
    let rate: Double
    let primaryCurrency: String
    @Binding var isPresented: Bool
    let onSave: (Double) -> Void
    
    @State private var rateText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("編輯匯率")
                        .font(.headline)
                    
                    Text("1 \(currency) = ? \(primaryCurrency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    TextField("匯率", text: $rateText)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                    
                    Text(primaryCurrency)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                Button(action: {
                    if let newRate = Double(rateText), newRate > 0 {
                        onSave(newRate)
                    }
                }) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                .disabled(rateText.isEmpty || Double(rateText) == nil)
            }
            .padding(16)
            .navigationTitle("編輯匯率")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            rateText = String(format: "%.4f", rate)
        }
    }
}

    // MARK: - Helper for placeholder
extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

    // MARK: - 預覽
#Preview {
    ExchangeRateManager(
        primaryCurrency: "TWD",
        exchangeRates: ["USD": 31, "JPY": 0.2]
    ) { rates in
        print("保存的匯率: \(rates)")
    }
}

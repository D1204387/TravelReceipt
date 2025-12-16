    //
    //  AddExpenseView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let trip: Trip
    
        // MARK: - Form State
    @State private var amount: String = ""
    @State private var currency: String = "TWD"
    @State private var date: Date = Date()
    @State private var category: ExpenseCategory = .miscellaneous
    @State private var storeName: String = ""
    @State private var notes: String = ""
    
        // ✅ 收據圖片
    @State private var receiptImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPhotoSource = false
    
        // 常用貨幣
    private let currencies = ["TWD", "CNY", "JPY", "USD", "EUR", "HKD", "KRW"]
    
        // 驗證
    private var isValid: Bool {
        guard let value = Double(amount), value > 0 else {
            return false
        }
        return true
    }
    
        // 檢查日期是否在行程範圍內
    private var isDateOutOfRange: Bool {
        let calendar = Calendar.current
        let expenseDay = calendar.startOfDay(for: date)
        let tripStart = calendar.startOfDay(for: trip.startDate)
        let tripEnd = calendar.startOfDay(for: trip.endDate)
        return expenseDay < tripStart || expenseDay > tripEnd
    }
    
    var body: some View {
        NavigationStack {
            Form {
                    // MARK: - 收據照片
                Section {
                    HStack {
                            // 縮圖預覽
                        if let image = receiptImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 80)
                                .overlay {
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera")
                                            .font(.title2)
                                        Text("新增")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.gray)
                                }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Button(action: { showingPhotoSource = true }) {
                                Label("拍照/選擇", systemImage: "photo.badge.plus")
                            }
                            
                            if receiptImage != nil {
                                Button(role: .destructive, action: { receiptImage = nil }) {
                                    Label("移除照片", systemImage: "trash")
                                }
                                .foregroundStyle(.red)
                            }
                        }
                    }
                } header: {
                    Text("收據照片")
                } footer: {
                    Text("選填，可拍照或從相簿選取收據")
                }
                
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
                            Text("\(cat.icon) \(cat.displayName)")
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                    // MARK: - 詳細資訊
                Section {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    
                    if isDateOutOfRange {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text("費用日期不在行程期間內")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    TextField("商家名稱", text: $storeName)
                    
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("詳細資訊")
                } footer: {
                    Text("行程期間：\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) — \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .navigationTitle("新增費用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
            }
                // 選擇照片來源
            .confirmationDialog("選擇照片來源", isPresented: $showingPhotoSource) {
                Button("拍照") {
                    showingCamera = true
                }
                Button("從相簿選擇") {
                    showingImagePicker = true
                }
                Button("取消", role: .cancel) { }
            }
                // 相機
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker(image: $receiptImage)
                    .ignoresSafeArea()
            }
                // 相簿
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(image: $receiptImage)
            }
        }
    }
    
        // MARK: - Save Method
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
            // ✅ 壓縮圖片並轉換為 Data
        var imageData: Data? = nil
        if let image = receiptImage {
            imageData = image.jpegData(compressionQuality: 0.7)
        }
        
        let expense = Expense(
            amount: amountValue,
            currency: currency,
            date: date,
            storeName: storeName.isEmpty ? nil : storeName,
            notes: notes.isEmpty ? nil : notes,
            receiptImage: imageData,
            trip: trip,
            category: category
        )
        
        modelContext.insert(expense)
        trip.addExpense(expense)
        
        dismiss()
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let trip = Trip(
        name: "測試行程",
        destination: "東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 3)
    )
    container.mainContext.insert(trip)
    
    return AddExpenseView(trip: trip)
        .modelContainer(container)
}

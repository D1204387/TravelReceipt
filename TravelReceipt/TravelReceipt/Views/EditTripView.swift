//
//  EditTripView.swift
//  TravelReceipt
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
                        Text("元")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("預算")
                } footer: {
                    Text("選填，可用於追蹤支出進度")
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
        
        dismiss()
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
        totalBudget: 50000
    )
    container.mainContext.insert(trip)
    
    return EditTripView(trip: trip)
        .modelContainer(container)
}

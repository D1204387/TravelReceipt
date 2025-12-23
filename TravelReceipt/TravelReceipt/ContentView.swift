//
//  ContentView.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/12.
//

import SwiftUI
import SwiftData
import WidgetKit
import CloudKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @State private var showingAddTrip = false
    
    // 同步相關狀態
    @State private var isSyncing = false
    @State private var lastSyncTime: Date? = nil
    @State private var syncStatusMessage = ""
    @State private var showSyncStatus = false
    @State private var iCloudAvailable = false
    
    var body: some View {
        TabView {
            Tab("行程", systemImage: "list.bullet") {
                NavigationStack {
                    Group {
                        if trips.isEmpty {
                            EmptyStateView()
                        } else {
                            TripListView()
                        }
                    }
                    .navigationTitle("旅遊記帳")
                    .toolbar {
                        // 同步按鈕
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: syncWithCloud) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            .disabled(isSyncing || !iCloudAvailable)
                        }
                        // 新增行程按鈕
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showingAddTrip = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            
            Tab("統計", systemImage: "chart.pie") {
                NavigationStack {
                    StatisticsView()
                }
            }
            Tab("設定", systemImage: "gear") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView()
        }
        .onAppear {
            checkiCloudStatus()
        }
        .overlay {
            if showSyncStatus {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(syncStatusMessage)
                            .padding(8)
                            .background(.regularMaterial)
                            .cornerRadius(8)
                            .foregroundStyle(syncStatusMessage.contains("✅") ? .green : .orange)
                    }
                    .padding()
                }
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - iCloud 功能
    private func checkiCloudStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                iCloudAvailable = (status == .available)
                if let lastSync = UserDefaults.standard.object(forKey: "lastCloudSyncTime") as? Date {
                    lastSyncTime = lastSync
                }
            }
        }
    }
    
    private func syncWithCloud() {
        isSyncing = true
        showSyncStatus = false
        
        // 使用已有的 trips Query 資料
        let sharedData = trips.map { trip -> SharedTripData in
            var categoryBreakdown: [String: Double] = [:]
            if let expenses = trip.expenses {
                for expense in expenses {
                    let converted = trip.convertToPrimaryCurrency(amount: expense.amount, from: expense.currency)
                    categoryBreakdown[expense.category.displayName, default: 0] += converted
                }
            }
            return SharedTripData(
                id: trip.id,
                name: trip.name,
                destination: trip.destination,
                startDate: trip.startDate,
                endDate: trip.endDate,
                totalExpenses: trip.totalExpensesInPrimaryCurrency,
                expenseCount: trip.expenses?.count ?? 0,
                primaryCurrency: trip.primaryCurrency,
                categoryBreakdown: categoryBreakdown
            )
        }
        
        SharedDataManager.saveTripData(sharedData)
        WidgetCenter.shared.reloadAllTimelines()
        lastSyncTime = Date()
        UserDefaults.standard.set(lastSyncTime, forKey: "lastCloudSyncTime")
        syncStatusMessage = "✅ 同步完成"
        
        isSyncing = false
        showSyncStatus = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showSyncStatus = false
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("開始您的第一趟旅程")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("點擊右上角的 + 來新增行程")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview {
    ContentView()
        .modelContainer(try! ModelContainer(for: Trip.self, Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
}

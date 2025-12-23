//
//  TripListView.swift
//  TravelReceipt
//
//  Created by YiJou on 2025/11/14.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    
    @State private var tripToEdit: Trip? = nil
    @State private var selectedSegment: TripSegment = .all
    @State private var searchText: String = ""
    
    // 行程分段
    enum TripSegment: String, CaseIterable {
        case all = "全部"
        case active = "進行中"
        case upcoming = "即將開始"
        case past = "已結束"
    }
    
    // 根據分段和搜尋篩選行程
    var filteredTrips: [Trip] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        var result: [Trip]
        
        switch selectedSegment {
        case .all:
            result = trips
        case .active:
            result = trips.filter { trip in
                let start = calendar.startOfDay(for: trip.startDate)
                let end = calendar.startOfDay(for: trip.endDate)
                return start <= today && end >= today
            }
        case .upcoming:
            result = trips.filter { trip in
                let start = calendar.startOfDay(for: trip.startDate)
                return start > today
            }
        case .past:
            result = trips.filter { trip in
                let end = calendar.startOfDay(for: trip.endDate)
                return end < today
            }
        }
        
        // 搜尋過濾
        if !searchText.isEmpty {
            result = result.filter { trip in
                trip.name.localizedCaseInsensitiveContains(searchText) ||
                (trip.destination?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 分段選擇器
            Picker("篩選", selection: $selectedSegment) {
                ForEach(TripSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // 行程列表
            if filteredTrips.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: segmentIcon)
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                    Text(emptyMessage)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredTrips, id: \.id) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            TripRowView(trip: trip)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                tripToEdit = trip
                            } label: {
                                Label("編輯", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deleteTrips)
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "搜尋行程名稱或目的地")
        .sheet(item: $tripToEdit) { trip in
            EditTripView(trip: trip)
        }
    }
    
    private var segmentIcon: String {
        switch selectedSegment {
        case .all: return "list.bullet"
        case .active: return "airplane.departure"
        case .upcoming: return "calendar"
        case .past: return "checkmark.circle"
        }
    }
    
    private var emptyMessage: String {
        if !searchText.isEmpty {
            return "找不到符合「\(searchText)」的行程"
        }
        switch selectedSegment {
        case .all: return "尚無任何行程"
        case .active: return "目前沒有進行中的行程"
        case .upcoming: return "沒有即將開始的行程"
        case .past: return "沒有已結束的行程"
        }
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        let tripsToDelete = offsets.map { filteredTrips[$0] }
        for trip in tripsToDelete {
            modelContext.delete(trip)
        }
    }
}

// MARK: - Trip Row View
struct TripRowView: View {
    let trip: Trip
    
    private var tripStatus: (text: String, color: Color) {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let start = calendar.startOfDay(for: trip.startDate)
        let end = calendar.startOfDay(for: trip.endDate)
        
        if start <= today && end >= today {
            return ("進行中", .green)
        } else if start > today {
            return ("即將開始", .blue)
        } else {
            return ("已結束", .gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                    .font(.headline)
                
                Spacer()
                
                Text(tripStatus.text)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tripStatus.color.opacity(0.15))
                    .foregroundStyle(tripStatus.color)
                    .clipShape(Capsule())
            }
            
            Text(trip.destination ?? "未知目的地")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                Text("—")
                Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        TripListView()
    }
    .modelContainer(for: [Trip.self, Expense.self], inMemory: true)
}

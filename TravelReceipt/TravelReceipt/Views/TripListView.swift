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
    
    var body: some View {
        List {
            ForEach(trips, id: \.id) { trip in
                NavigationLink(destination: TripDetailView(trip: trip)) {
                    TripRowView(trip: trip)
                }
                    // ✅ 加入右滑選單
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
        .sheet(item: $tripToEdit) { trip in
            EditTripView(trip: trip)
        }
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
    }
}

    // MARK: - Trip Row View
struct TripRowView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                .font(.headline)
            
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

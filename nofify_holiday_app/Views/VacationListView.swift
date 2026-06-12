import SwiftUI
import WidgetKit

struct VacationListView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            Group {
                if store.vacations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "suitcase")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("등록된 휴가가 없어요")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Button("휴가 추가하기") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.vacations) { vacation in
                            VacationRow(vacation: vacation)
                        }
                        .onDelete(perform: deleteVacation)
                    }
                }
            }
            .navigationTitle("내 휴가")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddVacationView { vacation in
                    store.vacations.append(vacation)
                    store.vacations.sort { $0.startDate < $1.startDate }
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }

    private func deleteVacation(at offsets: IndexSet) {
        store.vacations.remove(atOffsets: offsets)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct VacationRow: View {
    let vacation: PersonalVacation

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        let start = formatter.string(from: vacation.startDate)
        let end = formatter.string(from: vacation.endDate)
        return "\(start) ~ \(end)"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(vacation.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(dateRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let days = vacation.daysUntilStart {
                Text(days == 0 ? "오늘!" : "D-\(days)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(days <= 7 ? .red : .blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill((days <= 7 ? Color.red : Color.blue).opacity(0.1))
                    )
            } else {
                Text("지남")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddVacationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 3)

    let onAdd: (PersonalVacation) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("휴가 이름") {
                    TextField("예: 여름 휴가", text: $name)
                }

                Section("기간") {
                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                    DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("휴가 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let vacation = PersonalVacation(
                            name: name,
                            startDate: startDate,
                            endDate: endDate
                        )
                        onAdd(vacation)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

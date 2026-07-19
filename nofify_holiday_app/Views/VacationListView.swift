import SwiftUI
import WidgetKit

struct VacationListView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddSheet = false

    var body: some View {
        let l = store.l10n
        NavigationView {
            Group {
                if store.vacations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "suitcase")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text(l.noVacations)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Button(l.addVacationCTA) {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.vacations) { vacation in
                            VacationRow(vacation: vacation, l: l)
                        }
                        .onDelete(perform: deleteVacation)
                    }
                }
            }
            .navigationTitle(l.tabVacation)
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
                AddVacationView(l: l) { vacation in
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
    let l: L10n

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
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
                Text(days == 0 ? l.today : "D-\(days)")
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
                Text(l.past)
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

    let l: L10n
    let onAdd: (PersonalVacation) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(l.vacationName) {
                    TextField(l.vacationNamePlaceholder, text: $name)
                }

                Section(l.period) {
                    DatePicker(l.startDate, selection: $startDate, displayedComponents: .date)
                    DatePicker(l.endDate, selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle(l.addVacationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(l.cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(l.add) {
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

import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var store: DataStore
    @State private var upcomingHolidays: [PublicHoliday] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        let l = store.l10n
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    DDayCard(info: store.nextHoliday, l: l)
                        .padding(.horizontal)

                    if !upcomingHolidays.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(l.upcomingHolidays)
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(upcomingHolidays.prefix(5)) { holiday in
                                HolidayRow(holiday: holiday, l: l)
                            }
                        }
                    }

                    if isLoading {
                        ProgressView(l.loadingHolidays)
                            .padding()
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(l.countryHolidays(store.countryName))
            .task { await loadHolidays() }
            .onChange(of: store.countryCode) { _ in
                Task { await loadHolidays() }
            }
            .onChange(of: store.language) { _ in
                // Trigger re-render on language change
            }
        }
    }

    private func loadHolidays() async {
        isLoading = true
        errorMessage = nil
        do {
            let year = Calendar.current.component(.year, from: Date())
            var holidays = try await HolidayService.shared.fetchHolidays(countryCode: store.countryCode, year: year)

            let month = Calendar.current.component(.month, from: Date())
            if month >= 11 {
                let nextYear = try await HolidayService.shared.fetchHolidays(countryCode: store.countryCode, year: year + 1)
                holidays += nextYear
            }

            let today = Calendar.current.startOfDay(for: Date())
            upcomingHolidays = holidays.filter {
                guard let d = $0.dateValue else { return false }
                return Calendar.current.startOfDay(for: d) >= today
            }

            let nextInfo = HolidayService.shared.resolveNextEvent(
                holidays: holidays,
                vacations: store.vacations
            )
            await MainActor.run {
                store.nextHoliday = nextInfo
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            await MainActor.run {
                errorMessage = store.l10n.holidayLoadError(error.localizedDescription)
            }
        }
        await MainActor.run { isLoading = false }
    }
}

struct DDayCard: View {
    let info: NextHolidayInfo?
    let l: L10n

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let info = info {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: info.isPersonal ? "suitcase.fill" : "calendar")
                            .foregroundColor(.white.opacity(0.8))
                        Text(info.isPersonal ? l.myVacation : l.publicHoliday)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }

                    Text(info.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(alignment: .bottom) {
                        Text(info.daysRemaining == 0 ? l.dDay : "D-\(info.daysRemaining)")
                            .font(.system(size: 52, weight: .black))
                            .foregroundColor(.white)

                        Spacer()

                        Text(info.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(20)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.6))
                    Text(l.noUpcomingHoliday)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .padding(20)
            }
        }
        .frame(height: 160)
    }
}

struct HolidayRow: View {
    let holiday: PublicHoliday
    let l: L10n

    var daysLeft: Int? {
        guard let d = holiday.dateValue else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: d)
        return Calendar.current.dateComponents([.day], from: today, to: target).day
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(holiday.localName)
                    .font(.body)
                    .fontWeight(.medium)
                Text(holiday.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let days = daysLeft {
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
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var store: DataStore
    @State private var upcomingHolidays: [PublicHoliday] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    DDayCard(info: store.nextHoliday)
                        .padding(.horizontal)

                    if !upcomingHolidays.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("다가오는 공휴일")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(upcomingHolidays.prefix(5)) { holiday in
                                HolidayRow(holiday: holiday)
                            }
                        }
                    }

                    if isLoading {
                        ProgressView("공휴일 불러오는 중...")
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
            .navigationTitle("\(store.countryName) 공휴일")
            .task { await loadHolidays() }
            .onChange(of: store.countryCode) { _ in
                Task { await loadHolidays() }
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
                errorMessage = "공휴일 정보를 가져오지 못했어요: \(error.localizedDescription)"
            }
        }
        await MainActor.run { isLoading = false }
    }
}

struct DDayCard: View {
    let info: NextHolidayInfo?

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
                        Text(info.isPersonal ? "내 휴가" : "공휴일")
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
                        Group {
                            if info.daysRemaining == 0 {
                                Text("D-Day!")
                            } else {
                                Text("D-\(info.daysRemaining)")
                            }
                        }
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
                    Text("다가오는 휴일 없음")
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
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

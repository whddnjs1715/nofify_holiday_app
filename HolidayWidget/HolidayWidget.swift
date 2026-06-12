import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct HolidayEntry: TimelineEntry {
    let date: Date
    let nextHoliday: NextHolidayInfo?
    let countryName: String
}

struct HolidayProvider: TimelineProvider {
    func placeholder(in context: Context) -> HolidayEntry {
        HolidayEntry(
            date: Date(),
            nextHoliday: NextHolidayInfo(
                name: "크리스마스",
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                isPersonal: false
            ),
            countryName: "대한민국"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HolidayEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HolidayEntry>) -> Void) {
        let entry = makeEntry()
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func makeEntry() -> HolidayEntry {
        let defaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard
        let countryName = defaults.string(forKey: UserDefaultsKeys.countryName) ?? "대한민국"
        let nextHoliday: NextHolidayInfo? = {
            guard let data = defaults.data(forKey: UserDefaultsKeys.nextHoliday),
                  let info = try? JSONDecoder().decode(NextHolidayInfo.self, from: data)
            else { return nil }
            return info.daysRemaining >= 0 ? info : nil
        }()
        return HolidayEntry(date: Date(), nextHoliday: nextHoliday, countryName: countryName)
    }
}

// MARK: - Widget Views

struct HolidayWidgetEntryView: View {
    var entry: HolidayProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: HolidayEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let info = entry.nextHoliday {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: info.isPersonal ? "suitcase.fill" : "calendar")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        Text(info.isPersonal ? "내 휴가" : "공휴일")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }

                    Spacer()

                    Text(info.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Group {
                        if info.daysRemaining == 0 {
                            Text("D-Day!")
                        } else {
                            Text("D-\(info.daysRemaining)")
                        }
                    }
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.white)
                }
                .padding(12)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                    Text("휴일 없음")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct MediumWidgetView: View {
    let entry: HolidayEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if let info = entry.nextHoliday {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: info.isPersonal ? "suitcase.fill" : "calendar")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(info.isPersonal ? "내 휴가" : "\(entry.countryName) 공휴일")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Text(info.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(info.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    VStack {
                        Group {
                            if info.daysRemaining == 0 {
                                Text("D-Day!")
                                    .font(.system(size: 28, weight: .black))
                            } else {
                                VStack(spacing: 0) {
                                    Text("D-")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("\(info.daysRemaining)")
                                        .font(.system(size: 44, weight: .black))
                                }
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(16)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                    Text("다가오는 휴일이 없습니다")
                        .font(.callout)
                        .foregroundColor(.white)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Widget Configuration

@main
struct HolidayWidget: Widget {
    let kind: String = "HolidayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HolidayProvider()) { entry in
            HolidayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("다음 휴일까지")
        .description("다음 공휴일 또는 개인 휴가까지 남은 날짜를 표시합니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    HolidayWidget()
} timeline: {
    HolidayEntry(
        date: .now,
        nextHoliday: NextHolidayInfo(
            name: "크리스마스",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            isPersonal: false
        ),
        countryName: "대한민국"
    )
    HolidayEntry(
        date: .now,
        nextHoliday: NextHolidayInfo(
            name: "여름 휴가",
            date: Calendar.current.date(byAdding: .day, value: 23, to: Date())!,
            isPersonal: true
        ),
        countryName: "대한민국"
    )
}

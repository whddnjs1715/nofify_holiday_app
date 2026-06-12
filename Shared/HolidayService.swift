import Foundation

class HolidayService {
    static let shared = HolidayService()
    private let baseURL = "https://date.nager.at/api/v3"

    func fetchHolidays(countryCode: String, year: Int) async throws -> [PublicHoliday] {
        guard let url = URL(string: "\(baseURL)/PublicHolidays/\(year)/\(countryCode)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let holidays = try JSONDecoder().decode([PublicHoliday].self, from: data)
        return holidays
    }

    func nextHoliday(from holidays: [PublicHoliday]) -> PublicHoliday? {
        let today = Calendar.current.startOfDay(for: Date())
        return holidays
            .filter { h in
                guard let d = h.dateValue else { return false }
                return Calendar.current.startOfDay(for: d) > today
            }
            .min { a, b in
                guard let da = a.dateValue, let db = b.dateValue else { return false }
                return da < db
            }
    }

    func resolveNextEvent(
        holidays: [PublicHoliday],
        vacations: [PersonalVacation]
    ) -> NextHolidayInfo? {
        let today = Calendar.current.startOfDay(for: Date())
        var candidates: [NextHolidayInfo] = []

        if let ph = nextHoliday(from: holidays), let d = ph.dateValue {
            candidates.append(NextHolidayInfo(name: ph.localName, date: d, isPersonal: false))
        }

        for v in vacations {
            let start = Calendar.current.startOfDay(for: v.startDate)
            if start > today {
                candidates.append(NextHolidayInfo(name: v.name, date: v.startDate, isPersonal: true))
            }
        }

        return candidates.min { $0.date < $1.date }
    }
}

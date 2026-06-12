import Foundation

struct PublicHoliday: Codable, Identifiable {
    let id = UUID()
    let date: String
    let localName: String
    let name: String
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case date, localName, name, countryCode
    }

    var dateValue: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: date)
    }
}

struct PersonalVacation: Codable, Identifiable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date

    var daysUntilStart: Int? {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let components = Calendar.current.dateComponents([.day], from: today, to: start)
        guard let days = components.day, days >= 0 else { return nil }
        return days
    }
}

struct NextHolidayInfo: Codable {
    let name: String
    let date: Date
    let isPersonal: Bool

    var daysRemaining: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: date)
        let components = Calendar.current.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }
}

struct Country: Identifiable, Hashable {
    let id: String
    let name: String
}

extension Country {
    static let popular: [Country] = [
        Country(id: "KR", name: "대한민국"),
        Country(id: "US", name: "미국"),
        Country(id: "JP", name: "일본"),
        Country(id: "GB", name: "영국"),
        Country(id: "DE", name: "독일"),
        Country(id: "FR", name: "프랑스"),
        Country(id: "ES", name: "스페인"),
        Country(id: "IT", name: "이탈리아"),
        Country(id: "CA", name: "캐나다"),
        Country(id: "AU", name: "호주"),
        Country(id: "CN", name: "중국"),
        Country(id: "SG", name: "싱가포르"),
        Country(id: "TH", name: "태국"),
        Country(id: "VN", name: "베트남"),
        Country(id: "PH", name: "필리핀"),
    ]
}

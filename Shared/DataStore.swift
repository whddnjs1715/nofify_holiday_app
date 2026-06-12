import Foundation

class DataStore: ObservableObject {
    static let shared = DataStore()

    private let defaults: UserDefaults

    @Published var countryCode: String {
        didSet { defaults.set(countryCode, forKey: UserDefaultsKeys.countryCode) }
    }
    @Published var countryName: String {
        didSet { defaults.set(countryName, forKey: UserDefaultsKeys.countryName) }
    }
    @Published var vacations: [PersonalVacation] {
        didSet { save(vacations, forKey: UserDefaultsKeys.vacations) }
    }
    @Published var nextHoliday: NextHolidayInfo? {
        didSet {
            if let info = nextHoliday { save(info, forKey: UserDefaultsKeys.nextHoliday) }
        }
    }

    init() {
        self.defaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard
        self.countryCode = defaults.string(forKey: UserDefaultsKeys.countryCode) ?? "KR"
        self.countryName = defaults.string(forKey: UserDefaultsKeys.countryName) ?? "대한민국"
        self.vacations = DataStore.load([PersonalVacation].self, forKey: UserDefaultsKeys.vacations, from: defaults) ?? []
        self.nextHoliday = DataStore.load(NextHolidayInfo.self, forKey: UserDefaultsKeys.nextHoliday, from: defaults)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

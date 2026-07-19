import Foundation

enum AppLanguage: String, CaseIterable, Codable {
    case korean = "ko"
    case english = "en"
    case spanish = "es"

    var displayName: String {
        switch self {
        case .korean:  return "한국어"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

struct L10n {
    let lang: AppLanguage

    // MARK: - Tab Bar
    var tabHome: String        { pick("홈", "Home", "Inicio") }
    var tabVacation: String    { pick("내 휴가", "My Vacation", "Mis Vacaciones") }
    var tabSettings: String    { pick("설정", "Settings", "Ajustes") }

    // MARK: - Home
    var upcomingHolidays: String   { pick("다가오는 공휴일", "Upcoming Holidays", "Próximos Festivos") }
    var loadingHolidays: String    { pick("공휴일 불러오는 중...", "Loading holidays...", "Cargando festivos...") }
    var noUpcomingHoliday: String  { pick("다가오는 휴일 없음", "No upcoming holidays", "Sin festivos próximos") }
    var noUpcomingHolidayLong: String { pick("다가오는 휴일이 없습니다", "No upcoming holidays", "Sin festivos próximos") }
    var publicHoliday: String      { pick("공휴일", "Public Holiday", "Festivo") }
    var myVacation: String         { pick("내 휴가", "My Vacation", "Mis Vacaciones") }
    var today: String              { pick("오늘!", "Today!", "¡Hoy!") }
    var dDay: String               { pick("D-Day!", "D-Day!", "¡D-Day!") }
    func holidayLoadError(_ msg: String) -> String {
        pick("공휴일 정보를 가져오지 못했어요: \(msg)",
             "Failed to load holidays: \(msg)",
             "Error al cargar festivos: \(msg)")
    }
    func countryHolidays(_ name: String) -> String {
        pick("\(name) 공휴일", "\(name) Holidays", "Festivos de \(name)")
    }

    // MARK: - Vacation List
    var noVacations: String        { pick("등록된 휴가가 없어요", "No vacations added", "Sin vacaciones registradas") }
    var addVacationCTA: String     { pick("휴가 추가하기", "Add Vacation", "Añadir Vacaciones") }
    var past: String               { pick("지남", "Past", "Pasado") }
    var addVacationTitle: String   { pick("휴가 추가", "Add Vacation", "Añadir Vacaciones") }
    var vacationName: String       { pick("휴가 이름", "Vacation Name", "Nombre de Vacaciones") }
    var vacationNamePlaceholder: String { pick("예: 여름 휴가", "e.g. Summer vacation", "ej. Vacaciones de verano") }
    var period: String             { pick("기간", "Duration", "Duración") }
    var startDate: String          { pick("시작일", "Start Date", "Fecha de Inicio") }
    var endDate: String            { pick("종료일", "End Date", "Fecha de Fin") }
    var cancel: String             { pick("취소", "Cancel", "Cancelar") }
    var add: String                { pick("추가", "Add", "Añadir") }

    // MARK: - Settings
    var selectedCountry: String    { pick("현재 선택된 나라", "Selected Country", "País Seleccionado") }
    var selectCountry: String      { pick("나라 선택", "Select Country", "Seleccionar País") }
    var searchCountry: String      { pick("나라 검색", "Search country", "Buscar país") }
    var dataSource: String         { pick("공휴일 데이터 출처: Nager.Date API",
                                         "Holiday data: Nager.Date API",
                                         "Datos de festivos: Nager.Date API") }
    var language: String           { pick("언어", "Language", "Idioma") }
    var noHoliday: String          { pick("휴일 없음", "No Holiday", "Sin Festivo") }

    // MARK: - Helper
    private func pick(_ ko: String, _ en: String, _ es: String) -> String {
        switch lang {
        case .korean:  return ko
        case .english: return en
        case .spanish: return es
        }
    }
}

extension Country {
    static func localizedName(code: String, language: AppLanguage) -> String? {
        let englishNames: [String: String] = [
            "KR": "South Korea", "US": "United States", "JP": "Japan",
            "GB": "United Kingdom", "DE": "Germany", "FR": "France",
            "ES": "Spain", "IT": "Italy", "CA": "Canada", "AU": "Australia",
            "CN": "China", "SG": "Singapore", "TH": "Thailand",
            "VN": "Vietnam", "PH": "Philippines",
        ]
        let spanishNames: [String: String] = [
            "KR": "Corea del Sur", "US": "Estados Unidos", "JP": "Japón",
            "GB": "Reino Unido", "DE": "Alemania", "FR": "Francia",
            "ES": "España", "IT": "Italia", "CA": "Canadá", "AU": "Australia",
            "CN": "China", "SG": "Singapur", "TH": "Tailandia",
            "VN": "Vietnam", "PH": "Filipinas",
        ]
        switch language {
        case .english: return englishNames[code]
        case .spanish: return spanishNames[code]
        case .korean:  return nil
        }
    }
}

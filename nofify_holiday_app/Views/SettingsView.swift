import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var store: DataStore
    @State private var searchText = ""

    private var filteredCountries: [Country] {
        let countries = Country.popular.map { country -> Country in
            let localizedName = Country.localizedName(code: country.id, language: store.language) ?? country.name
            return Country(id: country.id, name: localizedName)
        }
        if searchText.isEmpty { return countries }
        return countries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        let l = store.l10n
        NavigationView {
            Form {
                // Language picker
                Section(header: Text(l.language)) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Button {
                            store.language = lang
                            // Update country name to match new language
                            if let localized = Country.localizedName(code: store.countryCode, language: lang) {
                                store.countryName = localized
                            } else {
                                // Fall back to Korean name
                                store.countryName = Country.popular.first(where: { $0.id == store.countryCode })?.name ?? store.countryName
                            }
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text(lang.displayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if store.language == lang {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                // Country picker
                Section(header: Text(l.selectedCountry)) {
                    HStack {
                        Text(store.countryName)
                            .font(.headline)
                        Spacer()
                        Text(store.countryCode)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                }

                Section(header: Text(l.selectCountry)) {
                    ForEach(filteredCountries) { country in
                        Button {
                            store.countryCode = country.id
                            store.countryName = country.name
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text(country.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(country.id)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if store.countryCode == country.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section {
                    Text(l.dataSource)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .searchable(text: $searchText, prompt: l.searchCountry)
            .navigationTitle(l.tabSettings)
        }
    }
}

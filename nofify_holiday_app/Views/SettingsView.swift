import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var store: DataStore
    @State private var searchText = ""

    private var filteredCountries: [Country] {
        if searchText.isEmpty { return Country.popular }
        return Country.popular.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("현재 선택된 나라")) {
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

                Section(header: Text("나라 선택")) {
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
                    Text("공휴일 데이터 출처: Nager.Date API")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .searchable(text: $searchText, prompt: "나라 검색")
            .navigationTitle("설정")
        }
    }
}

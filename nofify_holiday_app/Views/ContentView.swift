import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: DataStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(store.l10n.tabHome, systemImage: "house.fill")
                }

            VacationListView()
                .tabItem {
                    Label(store.l10n.tabVacation, systemImage: "suitcase.fill")
                }

            SettingsView()
                .tabItem {
                    Label(store.l10n.tabSettings, systemImage: "gearshape.fill")
                }
        }
    }
}

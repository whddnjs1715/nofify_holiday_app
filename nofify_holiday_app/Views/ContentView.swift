import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: DataStore

    var body: some View {
        let l = store.l10n
        return TabView {
            HomeView()
                .tabItem {
                    Label(l.tabHome, systemImage: "house.fill")
                }

            VacationListView()
                .tabItem {
                    Label(l.tabVacation, systemImage: "suitcase.fill")
                }

            SettingsView()
                .tabItem {
                    Label(l.tabSettings, systemImage: "gearshape.fill")
                }
        }
    }
}

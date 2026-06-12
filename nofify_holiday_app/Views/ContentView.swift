import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: DataStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            VacationListView()
                .tabItem {
                    Label("내 휴가", systemImage: "suitcase.fill")
                }

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
        }
    }
}

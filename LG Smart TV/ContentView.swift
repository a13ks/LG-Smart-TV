import SwiftUI

struct ContentView: View {
    static let suiteName = "group.org.a13ks.lgtv"

    @AppStorage("ipAddress", store: UserDefaults(suiteName: suiteName))
    var ipAddress: String = ""
    
    @AppStorage("clientKey", store: UserDefaults(suiteName: suiteName))
    var clientKey: String = ""
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

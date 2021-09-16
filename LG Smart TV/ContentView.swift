import SwiftUI

struct ContentView: View {
    static let suiteName = "group.org.a13ks.lgtv"

    @AppStorage("ipAddress", store: UserDefaults(suiteName: suiteName))
    var ipAddress: String = ""
    
    @AppStorage("clientKey", store: UserDefaults(suiteName: suiteName))
    var clientKey: String = ""
    
    @State
    var userInput: String = ""
    
    init() {
        let userDefaults = UserDefaults(suiteName: ContentView.suiteName)
        userInput = (userDefaults?.string(forKey: "ipAddress"))!
    }
    
    var body: some View {
        if clientKey.isEmpty {
            VStack {
                Spacer().frame(height: 10)
                Text("Enter IP address of TV").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer().frame(height: 10)
                TextField("IP address", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer().frame(height: 10)
                Button("Pair") {
                    
                }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
        } else {
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

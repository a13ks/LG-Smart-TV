import SwiftUI

struct ContentView: View, WebSocketConnectionDelegate {
    func onPaired(connection: WebSocketConnection, clientKey: String) {
        self.clientKey = clientKey
        print("paired")
        
        if !openUrlWhenPaired.isEmpty {
            connection.openUrl(url: openUrlWhenPaired)
            self.openUrlWhenPaired = ""
        }
    }
    
    func onConnected(connection: WebSocketConnection) {
        print("connected")
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("disconnected")
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print("error occurred")
    }
    
    func onMessage(connection: WebSocketConnection, text: String) {
        print("got message")
    }
    
    static let suiteName = "group.org.a13ks.lgtv"

    @AppStorage("ipAddress", store: UserDefaults(suiteName: suiteName))
    var ipAddress: String = ""
    
    @AppStorage("clientKey", store: UserDefaults(suiteName: suiteName))
    var clientKey: String = ""
    
    @State
    var userInput: String = ""
    
    @State
    var userInputUrl: String = ""
    
    @State
    var tvWebSocket: WebSocketConnection?
    
    @State
    var openUrlWhenPaired: String = ""
    
    init() {
        let userDefaults = UserDefaults(suiteName: ContentView.suiteName)
        
        if userDefaults != nil {
            var ip = (userDefaults?.string(forKey: "ipAddress"))
            if ip != nil {
                userInput = ip!
            }
        }
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
                    self.ipAddress = userInput
                    let url = URL(string: "ws://\(userInput):3000")
                    self.tvWebSocket = WebSocketTaskConnection(url: url!)

                    self.tvWebSocket?.delegate = self
                    
                    self.tvWebSocket?.connect()
                    self.tvWebSocket?.register()
                }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
        } else {
            VStack {
                Spacer().frame(height: 10)
                Text("TV Paired").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer().frame(height: 10)
                Text(ipAddress).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                TextField("URL", text: $userInputUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer().frame(height: 10)
                Button("Go to website") {
                    if tvWebSocket == nil {
                        let url = URL(string: "ws://\(ipAddress):3000")
                        self.tvWebSocket = WebSocketTaskConnection(url: url!)

                        self.tvWebSocket?.delegate = self

                        self.tvWebSocket?.connect()
                        
                        self.openUrlWhenPaired = userInputUrl
                        self.tvWebSocket?.register(clientKey: self.clientKey)
                    } else {
                        self.tvWebSocket?.openUrl(url: userInputUrl)
                    }
                }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer().frame(height: 30)
                Spacer().frame(height: 10)
                Button("Pair with other TV") {
                    clientKey = ""
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

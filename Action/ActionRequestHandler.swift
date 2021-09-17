import UIKit
import MobileCoreServices
import Common

class ActionRequestHandler: NSObject, NSExtensionRequestHandling, WebSocketConnectionDelegate {
    func onConnected(connection: WebSocketConnection) {
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
    }
    
    func onMessage(connection: WebSocketConnection, text: String) {
    }
    
    func onPaired(connection: WebSocketConnection, clientKey: String) {
        if !openUrlWhenPaired.isEmpty {
            self.tvWebSocket?.openUrl(url: openUrlWhenPaired)
            openUrlWhenPaired = ""
        }
    }
    

    static let suiteName = "group.org.a13ks.lgtv"
    var extensionContext: NSExtensionContext?
    var tvWebSocket: WebSocketConnection?
    var openUrlWhenPaired: String = ""
    
    func beginRequest(with context: NSExtensionContext) {
        // Do not call super in an Action extension with no user interface
        self.extensionContext = context
        
        var found = false
        
        // Find the item containing the results from the JavaScript preprocessing.
        outer:
            for item in context.inputItems as! [NSExtensionItem] {
                if let attachments = item.attachments {
                    for itemProvider in attachments {
                        if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                            itemProvider.loadItem(forTypeIdentifier: String(kUTTypePropertyList), options: nil, completionHandler: { (item, error) in
                                let dictionary = item as! [String: Any]
                                OperationQueue.main.addOperation {
                                    self.itemLoadCompletedWithPreprocessingResults(dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! [String: Any]? ?? [:])
                                }
                            })
                            found = true
                            break outer
                        }
                    }
                }
        }
        
        if !found {
            self.doneWithResults(nil)
        }
    }
    
    func itemLoadCompletedWithPreprocessingResults(_ javaScriptPreprocessingResults: [String: Any]) {
        let userDefaults = UserDefaults(suiteName: ActionRequestHandler.suiteName)
        
        self.openUrlWhenPaired = javaScriptPreprocessingResults["currentUrl"] as! String
        var clientKey = ""
        var ipAddress = ""
        if userDefaults != nil {
            ipAddress = (userDefaults?.string(forKey: "ipAddress"))!;
            clientKey = (userDefaults?.string(forKey: "clientKey"))!;
            
            let tvUrl = URL(string: "ws://\(ipAddress):3000")
            self.tvWebSocket = WebSocketTaskConnection(url: tvUrl!)

            self.tvWebSocket?.delegate = self
            self.tvWebSocket?.connect()
            self.tvWebSocket?.register(clientKey: clientKey)
        }

        
    }
    
    func doneWithResults(_ resultsForJavaScriptFinalizeArg: [String: Any]?) {
        if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
            // Construct an NSExtensionItem of the appropriate type to return our
            // results dictionary in.
            
            // These will be used as the arguments to the JavaScript finalize()
            // method.
            
            let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
            
            let resultsProvider = NSItemProvider(item: resultsDictionary as NSDictionary, typeIdentifier: String(kUTTypePropertyList))
            
            let resultsItem = NSExtensionItem()
            resultsItem.attachments = [resultsProvider]
            
            // Signal that we're complete, returning our results.
            self.extensionContext!.completeRequest(returningItems: [resultsItem], completionHandler: nil)
        } else {
            // We still need to signal that we're done even if we have nothing to
            // pass back.
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        // Don't hold on to this after we finished with it.
        self.extensionContext = nil
    }

}

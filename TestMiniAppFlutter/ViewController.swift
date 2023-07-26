import UIKit
import WebKit
import AVFoundation
import WKWebViewRTC

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    @IBOutlet weak var lastValueLabel: UILabel!
    var webView: WKWebView!
    @IBOutlet weak var tfCounter: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
    }
    
    @IBAction func addWebViewACtion(_ sender: Any) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.userContentController.add(self, name: "dataReceiver")
        webConfiguration.userContentController.add(self, name: "closeTrigger")
        
        webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.addSubview(webView)
        
        _ = WKWebViewRTC(wkwebview: webView, contentController: webView.configuration.userContentController)
        
        webView.load(URLRequest(url: URL(string: "http://10.124.56.41:8000")!))
    }
    
    func sendDataToFlutterWeb() {
        let counterInt = Int(tfCounter.text ?? "0") ?? 0
        webView.evaluateJavaScript("receiveDataFromiOS('\(counterInt)');")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "dataReceiver", let messageBody = message.body as? Int {
            lastValueLabel.text = "Last value: \(messageBody)"
        } else if message.name == "closeTrigger" {
            webView.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.sendDataToFlutterWeb()
        })
    }
}

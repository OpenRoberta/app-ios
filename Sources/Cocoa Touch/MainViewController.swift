//  Copyright © 2017 Fraunhofer Gesellschaft. All rights reserved.

import UIKit
import WebKit

class MainViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, LEDeviceManagerDelegate, WKScriptMessageHandler {
    
    private(set) var webView: WKWebView!
    var labUrl = "https://lab.open-roberta.org/#loadSystem&&wedo" // this is the default, if no user settings are found
    
    // hide the statusbar
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupWebView()
        openWebsite()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning in ViewController class")
    }
    
    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "OpenRoberta")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        self.view.addSubview(webView)
        DeviceManager.sharedManager.setWebView(webView: webView)
    }
    
    private func openWebsite() {
        let urlFromDefault = UserDefaults.standard.string(forKey: "server_url")
        let urlString = urlFromDefault ?? labUrl
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
            webView.navigationDelegate = self
            webView.load(request)
        }
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        let body = message.body
        print("JavaScript is sending a message \(body)")
        if let bodyString = body as? String {
            if let dict = DeviceManager.json2dict(text: bodyString) {
                if let target = dict["target"] as? String,
                   let type = dict["type"] as? String
                {
                    if (target == "internal") {
                        if (type == "identify") {
                            DeviceManager.dict2webkit(dict: ["target":"internal", "type":"identify", "name":"OpenRoberta"])
                        } else if (type == "setRobot") {
                            // ignore
                        }
                    } else if (target == "wedo") {
                        handlePeripheralRequest(dict)
                    }
                }
            }
        }
        print("done")
    }
    
    /**
      a request from thwe webview arrived and has to be processed. This is done here.
     */
    func handlePeripheralRequest(_ request: [String: Any]) {
        if let type = request["type"] as? String {
			switch type {
			case "startScan":
				DeviceManager.sharedManager.startScan()
			case "stopScan":
				DeviceManager.sharedManager.stopScan()
			case "connect":
				if let name = request["robot"] as? String {
					DeviceManager.sharedManager.connectToDevice(name)
				}
			case "disconnect":
				DeviceManager.sharedManager.disconnectFromDevice()
			case "command":
				DeviceManager.sharedManager.selectedDevice?.process(request)
			default:
				print("received peripheral request with an invalid type \(type)")
			}
		}
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if (url.absoluteString.starts(with: "https://www.roberta-home")) {
                decisionHandler(.cancel)
                UIApplication.shared.openURL(url)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
        }
    
        present(alertController, animated: true, completion: nil)
    }
   
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
        }

        present(alertController, animated: true, completion: nil)
    }
}

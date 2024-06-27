//  PyOnApp.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI
import WebKit

@main
struct PyOnApp: App {
    @State var login: String = ""
    var body: some Scene {WindowGroup {FirstView()}}
}

//struct ServerConfig {static let serverIP = "http://172.20.10.12:80"} // АДРЕС сервера раздача с айфона
struct ServerConfig {static let serverIP = "http://127.0.0.1:80"} // АДРЕС сервера локаль

// Представитель WebView
struct WebView: UIViewRepresentable {
    let htmlString: String
    var navigationDelegate: WKNavigationDelegate?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if htmlString.starts(with: "http") {
            if let url = URL(string: htmlString) {uiView.load(URLRequest(url: url))}
        } else {uiView.loadHTMLString(htmlString, baseURL: nil)}
    }
    
    func makeCoordinator() -> Coordinator {Coordinator(self)}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        init(_ parent: WebView) {self.parent = parent}
    }
}

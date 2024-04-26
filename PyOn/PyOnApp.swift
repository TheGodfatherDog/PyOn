//  PyOnApp.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI

@main
struct PyOnApp: App {
    @State var login: String = ""
    
    var body: some Scene {
        WindowGroup {
            FirstView()
        }
    }
}

struct ServerConfig {
    static let serverIP = "http://127.0.0.1:80"
}

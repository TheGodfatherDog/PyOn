//  PyOnApp.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI

@main
struct PyOnApp: App {
    @State var dataLoadingMode: DataLoadingMode = .local // Режим работы приложения .local и .server
    @State var login: String = ""
    
    var body: some Scene {
        WindowGroup {
            // Заменяем ContentView на LoginScreenView
            FirstView()
        }
    }
}

enum DataLoadingMode {
    case server // Режим загрузки с сервера
    case local // Режим загрузки из локальных хранилищ
}

//  ContentView.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    @Environment(\.colorScheme) var colorScheme
    let login: String

    var body: some View {
        TabView(selection: $selection) {
            createTab(view: ProfileView(login: login), label: "Профиль", icon: "person.crop.circle.fill", tag: 1)
            createTab(view: LessonsView(login: login), label: "Уроки", icon: "star.fill", tag: 2)
            createTab(view: TasksView(), label: "Задания", icon: "x.squareroot", tag: 3)
            createTab(view: PyOnView(), label: "PyOn", icon: "apple.terminal", tag: 4)
        }
        .accentColor(.blue)
        .onAppear(perform: setupTabBarAppearance)
    }

    private func createTab<V: View>(view: V, label: String, icon: String, tag: Int) -> some View {
        view.tabItem {
            Image(systemName: icon)
            Text(label)
        }
        .tag(tag)
    }

    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = colorScheme == .dark ? UIColor.black : UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(login: "Test") // Передаем пример значения login
    }
}

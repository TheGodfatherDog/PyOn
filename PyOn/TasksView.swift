//  TasksView.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI

struct TasksView: View {
    // Предполагаемая структура данных для урока
    struct Lesson {
        var id: Int
        var title: String
        var done: Bool
    }
    
    // Пример данных
    let lessons = [
        Lesson(id: 1, title: "Введение", done: false),
        Lesson(id: 2, title: "Основы Python", done: true),
        Lesson(id: 3, title: "Переменные", done: false),
        Lesson(id: 4, title: "Машинное обучение", done: false)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                List(lessons, id: \.id) { lesson in
                    HStack {
                        Text(lesson.title)
                            .foregroundColor(.white)
                        Spacer()
                        if lesson.done {
                            Image(systemName: "star.fill")
                                .foregroundColor(.purple)
                        } else {
                            Image(systemName: "star")
                                .foregroundColor(.purple)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                Spacer()
                //NavigationView() // Добавляем навигацию
            }
        }
    }
    //CustomTabView()

}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}


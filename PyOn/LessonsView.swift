//import SwiftUI
//
//struct LessonsView: View {
//    struct Lesson: Identifiable {
//        var id: Int
//        var title: String
//        var done: Bool
//        var url: AnyView // Обертка для разных типов представлений
//    }
//    
//    @State var lessons = [
//        Lesson(id: 1, title: "Введение", done: false, url: AnyView(IntroView())),
//        Lesson(id: 2, title: "Функции", done: true, url: AnyView(FunctionsView())),
//        Lesson(id: 3, title: "Ветвление", done: false, url: AnyView(ConditionalsView())),
//        Lesson(id: 4, title: "Синтаксис", done: false, url: AnyView(SyntaxView())),
//        Lesson(id: 5, title: "Операторы", done: false, url: AnyView(OperatorsView())),
//        Lesson(id: 6, title: "Модули", done: true, url: AnyView(ModulesView())),
//        Lesson(id: 7, title: "Циклы", done: true, url: AnyView(LoopsView())),
//        Lesson(id: 8, title: "Ввод и вывод", done: false, url: AnyView(IOView())),
//        Lesson(id: 9, title: "Переменные", done: false, url: AnyView(VariablesView())),
//    ]
//    
//    @State private var selectedLesson: Lesson? = nil
//    @State var showModal: Bool = false
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                List($lessons) { $lesson in
//                    HStack {
//                        Button(action: {
//                            self.selectedLesson = lesson
//                            self.showModal = true
//                        }) {
//                            Text(lesson.title)
//                                .foregroundColor(colorScheme == .dark ? .white : .black)
//                        }
//                        .sheet(item: self.$selectedLesson) { lesson in
//                            lesson.url
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .buttonStyle(PlainButtonStyle())
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            lesson.done.toggle()
//                        }) {
//                            Image(systemName: lesson.done ? "star.fill" : "star")
//                                .foregroundColor(lesson.done ? (colorScheme == .dark ? .purple : .purple) : .gray)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .listStyle(InsetGroupedListStyle())
//                Spacer()
//            }
//        }
//    }
//}
//
//struct LessonsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LessonsView()
//    }
//}

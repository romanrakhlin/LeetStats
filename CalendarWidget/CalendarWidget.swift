//
//  CalendarWidget.swift
//  CalendarWidget
//
//  Created by Roman Rakhlin on 12.10.2021.
//

import WidgetKit
import SwiftUI
import Intents
import UIKit

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct CalendarWidgetEntryView : View {
    var entry: Provider.Entry
    @State var text = NSMutableAttributedString(string: "")

    var body: some View {
        CalendarSubView(submissions: [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 26, 4, 3, 0, 0, 0, 0, 12, 13, 1, 7, 8, 8, 26, 15, 20, 0, 0, 0, 0, 0, 0, 0, 0, 37, 22, 14, 21, 7, 0, 12, 0, 0, 0, 0, 0, 0, 0, 7, 40, 9, 20, 4, 5, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1])
    }
}

struct CalendarSubView: UIViewRepresentable {
    
    var submissions: [Int]!
    
    func makeUIView(context: UIViewRepresentableContext<CalendarSubView>) -> CalendarView {
        let calendarView = CalendarView(frame: CGRect(x: 0, y: 0, width: 400, height: 400), data: submissions)
        return calendarView
    }
    
    func updateUIView(_ uiView: CalendarView,
        context: UIViewRepresentableContext<CalendarSubView>) {
    }
}

@main
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

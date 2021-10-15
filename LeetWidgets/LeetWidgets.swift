//
//  LeetWidgets.swift
//  LeetWidgets
//
//  Created by Roman Rakhlin on 15.10.2021.
//

import WidgetKit
import SwiftUI
import Intents

// MARK: - Main Methods
struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(date: Date(), streak: 0)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        // Create a timeline entry for "now."
        let date = Date()
        let entry = StreakEntry(
            date: date,
            streak: setStreak()
        )

        // Create a date that's 15 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!

        // Create the timeline with the entry and a reload policy with the date
        // for the next update.
        let timeline = Timeline(
            entries:[entry],
            policy: .after(nextUpdateDate)
        )

        completion(timeline)
    }
    
    func setStreak() -> Int {
        @AppStorage("SavedStats", store: UserDefaults(suiteName: "group.com.romanrakhlin.LeetStats"))
        var stats: Data?
        
        guard let safeStats = stats else { return 999 }
        
        let decoder = JSONDecoder()
        guard let loadedStats = try? decoder.decode(Stats.self, from: safeStats) else { return 999 }
        
        guard let safeStreak = loadedStats.streak else { return 999 }
        
        return safeStreak
    }
}

// MARK: - Addidtional Data for Presenting Widget
struct StreakEntry: TimelineEntry {
    var date: Date
    let streak: Int
}

struct LeetWidgetsEntryView: View {
    var entry: StreakProvider.Entry
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image("fireball")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 55)
                Text("\(entry.streak)")
                    .font(.system(size: 55, weight: .bold, design: .default))
            }
        }
    }
}

@main
struct LeetWidgets: Widget {
    let kind: String = "widgetSale"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            LeetWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct LeetWidgets_Previews: PreviewProvider {
    static var previews: some View {
        LeetWidgetsEntryView(entry: StreakEntry(date: Date(), streak: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}








//struct Provider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), configuration: configuration)
//        completion(entry)
//    }
//
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationIntent
//}
//
//struct LeetWidgetsEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        Text(entry.date, style: .time)
//    }
//}

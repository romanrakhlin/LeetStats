//
//  LeetWidgets.swift
//  LeetWidgets
//
//  Created by Roman Rakhlin on 15.10.2021.
//

import SwiftUI
import WidgetKit

private struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let entries = [StreakEntry(date: midnight)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

private struct StreakEntry: TimelineEntry {
    let date: Date
}

private struct StreakWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Your Streak:")
                .font(.system(size: 20, weight: .bold, design: .default))
            HStack(alignment: .center) {
                Image("fireball")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                Text("\(streakNumber)")
                    .font(.system(size: 55, weight: .bold, design: .default))
                    .minimumScaleFactor(0.4)
            }
        }
    }

    var streakNumber: Int {
        let gotData = UserDefaults.appGroup.data(forKey: "SavedStats")
        
        guard let safeStats = gotData else { return 0 }
        
        let decoder = JSONDecoder()
        guard let loadedStats = try? decoder.decode(Stats.self, from: safeStats) else { return 0 }

        guard let safeStreak = loadedStats.streak else { return 0 }
        
        return safeStreak
        
        // returninig 0 if failed on some step
    }
}

@main
struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("StreakWidget")
        .description("A widget that show streak from LeetCode.")
        .supportedFamilies([.systemSmall])
    }
}




//import WidgetKit
//import SwiftUI
//import Intents
//
//// MARK: - Main Methods
//struct StreakProvider: TimelineProvider {
//    func placeholder(in context: Context) -> StreakEntry {
//        StreakEntry(date: Date(), streak: 0)
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
//        let entry = StreakEntry(date: Date(), streak: 0)
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
//        // Create a timeline entry for "now."
//        let date = Date()
//        let entry = StreakEntry(
//            date: date,
//            streak: setStreak()
//        )
//
//        // Create a date that's 15 minutes in the future.
//        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
//
//        // Create the timeline with the entry and a reload policy with the date
//        // for the next update.
//        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
//        completion(timeline)
//    }
//
//    func setStreak() -> Int {
//        @AppStorage("SavedStats", store: UserDefaults(suiteName: "group.com.romanrakhlin.LeetStats"))
//        var stats: Data?
//
//        guard let safeStats = stats else { return 999 }
//
//        let decoder = JSONDecoder()
//        guard let loadedStats = try? decoder.decode(Stats.self, from: safeStats) else { return 999 }
//
//        guard let safeStreak = loadedStats.streak else { return 999 }
//
//        return safeStreak
//    }
//}
//
//// MARK: - Addidtional Data for Presenting Widget
//struct StreakEntry: TimelineEntry {
//    var date: Date
//    let streak: Int
//}
//
//struct LeetWidgetsEntryView: View {
//    var entry: StreakProvider.Entry
//
//    var body: some View {
//        VStack {
//            HStack(alignment: .center) {
//                Image("fireball")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 55)
//                Text("\(entry.streak)")
//                    .font(.system(size: 55, weight: .bold, design: .default))
//            }
//        }
//    }
//}
//
//@main
//struct LeetWidgets: Widget {
//    let kind: String = "widgetSale"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
//            LeetWidgetsEntryView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//struct LeetWidgets_Previews: PreviewProvider {
//    static var previews: some View {
//        LeetWidgetsEntryView(entry: StreakEntry(date: Date(), streak: 0))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}

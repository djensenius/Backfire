//
//  TripView.swift
//  Shared
//
//  Created by David Jensenius on 2021-04-07.
//

import SwiftUI
import CoreData
import CoreLocation

struct TripView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ride.timestamp, ascending: false)],
        animation: .default)

    private var items: FetchedResults<Ride>

    @State private var selection: Ride?

    @State private var columnVisibility = NavigationSplitViewVisibility.all

    private var localizeNumber = LocalizeNumbers()

    let helper = Helper()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(items, selection: $selection) { item in
                NavigationLink(value: item) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            returnTitle(item: item)
                            if item.locations?.count ?? 0 > 0 {
                                details(locationsAny: item.locations!.allObjects)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 10) {
                            if colorScheme == .dark {
                                Text(helper.weatherIcon(icon: item.weather?.icon ?? ""))
                                    .font(.largeTitle)
                            } else {
                                helper.weatherIcon(
                                    icon: item.weather?.icon ?? ""
                                ).symbolRenderingMode(getRenderMode())
                            }
                            Text(
                                localizeNumber.temp(
                                    temp: item.weather?.temperature ?? 373.15,
                                    unitName: item.weather?.temperatureUnit ?? ""
                                )
                            )
                            .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Rides")
            #if !os(macOS) && !os(visionOS)
                .frame(maxWidth: .infinity)
                .listStyle(GroupedListStyle())
            #endif
        } detail: {
            if let detailItem = selection {
                RideDetailView(ride: detailItem).navigationTitle(returnTitleText(item: detailItem))
                    .id(detailItem.id)
            }
        }.navigationSplitViewStyle(.balanced)
    }

    func getRenderMode() -> SymbolRenderingMode {
        var renderingMode: SymbolRenderingMode = .multicolor
        #if !os(visionOS)
        if colorScheme == .light {
            renderingMode = .monochrome
        }
        #endif
        return renderingMode
    }

    func details(locationsAny: [Any]) -> AnyView {
        guard let locations = locationsAny as? [Location] else {
            fatalError("Could not cast variable")
        }
        if locations.count == 0 {
            return AnyView(Text(""))
        }
        let sortedLocations = locations.sorted {
            $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedAscending
        }

        var timeText = ""

        if sortedLocations.first?.timestamp != nil && sortedLocations.last?.timestamp != nil {
            let diffComponents = Calendar.current.dateComponents(
                [.minute, .second],
                from: (sortedLocations.first?.timestamp)!,
                to: (sortedLocations.last?.timestamp)!
            )
            let minutes = diffComponents.minute
            let seconds = diffComponents.second
            timeText = "\(minutes ?? 0)"

            if seconds ?? 0 < 10 {
                timeText = "\(timeText):0\(seconds ?? 0)"
            } else {
                timeText = "\(timeText):\(seconds ?? 0)"
            }
        }

        var totalDistance: Double = 0
        var firstLat = sortedLocations.first?.latitude
        var firstLon = sortedLocations.first?.longitude
        sortedLocations.dropFirst().forEach { location in
            let firsLocation = CLLocation(latitude: firstLat!, longitude: firstLon!)
            let secondLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            firstLat = location.latitude
            firstLon = location.longitude
            totalDistance += firsLocation.distance(from: secondLocation)
        }

        return AnyView(
            Text("\(timeText) / \(localizeNumber.distance(distance: Double(totalDistance) / 1000, length: 2))")
                .font(.subheadline)
        )
    }

    private func returnTitle(item: Ride) -> AnyView {
        return AnyView(
            HStack {
                if item.device == "Apple Watch" {
                    Text(Image(systemName: "applewatch"))
                }
                Text("\(item.timestamp!, formatter: itemFormatter)")
                    .font(.headline)
            }
        )
    }

    private func returnTitleText(item: Ride) -> String {
        var string = ""
        let time = itemFormatterShort.string(from: item.timestamp ?? Date())
        string = "\(string) \(time)"
        return string
    }

    private func addItem() {
        withAnimation {
            let newItem = Ride(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it
                // may be useful during development.
                let nsError = error as NSError
                print(nsError)
                fatalError("Unresolved error 1 \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it
                // may be useful during development.
                let nsError = error as NSError
                print(nsError)
                // fatalError("Unresolved error 2 \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#if os(macOS)
extension View {
    func navigationBarTitle(_ title: String) -> some View {
        self
    }
}
#endif

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()

private let itemFormatterShort: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct TripView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TripView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            TripView()
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

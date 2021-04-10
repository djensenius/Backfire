//
//  TripView.swift
//  Shared
//
//  Created by David Jensenius on 2021-04-07.
//

import SwiftUI
import CoreData

struct TripView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ride.timestamp, ascending: false)],
        animation: .default)

    private var items: FetchedResults<Ride>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: RideDetailView(ride: item)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    if item.device == "Apple Watch" {
                                        Text(Image(systemName: "applewatch"))
                                    }
                                    Text("\(item.timestamp!, formatter: itemFormatter)")
                                        .font(.headline)
                                }
                                if (item.locations?.count ?? 0 > 0) {
                                    details(locations: item.locations?.allObjects as! [Location])
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 10) {
                                if colorScheme == .dark {
                                    Text(weatherIcon(icon: item.weather?.icon ?? ""))
                                        .font(.largeTitle)
                                } else {
                                    Text(weatherIcon(icon: item.weather?.icon ?? "").renderingMode(.template))
                                        .font(.largeTitle)
                                }
                                Text(returnTemp(temperature: item.weather?.temperature ?? 373.15))
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }.navigationBarTitle("Rides")
        }
    }

    func returnTemp(temperature: Double) -> String {
        let temp = String(format:"%.01f", temperature - 273.15)
        return "\(temp)°"
    }

    func weatherIcon(icon: String) -> Image {
        switch icon {
        case "01d":
            return Image(systemName: "sun.max.fill")
                .renderingMode(.original)
        case "02d":
            return Image(systemName: "cloud.sun.fill")
                .renderingMode(.original)
        case "03d":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "04d":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "09d":
            return Image(systemName: "cloud.rain.fill")
                .renderingMode(.original)
        case "10d":
            return Image(systemName: "cloud.sun.rain.fill")
                .renderingMode(.original)
        case "11d":
            return Image(systemName: "cloud.sun.bolt.fill")
                .renderingMode(.original)
        case "13d":
            return Image(systemName: "snow")
                .renderingMode(.original)
        case "50d":
            return Image(systemName: "cloud.fog.fill")
                .renderingMode(.original)
        case "01n":
            return Image(systemName: "moon.fill")
                .renderingMode(.original)
        case "02n":
            return Image(systemName: "cloud.moon.fill")
                .renderingMode(.original)
        case "03n":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "04n":
            return Image(systemName: "cloud.fill")
                .renderingMode(.original)
        case "09n":
            return Image(systemName: "cloud.rain.fill")
                .renderingMode(.original)
        case "10n":
            return Image(systemName: "cloud.moon.rain.fill")
                .renderingMode(.original)
        case "11n":
            return Image(systemName: "cloud.moon.bolt.fill")
                .renderingMode(.original)
        case "13n":
            return Image(systemName: "cloud.snow.fill")
                .renderingMode(.original)
        case "50n":
            return Image(systemName: "cloud.fog.fill")
                .renderingMode(.original)
        default:
            return Image(systemName: "thermometer")
                .renderingMode(.original)
        }
    }

    func details(locations: [Location]) -> AnyView {
        if locations.count == 0 {
            return AnyView(Text(""))
        }
        let sortedLocations = locations.sorted {
            $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedAscending
        }

        var timeText = ""

        if (sortedLocations.first?.timestamp != nil && sortedLocations.last?.timestamp != nil) {
            let diffComponents = Calendar.current.dateComponents([.minute, .second], from: (sortedLocations.first?.timestamp)!, to: (sortedLocations.last?.timestamp)!)
            let minutes = diffComponents.minute
            let seconds = diffComponents.second
            timeText = "\(minutes ?? 0)"

            if (seconds ?? 0 < 10) {
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
            totalDistance = totalDistance + firsLocation.distance(from: secondLocation)
        }

        return AnyView(
            Text("\(timeText) / \(String(format:"%.02f", totalDistance / 1000)) km")
                .font(.subheadline)
        )
    }

    private func addItem() {
        withAnimation {
            let newItem = Ride(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                print(nsError)
                fatalError("Unresolved error 2 \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()

struct TripView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TripView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            TripView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

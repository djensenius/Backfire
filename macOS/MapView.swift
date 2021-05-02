import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    private let locationViewModel = LocationViewModel()
    private let mapZoomEdgeInsets = NSEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    private var rideLocations: [Location]
    private var color = NSColor.black

    init(rideLocations: [Location]) {
        locationViewModel.load(rideLocations: rideLocations)
        self.rideLocations = rideLocations
    }

  func makeCoordinator() -> MapViewCoordinator {
    MapViewCoordinator(self)
  }

  func makeNSView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.showsUserLocation = false
    mapView.delegate = context.coordinator
    return mapView
  }

  func updateNSView(_ uiView: MKMapView, context: NSViewRepresentableContext<MapView>) {
    updateOverlays(from: uiView)
  }

  private func updateOverlays(from mapView: MKMapView) {
    mapView.removeOverlays(mapView.overlays)
    let polyline = MKPolyline(coordinates: locationViewModel.locations, count: locationViewModel.locations.count)
    let pl = polyLine()
    pl.forEach { line in
        mapView.addOverlay(line)
    }
    //mapView.addOverlay(pl)
    setMapZoomArea(map: mapView, polyline: polyline, edgeInsets: mapZoomEdgeInsets, animated: true)
  }

  private func setMapZoomArea(map: MKMapView, polyline: MKPolyline, edgeInsets: NSEdgeInsets, animated: Bool = false) {
    DispatchQueue.main.async {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
  }

    private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> NSColor {
      enum BaseColors {
        static let r_red: CGFloat = 1
        static let r_green: CGFloat = 20 / 255
        static let r_blue: CGFloat = 44 / 255

        static let y_red: CGFloat = 1
        static let y_green: CGFloat = 215 / 255
        static let y_blue: CGFloat = 0

        static let g_red: CGFloat = 0
        static let g_green: CGFloat = 146 / 255
        static let g_blue: CGFloat = 78 / 255
      }

      let red, green, blue: CGFloat

      if speed < midSpeed {
        let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
        red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
        green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
        blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
      } else {
        let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
        red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
        green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
        blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
      }

      return NSColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private func polyLine() -> [MulticolorPolyline] {
        let locations = self.rideLocations.sorted {
            $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedAscending
        }

        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0

        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
            let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
            coordinates.append((start, end))

            let distance = end.distance(from: start)
            if second.timestamp == nil {
                second.timestamp = Date()
            }
            if first.timestamp == nil {
                first.timestamp = Date()
            }
            let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
        }

        let midSpeed = speeds.reduce(0, +) / Double(speeds.count)

        var segments: [MulticolorPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = segmentColor(speed: speed,
                                     midSpeed: midSpeed,
                                     slowestSpeed: minSpeed,
                                     fastestSpeed: maxSpeed)
            segments.append(segment)
      }
      return segments
    }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(rideLocations: [Location()])
  }
}


import SwiftUI
import MapKit

struct MapView: NSViewRepresentable {
    private let locationViewModel = LocationViewModel()
    private let mapZoomEdgeInsets = NSEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    private var rideLocations: [Location]
    private var color = NSColor.black

    init(rideLocations: [Any]) {
        guard let locations = rideLocations as? [Location] else {
            fatalError("Could not cast locations")
        }
        locationViewModel.load(rideLocations: locations)
        self.rideLocations = locations
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
    let pline = polyLine()
    pline.forEach { line in
        mapView.addOverlay(line)
    }
    setMapZoomArea(map: mapView, polyline: polyline, edgeInsets: mapZoomEdgeInsets, animated: true)
  }

  private func setMapZoomArea(map: MKMapView, polyline: MKPolyline, edgeInsets: NSEdgeInsets, animated: Bool = false) {
    DispatchQueue.main.async {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
  }

    private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> NSColor {
      enum BaseColors {
        static let rRed: CGFloat = 1
        static let rGreen: CGFloat = 20 / 255
        static let rBlue: CGFloat = 44 / 255

        static let yRed: CGFloat = 1
        static let yGreen: CGFloat = 215 / 255
        static let yBlue: CGFloat = 0

        static let gRed: CGFloat = 0
        static let gGreen: CGFloat = 146 / 255
        static let gBlue: CGFloat = 78 / 255
      }

      let red, green, blue: CGFloat

      if speed < midSpeed {
        let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
        red = BaseColors.rRed + ratio * (BaseColors.yRed - BaseColors.rRed)
        green = BaseColors.rGreen + ratio * (BaseColors.yGreen - BaseColors.rGreen)
        blue = BaseColors.rBlue + ratio * (BaseColors.yBlue - BaseColors.rBlue)
      } else {
        let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
        red = BaseColors.yRed + ratio * (BaseColors.gRed - BaseColors.yRed)
        green = BaseColors.yGreen + ratio * (BaseColors.gGreen - BaseColors.yGreen)
        blue = BaseColors.yBlue + ratio * (BaseColors.gBlue - BaseColors.yBlue)
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

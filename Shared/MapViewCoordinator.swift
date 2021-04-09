//
//  MapViewCoordinator.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-08.
//

import MapKit

final class MapViewCoordinator: NSObject, MKMapViewDelegate {
  private let map: MapView

  init(_ control: MapView) {
    self.map = control
  }

  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    if let annotationView = views.first, let annotation = annotationView.annotation {
      if annotation is MKUserLocation {
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
      }
    }
  }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MulticolorPolyline else {
        // return MKOverlayRenderer(overlay: overlay)
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3.0
            return renderer
      }
      let renderer = MKPolylineRenderer(polyline: polyline)
      renderer.strokeColor = polyline.color
      renderer.lineWidth = 3
      return renderer
    }

//  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//    let renderer = MKPolylineRenderer(overlay: overlay)
//    renderer.strokeColor = .blue
//    renderer.lineWidth = 3.0
//    return renderer
//  }
}

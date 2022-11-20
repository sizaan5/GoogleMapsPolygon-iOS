//
//  ViewController.swift
//  GoogleMapPolygon
//
//  Created by Admin on 11/02/2022.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    var nevadaCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(
            latitude: 41.99483623877299,
            longitude: -119.99917096965822
        ),
        CLLocationCoordinate2D(
            latitude: 41.86407114225792,
            longitude: -114.0225887305135
        ),
        CLLocationCoordinate2D(
            latitude: 37.11940857325003,
            longitude: -114.0225887305135
        ),
        CLLocationCoordinate2D(
            latitude: 35.05993939067412,
            longitude: -114.63782306666128
        ),
        CLLocationCoordinate2D(
            latitude: 38.996381415577794,
            longitude: -119.98816452566066
        ),
        CLLocationCoordinate2D(
            latitude: 41.986681086642214,
            longitude: -119.98816452566066
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Maps Polygon"
        self.addingThemeToMap(fileName: "map_style", fileExtension: "json")
        var points: [CGPoint] = []
        for point in self.nevadaCoordinates {
            let pointObj = CGPoint(x: point.latitude, y: point.longitude)
            points.append(pointObj)
        }
        
        self.createPolygon(coordinates: self.nevadaCoordinates) { polygon in
            if let polygon = polygon {
                polygon.fillColor = .red
                polygon.strokeColor = .black
                polygon.strokeWidth = 2
                polygon.map = self.mapView
                
                let centreOfPolygon = self.polygonCenterOfMass(polygon: points)
                let centreLocation = CLLocationCoordinate2D(latitude: centreOfPolygon.x, longitude: centreOfPolygon.y)
                self.mapView.animate(toLocation: centreLocation)
                self.mapView.animate(toZoom: 6)
                let mapMarker = GMSMarker(position: centreLocation)
                mapMarker.title = "Nevada"
                mapMarker.map = self.mapView
            }
        }
    }
    
    // to add theme on google maps
    func addingThemeToMap(fileName: String, fileExtension: String) {
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find map_style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    //to create polygon
    func createPolygon(coordinates: [CLLocationCoordinate2D], completion: @escaping (_ polygon: GMSPolygon?) -> Void) {
        let rect = GMSMutablePath()
        
        for coordinate in coordinates {
            rect.add(coordinate)
        }
        let polygon = GMSPolygon(path: rect)
        completion(polygon)
    }
    
    // to get centre point of polygon
    func polygonCenterOfMass(polygon: [CGPoint]) -> CGPoint {
        let nr = polygon.count
        var centerX: CGFloat = 0
        var centerY: CGFloat = 0
        var area = signedPolygonArea(polygon: polygon)
        for i in 0 ..< nr {
            let j = (i + 1) % nr
            let factor1 = polygon[i].x * polygon[j].y - polygon[j].x * polygon[i].y
            centerX = centerX + (polygon[i].x + polygon[j].x) * factor1
            centerY = centerY + (polygon[i].y + polygon[j].y) * factor1
        }
        area = area * 6.0
        let factor2 = 1.0/area
        centerX = centerX * factor2
        centerY = centerY * factor2
        let center = CGPoint.init(x: centerX, y: centerY)
        return center
    }
    
    func signedPolygonArea(polygon: [CGPoint]) -> CGFloat {
        let nr = polygon.count
        var area: CGFloat = 0
        for i in 0 ..< nr {
            let j = (i + 1) % nr
            area = area + polygon[i].x * polygon[j].y
            area = area - polygon[i].y * polygon[j].x
        }
        area = area/2.0
        return area
    }

}


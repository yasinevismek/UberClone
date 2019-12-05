//
//  TaxiRequestAcceptViewController.swift
//  uber
//
//  Created by yasin on 11.05.2019.
//  Copyright © 2019 yasin. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
class customPin:NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title=pinTitle
        self.subtitle=pinSubTitle
        self.coordinate=location
    }
}

class TaxiRequestAcceptViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var requestMap: MKMapView!
     var locationManager=CLLocationManager()
    var boylam:Double=0.0
    var enlem:Double=0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let profileVT = Database.database().reference().child("TaksiCagiranlar")
        profileVT.observe(.childAdded, with: { snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let boylamm = snapshotValue["boylam"] as! Double
            let enlemm = snapshotValue["enlem"] as! Double
            
            
            if boylamm>0{
            self.boylam=boylamm
            self.enlem=enlemm
            }
            
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
        let sourceLocation=CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        let destinationLocation=CLLocationCoordinate2D(latitude: 40.945405, longitude: 40.27)
        print(self.boylam)
            print(self.enlem)
        let sourcePin=customPin(pinTitle: "Siz", pinSubTitle: "", location: sourceLocation)
        let destinationPin=customPin(pinTitle: "Yolcu", pinSubTitle: "", location: destinationLocation)
        
        self.requestMap.addAnnotation(sourcePin)
        self.requestMap.addAnnotation(destinationPin)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source=MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination=MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{(response,error) in
            guard let directionResonse = response else {
                if let error = error{
                    print("hata var==\(error.localizedDescription)")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.requestMap.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.requestMap.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        }
        self.requestMap.delegate = self
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.blue
            return lineView
    }

    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let passengervc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(passengervc, animated: true, completion: nil)
        } catch{
            print("Çıkış Yapılamadı")
        }    }
}

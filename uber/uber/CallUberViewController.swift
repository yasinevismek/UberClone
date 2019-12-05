//
//  CallUberViewController.swift
//  uber
//
//  Created by yasin on 1.05.2019.
//  Copyright © 2019 yasin. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class CallUberViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var uberMap: MKMapView!
    var locationManager=CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var taksiCagir:Bool = false
    @IBOutlet weak var taksibutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //Daha önce taksi çağrılmış mı
        if let email=Auth.auth().currentUser?.email{
            Database.database().reference().child("TaksiCagiranlar").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snaphot) in
                self.taksiCagir=true
                self.taksibutton.setTitle("İptal Et", for: .normal)
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate //konumun koordinatları
        {
            let center = CLLocationCoordinate2DMake(coord.latitude, coord.longitude) //konum koordinatlarını haritanın merkezinde gösterme
            userLocation = center
            let span = MKCoordinateSpanMake(0.01, 0.01) //haritaya yaklaşma
            let region = MKCoordinateRegion(center: center, span: span)
            uberMap.setRegion(region, animated: true)
            //pini haritaya ekleme
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Buradasınız"
            uberMap.addAnnotation(annotation)
        }
        
    }
    
    @IBAction func callTaksi(_ sender: Any) {
        let email=Auth.auth().currentUser?.email
        let userInfo:[String:Any] = ["email":email!,"enlem":userLocation.latitude,"boylam":userLocation.longitude]
        if taksiCagir{
            taksiCagir=false
            taksibutton.setTitle("Taksi Çağır", for: .normal)
            Database.database().reference().child("TaksiCagiranlar").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                snapshot.ref.removeValue()
                Database.database().reference().child("TaksiCagiranlar").removeAllObservers()
            })
        }
        else{
            Database.database().reference().child("TaksiCagiranlar").childByAutoId().setValue(userInfo)
            taksibutton.setTitle("İptal Et", for: .normal)
            taksiCagir=true
        }
    }

    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let passengervc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(passengervc, animated: true, completion: nil)
        } catch{
            print("Çıkış Yapılamadı")
        }
    }
}

//
//  DriverViewController.swift
//  uber
//
//  Created by yasin on 1.05.2019.
//  Copyright © 2019 yasin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit




class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    @IBOutlet weak var tableView: UITableView!
    var taksiCagiranlar : [DataSnapshot] = []
    var konumYoneticisi = CLLocationManager()
    var soforKonum = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha=0.2
        tableView.backgroundView = backgroundImage
        konumYoneticisi.delegate = self
        konumYoneticisi.desiredAccuracy = kCLLocationAccuracyBest
        konumYoneticisi.requestWhenInUseAuthorization()
        konumYoneticisi.startUpdatingLocation()
        
        //Veritabanında TaksiCagiranlar altındaki verileri diziye atma
        Database.database().reference().child("TaksiCagiranlar").observe(.childAdded) { (snapshot) in
            self.taksiCagiranlar.append(snapshot)
            self.tableView.reloadData()
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (updateTimer) in
            self.tableView.reloadData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let soforKoord = manager.location?.coordinate{
            soforKonum = soforKoord
        }
    }
    
    @IBAction func cikisYap(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Cikis Yapilamadi")
        }
    }
    //TableView kaç satır dönmeli
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taksiCagiranlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "taksiCagiranlarCell", for:indexPath)
        let snapshot = taksiCagiranlar [indexPath.row]
        
        if let taksiCagiranlarVerisi = snapshot.value as? [String:AnyObject]{
            if let email = taksiCagiranlarVerisi["email"] as? String{
                if let enlem = taksiCagiranlarVerisi["enlem"] as? Double{
                    if let boylam = taksiCagiranlarVerisi["boylam"] as? Double{
                        let soforKonumBilgileri = CLLocation(latitude: soforKonum.latitude, longitude: soforKonum.longitude)
                        let yolcuKkonumBilgileri = CLLocation(latitude: enlem, longitude: boylam)
                        let uzaklik = soforKonumBilgileri.distance(from: yolcuKkonumBilgileri)/1000
                        let yaklasikUzaklik = round(uzaklik*100)/100
                        cell.textLabel?.text = "\(email) - \(yaklasikUzaklik) km"
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let passengervc = storyboard.instantiateViewController(withIdentifier: "TaxiRequestVC")
        self.present(passengervc, animated: true, completion: nil)
        
        
    }
}

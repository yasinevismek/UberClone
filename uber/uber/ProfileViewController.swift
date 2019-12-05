//
//  ProfileViewController.swift
//  uber
//
//  Created by yasin on 11.05.2019.
//  Copyright © 2019 yasin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var kadilabel: UILabel!
    @IBOutlet weak var maillabel: UILabel!
    var profileAr : [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let emaill=Auth.auth().currentUser?.email
        let profileVT = Database.database().reference().child("Kullanicilar")
        profileVT.observe(.childAdded, with: { snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let email = snapshotValue["email"] as! String
            let kadi = snapshotValue["kadi"] as! String
            if email==emaill{
                self.kadilabel.text=kadi
                self.maillabel.text=email
            }
            
        })
    
        
        }
    

    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch{
            print("Çıkış Yapılamadı")
        }
    }

    @IBAction func konumGor(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let passengervc = storyboard.instantiateViewController(withIdentifier: "PassengerVC")
        self.present(passengervc, animated: true, completion: nil)
    }
}

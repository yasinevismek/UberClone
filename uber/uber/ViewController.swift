//
//  ViewController.swift
//  uber
//
//  Created by yasin on 28.04.2019.
//  Copyright © 2019 yasin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ViewController: UIViewController {

    @IBOutlet weak var emailtf: UITextField!
    @IBOutlet weak var sifretf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    @IBAction func loginbtn(_ sender: Any) {
        if (emailtf.text?.isEmpty)! && (sifretf.text?.isEmpty)! {
            showAlert(title: "Hata", message: "Lütfen boş alan bırakmayınız!")
        }
        else{
            let emaill=emailtf.text
            let profileVT = Database.database().reference().child("Kullanicilar")
            profileVT.observe(.childAdded, with: { snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let email = snapshotValue["email"] as! String
                let gorev = snapshotValue["gorev"] as! String
                // Görev yolcu ise yolcu ile giriş yap
                if (email==emaill && gorev=="yolcu"){
                    Auth.auth().signIn(withEmail: self.emailtf.text!, password: self.sifretf.text!, completion: {(user, error) in
                        if (error != nil){
                            self.showAlert(title: "Hata", message: (error?.localizedDescription)!)
                        }
                        else{
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let passengervc = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
                                self.present(passengervc, animated: true, completion: nil)
                        }
                    })
                }
                // Görev sofor ise sofor ile giriş yap
                else if (email==emaill && gorev=="sofor"){
                    Auth.auth().signIn(withEmail: self.emailtf.text!, password: self.sifretf.text!, completion: {(user, error) in
                        if (error != nil){
                            self.showAlert(title: "Hata", message: (error?.localizedDescription)!)
                        }
                        else{
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let passengervc = storyboard.instantiateViewController(withIdentifier: "DriverVC")
                                self.present(passengervc, animated: true, completion: nil)
                                self.emailtf.text = ""
                        }
                    })
                }
            })
        }
    }
    
}


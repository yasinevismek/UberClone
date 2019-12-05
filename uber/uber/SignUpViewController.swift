//
//  SignUpViewController.swift
//  uber
//
//  Created by yasin on 28.04.2019.
//  Copyright © 2019 yasin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailtf: UITextField!
    @IBOutlet weak var sifre1tf: UITextField!
    @IBOutlet weak var sifre2tf: UITextField!
    @IBOutlet weak var kaditf: UITextField!
    
    var kayitol:Bool = false
    
    @IBOutlet weak var segmentSec: UISegmentedControl!
    var driver:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.driver = false
        
    }
    @IBAction func btnKayitol(_ sender: Any) {
        
        if(emailtf.text?.isEmpty)! && (sifre1tf.text?.isEmpty)! && (sifre2tf.text?.isEmpty)!{
            showAlert(title: "HATA", message: "Lütfen boş alan bırakmayınız!")
        }
        else if(sifre1tf.text != sifre2tf.text){
            showAlert(title: "HATA", message: "Şifreler uyuşmuyor!")
        }
        else {
            //Veritabanında bu email var mı diye bakıyor
            self.kayitol=true
            if let email=emailtf.text{
                Database.database().reference().child("Kullanicilar").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snaphot) in
                    self.kayitol=false
                })
            }
            if kayitol{
            Auth.auth().createUser(withEmail: emailtf.text!, password: sifre1tf.text!) { (user, error) in
                if let error = error{
                    self.showAlert(title: "HATA", message: error.localizedDescription)
                }
                else{
                    self.showAlert(title: "Tebrikler", message: "Kullanıcı kaydınız tamamlanmıştır.")
                    //Sürücü seçili ise
                    if self.driver {
                        let userInfo:[String:Any] = ["email":self.emailtf.text!,"kadi":self.kaditf.text!,"sifre":self.sifre1tf.text!,"gorev":"sofor"]
                        Database.database().reference().child("Kullanicilar").childByAutoId().setValue(userInfo)
                        self.emailtf.text = ""
                        self.sifre1tf.text = ""
                        self.sifre2tf.text = ""
                        self.kaditf.text = ""
                        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! ViewController
                        self.present(LoginVC, animated: true, completion: nil)
                    }
                    //Yolcu seçili ise
                    else {
                        let userInfo:[String:Any] = ["email":self.emailtf.text!,"kadi":self.kaditf.text!,"sifre":self.sifre1tf.text!,"gorev":"yolcu"]
                        Database.database().reference().child("Kullanicilar").childByAutoId().setValue(userInfo)
                        self.emailtf.text = ""
                        self.sifre1tf.text = ""
                        self.sifre2tf.text = ""
                        self.kaditf.text = ""
                        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! ViewController
                        self.present(LoginVC, animated: true, completion: nil)
                    }
                   
                }
            }
            }else {
                 showAlert(title: "HATA", message: "Bu mail adresi kayıtlı!")
            }
        }

        
    }
    @IBAction func kullaniciSec(_ sender: Any) {
        if segmentSec.selectedSegmentIndex==0{
            print("yolcu")
            driver = false
            if(!(emailtf.text?.isEmpty)!){
                self.btnKayitol(sender)
            }
        }else {
            print("sofor")
            driver = true
            if(!(emailtf.text?.isEmpty)!){
                self.btnKayitol(sender)
            }
        }
    }
}

extension UIViewController{
    func showAlert(title:String, message:String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert,animated: true,completion: nil)
    }
}

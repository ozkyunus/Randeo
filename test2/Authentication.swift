//
//  Untitled.swift
//  test2
//
//  Created by Yunus Emre Özkaya on 7.11.2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class Authentication: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func EnterButton(_ sender: Any) {
        guard let email = mailTextField.text, !email.isEmpty else {
                    showAlert(message: "E-posta boş olamaz.")
                    return
                }
                
                guard let password = passwordTextField.text, !password.isEmpty else {
                    showAlert(message: "Şifre boş olamaz.")
                    return
                }

        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.showAlert(message: "Giriş başarısız: \(error.localizedDescription)")
                return
            }

            self.showAlert(message: "Giriş başarılı!", isSuccess: true)
            
        }
    }

        func showAlert(message: String, isSuccess: Bool = false) {
            let alert = UIAlertController(title: isSuccess ? "Başarılı" : "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}

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
        view.isUserInteractionEnabled = false
        
        guard let email = mailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(message: "E-posta boş olamaz.")
            view.isUserInteractionEnabled = true
            return
        }
        
        guard let password = passwordTextField.text,
              !password.isEmpty else {
            showAlert(message: "Şifre boş olamaz.")
            view.isUserInteractionEnabled = true
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            DispatchQueue.main.async {

                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                self?.view.isUserInteractionEnabled = true
                
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(message: "Giriş başarısız: \(error.localizedDescription)")
                } else {
                    let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
                    if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreen {
                        homeViewController.modalPresentationStyle = .fullScreen
                        homeViewController.modalTransitionStyle = .crossDissolve
                        

                        self.present(homeViewController, animated: true) { [weak self] in

                            self?.mailTextField.text = ""
                            self?.passwordTextField.text = ""
                        }
                    } else {
                        self.showAlert(message: "HomeScreen yüklenemedi. Lütfen tekrar deneyin.")
                    }
                }
            }
        }
    }
    func showAlert(message: String, isSuccess: Bool = false) {
        let alert = UIAlertController(title: isSuccess ? "Başarılı" : "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

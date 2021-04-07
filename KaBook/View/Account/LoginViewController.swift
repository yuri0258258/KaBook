//
//  LoginViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/03/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setupGradientLayer()
    }
    
    private func setUpViews(){
        loginButton.layer.cornerRadius = 8
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupGradientLayer(){
        let layer = CAGradientLayer()
        let startColor = UIColor.rgb(red: 55, green: 161, blue: 246).cgColor
        let endColor = UIColor.rgb(red: 58, green: 236, blue: 150).cgColor
        
        
        layer.colors = [startColor,endColor]
        layer.locations = [0.0,1.3]
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
    }
    @IBAction func tappedLoginButton(_ sender: Any) {
        guard let email = emailTextField.text else {
            return
        }
      
        guard let password = passwordTextField.text else {
            return
        }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                HUD.hide()
                print("\(err):ログインに失敗しました")
                return
            }
            
            HUD.hide()
            print("ログインに成功しました。")
            let storyboard: UIStoryboard = UIStoryboard(name: "BaseTabBar", bundle: nil)
            let baseTabBarViewController = storyboard.instantiateViewController(withIdentifier: "BaseTabBarViewController") as! BaseTabBarViewController
            
            baseTabBarViewController.modalPresentationStyle = .fullScreen
            self.present(baseTabBarViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedDontHaveAcountButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        signUpViewController.modalPresentationStyle = .fullScreen
        self.present(signUpViewController, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else{
            loginButton.isEnabled = true
            loginButton.backgroundColor = .rgb(red: 9, green: 110, blue: 228)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

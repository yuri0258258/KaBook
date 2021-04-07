//
//  SignUpViewController.swift
//  KaBook
//
//  Created by takeda yuri on 2021/03/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PKHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setUpViews()
    }
    
    private func setUpViews(){
        registerButton.layer.cornerRadius = 8
        
        profileImageButton.layer.cornerRadius = profileImageButton.frame.width / 2
        profileImageButton.layer.borderWidth = 2
        profileImageButton.layer.borderColor = UIColor.rgb(red: 255, green: 255, blue: 255).cgColor
        
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
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
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        guard let image = profileImageButton.imageView?.image else {
            return
        }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {
            return
        }
        
        HUD.show(.progress)
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(uploadImage,metadata: nil) { (metadata,err) in
            if let err = err {
                HUD.hide()
                print("\(err):FireStorageへの保存に失敗しました")
                return
            }
            print("FireStorageへの保存に成功しました")
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    HUD.hide()
                    print("\(err):URL取得に失敗しました")
                }
                guard let urlString = url?.absoluteString else {return}
                self.createUserToFiresore(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFiresore(profileImageUrl: String){
        guard let emial = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        guard let username = usernameTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: emial, password: password) { (res, err) in
            if let err = err {
                HUD.hide()
                print("\(err):Auth情報の保存に失敗しました。")
                return
            }
            print("Auth情報の保存に成功しました。")
            
            guard let uid = res?.user.uid else {return}
            
            let docData = [
                "email": emial,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl
            ] as [String: Any]
            
            
            Firestore.firestore().collection("users").document(uid).setData(docData) { err in
                if let err = err {
                    HUD.hide()
                    print("\(err):データベースへの保存に失敗しました。")
                    return
                }
                print("データベースへの保存に成功しました。")
                HUD.hide()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else{
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 9, green: 110, blue: 228)
        }
    }
}

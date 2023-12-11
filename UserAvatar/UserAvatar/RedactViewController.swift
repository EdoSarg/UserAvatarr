//
//  ViewController.swift
//  UserAvatar
//
//  Created by Edgar Sargsyan on 22.08.23.
//

import UIKit

//Mark: Delegat
//protocol ViewControllerDelegate: AnyObject {
//    func setUserData(data: User)
//}

class RedactViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var field: UITextField!
    @IBOutlet var filedMail: UITextField!
    @IBOutlet var filedTel: UITextField!
    
    var selectedImage: UIImage?
    
    var userModel = User()
    
    // weak var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.black.cgColor
        self.imageView.layer.masksToBounds = false
        self.imageView.layer.cornerRadius = imageView.frame.size.height/2
        self.imageView.clipsToBounds = true
        
        field.returnKeyType = .done
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.delegate = self
        
        filedMail.returnKeyType = .done
        filedMail.autocapitalizationType = .words
        filedMail.autocorrectionType = .no
        filedMail.delegate = self
        
        filedTel.returnKeyType = .done
        filedTel.autocapitalizationType = .words
        filedTel.autocorrectionType = .no
        filedTel.delegate = self
        
        setupUI()
    }
    
    private func setupUI() {
        
        if let encodedData = UserDefaults.standard.data(forKey: "user") {
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(User.self, from: encodedData)
                userModel = user
            } catch {
                print("Decoding error: \(error)")
            }
        }
        
        if let data = userModel.avatar, let avatar = UIImage(data: data) {
            imageView.image = avatar
        }
        field.text = userModel.name
        filedMail.text = userModel.mail
        filedTel.text = userModel.tel
    }
    
    @IBAction func didTapButton() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated:  true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        // notific
        let notificationData: [String: User] = ["userData": userModel]
          NotificationCenter.default.post(name: NSNotification.Name("UserDataSaved"), object: nil, userInfo: notificationData)
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userModel)
            UserDefaults.standard.set(encodedData, forKey: "user")
        } catch {
            print("Encoding error: \(error)")
        }
          
          navigationController?.popViewController(animated: true)
        //Mark- Delegat
       // delegate?.setUserData(data: userModel)
       // navigationController?.popViewController(animated: true)
        
    }
}

extension RedactViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
            if let imageData = image.pngData() {
                userModel.avatar = imageData
            }
        }
        picker.dismiss(animated: true, completion:  nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:  nil)
    }
}
extension RedactViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allText = textField.text! + string
        if textField == field {
            userModel.name = allText
        } else if textField == filedMail {
            userModel.mail = allText
        } else if textField == filedTel {
            userModel.tel = allText
        }
        return true
    }
}

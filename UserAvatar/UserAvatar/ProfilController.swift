//
//  ProfilController.swift
//  UserAvatar
//
//  Created by Edgar Sargsyan on 24.08.23.
//

import UIKit

struct User: Codable {
    var name: String?
    var mail: String?
    var tel: String?
    var avatar: Data?
}

class ProfilController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var profilLabel: UILabel!
    
    var userModel = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avatarImageView.layer.borderWidth = 1
        self.avatarImageView.layer.borderColor = UIColor.black.cgColor
        self.avatarImageView.layer.masksToBounds = false
        self.avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2
        self.avatarImageView.clipsToBounds = true
        
        // Подписка на уведомление
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserDataNotification(_:)), name: NSNotification.Name("UserDataSaved"), object: nil)
        //del
//        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIWithUserData()
    }
    
    @objc func handleUserDataNotification(_ notification: Notification) {
        if let notificationData = notification.userInfo as? [String: User],
           let updatedUserModel = notificationData["userData"] {
            userModel = updatedUserModel
            updateUIWithUserData()
        }
    }
    
    func updateUIWithUserData() {
                
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
            avatarImageView.image = avatar
        }
        profilLabel.text = "Name: \(userModel.name ?? "")\nEmail: \(userModel.mail ?? "")\nPhone: \(userModel.tel ?? "")"
    }
    
    @IBAction func action(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "RedactViewController") as? RedactViewController {
            vc.userModel = userModel
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//extension ProfilController: ViewControllerDelegate {
//    func setUserData(data: User) {
//        userModel = data
//    }
//}

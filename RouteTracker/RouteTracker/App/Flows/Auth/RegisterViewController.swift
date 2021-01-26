//
//  RegisterViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 26.01.2021.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var lblErrorMessage: UILabel! {
        didSet {
            lblErrorMessage.layer.cornerRadius = 10
            lblErrorMessage.layer.borderWidth = 1
            lblErrorMessage.layer.borderColor = UIColor.systemRed.cgColor
            lblErrorMessage.isHidden = true
            lblErrorMessage.text = ""
        }
    }
    
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    
    let service = UserService.shared
    var onRegistrationDone: (() -> Void)?
    var firstName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false
        title = "Регистрация"
        
        let touchGuesture = UITapGestureRecognizer(target: self, action: #selector(onViewClick))
        self.view.addGestureRecognizer(touchGuesture)
    }
    
    @objc
    private func onViewClick() {
        self.view.endEditing(true)
    }
    
    private func showFormError(message: String) {
        lblErrorMessage.layer.opacity = 0
        lblErrorMessage.isHidden = false
        lblErrorMessage.text = message
        
        UIView.animate(withDuration: 2, animations: {
            self.lblErrorMessage.layer.opacity = 1
        }, completion: { _ in
            UIView.animate(withDuration: 5) {
                self.lblErrorMessage.layer.opacity = 0
            }
        })
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        // Проверим все необходимые данные
        guard let login = txtLogin.text, login.isEmpty == false,
            let password = txtPassword.text, password.isEmpty == false,
            let newPassword = txtNewPassword.text, newPassword.isEmpty == false,
            let firstName = txtFirstName.text, firstName.isEmpty == false,
            let lastName = txtLastName.text, lastName.isEmpty == false else {
                showFormError(message: "Все поля формы обязательны")
                return
        }
        
        // также проверим совпадают ли пароли
        guard password == newPassword else {
            showFormError(message: "Пароли не совпадают")
            return
        }
        
        do {
            try service.register(user: User(login: login,
                                            password: password,
                                            firstName: firstName,
                                            lastName: lastName))
            
            UserDefaults.standard.set(true, forKey: "isLogin")
            self.firstName = firstName
            onRegistrationDone?()
            
        } catch let error {
            if let error = error as? RegisterError {
                switch error {
                case .userFound:
                    showFormError(message: "Такой пользовтаель уже есть")
                default:
                    showFormError(message: "Ошибка регистрации пользователя")
                }
                
            } else {
                showFormError(message: "Ошибка регистрации пользователя")
            }
        }
    }
    
}

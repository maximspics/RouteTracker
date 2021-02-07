//
//  RegisterViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 26.01.2021.
//

import UIKit

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var txtLogin: UITextField! {
        didSet {
            txtLogin.autocorrectionType = .no
        }
    }
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            txtPassword.autocorrectionType = .no
            txtPassword.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var txtNewPassword: UITextField! {
        didSet {
            txtNewPassword.autocorrectionType = .no
            txtNewPassword.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    
    // MARK: - Properties
    let service = UserService.shared
    var onRegistrationDone: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false
        title = "Регистрация"
        
        let touchGuesture = UITapGestureRecognizer(target: self, action: #selector(onViewClick))
        self.view.addGestureRecognizer(touchGuesture)
    }
    
    // MARK: - Methods
    func showAlertMessage(_ message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc
    private func onViewClick() {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func btnRegisterClicked(_ sender: Any) {
        
        guard let login = txtLogin.text, login.isEmpty == false,
            let password = txtPassword.text, password.isEmpty == false,
            let newPassword = txtNewPassword.text, newPassword.isEmpty == false,
            let firstName = txtFirstName.text, firstName.isEmpty == false,
            let lastName = txtLastName.text, lastName.isEmpty == false else {
                showAlertMessage("Все поля формы обязательны")
                return
        }
        
        guard password == newPassword else {
            showAlertMessage("Пароли не совпадают")
            return
        }
        
        do {
            try service.register(user: User(login: login,
                                            password: password,
                                            firstName: firstName,
                                            lastName: lastName))
            
            UserDefaults.standard.set(true, forKey: "isLogin")
            UserDefaults.standard.set(firstName, forKey: "firstName")
            let message = "\(firstName)!\nВы успешно зарегистрированы!"
            UserDefaults.standard.set(message, forKey: "message")
            UserDefaults.standard.set(login, forKey: "userLogin")
            onRegistrationDone?()
            
        } catch let error {
            if let error = error as? RegisterError {
                switch error {
                case .userFound:
                    showAlertMessage("Такой пользователь уже есть")
                default:
                    showAlertMessage("Ошибка регистрации пользователя")
                }
                
            } else {
                showAlertMessage("Ошибка регистрации пользователя")
            }
        }
    }
    
}

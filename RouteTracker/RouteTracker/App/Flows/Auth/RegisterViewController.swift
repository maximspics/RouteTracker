//
//  RegisterViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 26.01.2021.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var txtLogin: UITextField! {
        didSet {
            txtLogin.autocorrectionType = .no
            txtLogin.layer.borderWidth = 0.1
            txtLogin.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            txtPassword.autocorrectionType = .no
            txtPassword.isSecureTextEntry = true
            txtPassword.layer.borderWidth = 0.1
            txtPassword.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var txtNewPassword: UITextField! {
        didSet {
            txtNewPassword.autocorrectionType = .no
            txtNewPassword.isSecureTextEntry = true
            txtNewPassword.layer.borderWidth = 0.1
            txtNewPassword.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var txtFirstName: UITextField! {
        didSet {
            txtFirstName.autocorrectionType = .no
            txtFirstName.layer.borderWidth = 0.1
            txtFirstName.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var txtLastName: UITextField! {
        didSet {
            txtLastName.autocorrectionType = .no
            txtLastName.layer.borderWidth = 0.1
            txtLastName.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var btnRegister: UIButton!
    
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
        
        configureBtnRegisterClicked()
    }
    
    // MARK: - Methods
    private func configureBtnRegisterClicked() {
        
        let _ = Observable.combineLatest(txtLogin.rx.text, txtPassword.rx.text, txtNewPassword.rx.text, txtFirstName.rx.text, txtLastName.rx.text).map { [self] (txtLogin, txtPassword, txtNewPassword, txtFirstName, txtLastName) in
            return (
                    !service.isUserExistWith(login: txtLogin ?? "") &&
                    !(txtLogin ?? "").isEmpty &&
                    !(txtPassword ?? "").isEmpty &&
                    !(txtNewPassword ?? "").isEmpty &&
                    txtPassword == txtNewPassword &&
                    !(txtFirstName ?? "").isEmpty &&
                    !(txtLastName ?? "").isEmpty
            )
        }.bind { [self, weak txtLogin, txtPassword, txtNewPassword, txtFirstName, txtLastName, btnRegister] fieldFillCorrect in
            
            btnRegister?.isEnabled = fieldFillCorrect
            
            txtLogin?.placeholder = fieldFillCorrect ? "" : "Обязательно для заполнения"
            if !(txtLogin?.text ?? "").isEmpty && service.isUserExistWith(login: txtLogin!.text ?? "") {
                txtLogin?.layer.borderColor = UIColor.red.cgColor
                txtLogin?.layer.borderWidth = 1.0
                if !txtLogin!.isEditing {
                    self.showAlertMessage("Такой пользователь уже есть")
                }
            } else if !fieldFillCorrect && (txtLogin?.text ?? "").isEmpty {
                txtLogin?.layer.borderColor = UIColor.lightGray.cgColor
                txtLogin?.layer.borderWidth = 0.1
            } else {
                txtLogin?.layer.borderColor = UIColor.green.cgColor
                txtLogin?.layer.borderWidth = 1.0
            }
            
            txtFirstName?.placeholder = fieldFillCorrect ? "" : "Обязательно для заполнения"
            if !(txtFirstName?.text ?? "").isEmpty {
                txtFirstName?.layer.borderColor = UIColor.green.cgColor
                txtFirstName?.layer.borderWidth = 1.0
            } else if !fieldFillCorrect && (txtFirstName?.text ?? "").isEmpty {
                txtFirstName?.layer.borderColor = UIColor.gray.cgColor
                txtFirstName?.layer.borderWidth = 0.1
            }
            
            txtLastName?.placeholder = fieldFillCorrect ? "" : "Обязательно для заполнения"
            if !(txtLastName?.text ?? "").isEmpty {
                txtLastName?.layer.borderColor = UIColor.green.cgColor
                txtLastName?.layer.borderWidth = 1.0
            } else if !fieldFillCorrect && (txtLastName?.text ?? "").isEmpty {
                txtLastName?.layer.borderColor = UIColor.gray.cgColor
                txtLastName?.layer.borderWidth = 0.1
            }
            
            if !fieldFillCorrect && (txtPassword?.text ?? "").isEmpty {
                txtPassword?.layer.borderColor = UIColor.gray.cgColor
                txtPassword?.layer.borderWidth = 0.1
            }
            if !fieldFillCorrect && (txtNewPassword?.text ?? "").isEmpty {
                txtNewPassword?.layer.borderColor = UIColor.gray.cgColor
                txtNewPassword?.layer.borderWidth = 0.1
            }
            
            txtPassword?.placeholder = fieldFillCorrect ? "" : "Обязательно для заполнения"
            txtNewPassword?.placeholder = fieldFillCorrect ? "" : "Пароли должны совпадать"
            if  !(txtPassword?.text ?? "").isEmpty && !(txtNewPassword?.text ?? "").isEmpty && txtPassword?.text == txtNewPassword?.text {
                txtPassword?.layer.borderColor = UIColor.green.cgColor
                txtPassword?.layer.borderWidth = 0.5
                txtNewPassword?.layer.borderColor = UIColor.green.cgColor
                txtNewPassword?.layer.borderWidth = 0.5
            } else if !(txtPassword?.text ?? "").isEmpty && !(txtNewPassword?.text ?? "").isEmpty && txtPassword?.text != txtNewPassword?.text{
                txtPassword?.layer.borderColor = UIColor.red.cgColor
                txtPassword?.layer.borderWidth = 0.5
                txtNewPassword?.layer.borderColor = UIColor.red.cgColor
                txtNewPassword?.layer.borderWidth = 0.5
            }
        }
    }
    
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
        do {
            try service.register(user: User(login: txtLogin.text,
                                            password: txtPassword.text,
                                            firstName: txtFirstName.text,
                                            lastName: txtLastName.text))
            
            UserDefaults.standard.set(true, forKey: "isLogin")
            UserDefaults.standard.set(txtFirstName.text, forKey: "firstName")
            let message = "\(txtFirstName.text ?? "Дорогой пользователь")!\nВы успешно зарегистрированы!"
            UserDefaults.standard.set(message, forKey: "message")
            UserDefaults.standard.set(txtLogin.text, forKey: "userLogin")
            onRegistrationDone?()
            
        } catch {
            showAlertMessage("Ошибка регистрации пользователя")
        }
    }
}

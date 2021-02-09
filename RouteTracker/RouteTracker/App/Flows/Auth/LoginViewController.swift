//
//  LoginViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 22.01.2021.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    // MARK: Outlets
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
    
    @IBOutlet weak var btnLogin: UIButton!
    
    // MARK: - Properties
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    var message: String?
    
    var service = UserService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showByeMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let touchGuesture = UITapGestureRecognizer(target: self, action: #selector(onViewClick))
        self.view.addGestureRecognizer(touchGuesture)
        navigationController?.navigationBar.isHidden = true
        
        configureButtonEnterClicked()
    }
    
    // MARK: - Methods
    @objc
    private func onViewClick() {
        self.view.endEditing(true)
    }
    
    func showByeMessage() {
        guard let message = UserDefaults.standard.string(forKey: "message") else { return }
        if message != "" {
            showAlertMessage(message)
            UserDefaults.standard.set("", forKey: "message")
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
    
    private func configureButtonEnterClicked() {
        let _ = Observable
            .combineLatest(txtLogin.rx.text, txtPassword.rx.text)
            .map { (login, password) in
                return (!(login ?? "").isEmpty && (password ?? "").count >= 2)
        }
        .bind { [weak btnLogin] fieldNotEmpty in
            btnLogin?.isEnabled = fieldNotEmpty
        }
    }
    
    // MARK: - Actions
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        guard let login = txtLogin.text, login.isEmpty == false,
              let password = txtPassword.text, password.isEmpty == false else {
            showAlertMessage("Необходимо ввести логин и пароль!")
            return
        }
        
        guard service.isUserExistWith(login: login) == true,
              let user = service.getUserBy(login: login, password: password)?.first else {
            showAlertMessage("Пользователь с таким логином и паролем не найден!")
            return
        }
        
        UserDefaults.standard.set(true, forKey: "isLogin")
        UserDefaults.standard.set(user.firstName, forKey: "firstName")
        UserDefaults.standard.set(user.login, forKey: "userLogin")
        let message = "\(user.firstName)!\nВы успешно авторизованы!"
        UserDefaults.standard.set(message, forKey: "message")
        onLogin?()
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        onRegister?()
    }
    
    
}

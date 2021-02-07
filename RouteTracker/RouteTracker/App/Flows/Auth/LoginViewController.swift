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
    
    @IBOutlet weak var scrollContainer: UIScrollView!
    
    // MARK: - Properties
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    var message: String?
    
    var service = UserService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewClicked(_:)))
        view.addGestureRecognizer(tapGesture)
        showByeMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        navigationController?.navigationBar.isHidden = true
        
        configureButtonEnterClicked()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Methods
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
    
    @objc func viewClicked(_ sender: UIView) {
        view.endEditing(true)
        scrollViewReset()
    }

    @objc func keyboardWasShown(notification: Notification) {
        
        guard let info = notification.userInfo as NSDictionary?,
              let kbSizeInfo = info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else {
            return
        }
        
        let kbSize = kbSizeInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        
        scrollContainer.contentInset = contentInsets
        scrollContainer.scrollIndicatorInsets = contentInsets
        scrollContainer.contentOffset = CGPoint(x: 0, y: kbSize.height)
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        scrollViewReset()
    }
    
    fileprivate func scrollViewReset() {
        scrollContainer.contentInset = UIEdgeInsets.zero
        scrollContainer.scrollIndicatorInsets = UIEdgeInsets.zero
        scrollContainer.contentOffset = CGPoint.zero
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

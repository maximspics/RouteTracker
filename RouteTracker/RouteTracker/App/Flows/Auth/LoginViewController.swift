//
//  LoginViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 22.01.2021.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var lblErrorMessage: UILabel! {
        didSet {
            lblErrorMessage.layer.cornerRadius = 10
            lblErrorMessage.layer.borderColor = UIColor.systemRed.cgColor
            lblErrorMessage.layer.borderWidth = 1
            lblErrorMessage.clipsToBounds = true
            lblErrorMessage.isHidden = true
        }
    }
    
    // MARK: - Properties
    var onLogin: ((String) -> Void)?
    var onRegister: (() -> Void)?
    var welcomeMessage: ((String) -> Void)?
    
    var service = UserService.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewClicked(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Methods
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
        // Скрываем сообщение об ошибке
        self.lblErrorMessage.isHidden = true
        
        // Проверяем наличие необходимых данных
        guard let login = txtLogin.text, login.isEmpty == false,
            let password = txtPassword.text, password.isEmpty == false else {
                return
        }
        
        // Проверяем пользователя
        guard service.isUserExistBy(login: login, password: password) == true else {
            self.lblErrorMessage.layer.opacity = 0
            self.lblErrorMessage.isHidden = false
            
            // Моргнем плашкой об ошибке
            UIView.animate(withDuration: 2, animations: {
                self.lblErrorMessage.layer.opacity = 1
            }, completion: { _ in
                UIView.animate(withDuration: 2) {
                    self.lblErrorMessage.layer.opacity = 0
                }
            })
            
            
            return
        
        }
        
        UserDefaults.standard.set(true, forKey: "isLogin")
        let firstName = String(service.getUserBy(login: login, password: password)?.first?.firstName ?? "")
        let message = "\(firstName), мы рады снова тебя видеть!"
        onLogin?(message)
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {
        onRegister?()
    }
    
    
}

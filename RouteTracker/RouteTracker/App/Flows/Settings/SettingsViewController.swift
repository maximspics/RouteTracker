//
//  SettingsViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 09.02.2021.
//

import UIKit
import Kingfisher

class SettingsViewController: UIViewController {
    @IBOutlet weak var imgAvatarView: UIImageView! {
        didSet {
            imgAvatarView.image = UIImage(named: "default_marker")
            imgAvatarView.layer.cornerRadius = 50
        }
    }
    
    @IBOutlet weak var btnAddAvatar: UIButton! {
        didSet {
            btnAddAvatar.isEnabled = false
        }
    }
    
    let isCameraAvaileble = UIImagePickerController.isSourceTypeAvailable(.camera)
    let isPhotoLibraryAvaileble = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    
    private var edgeSwipeGestureRecognizer: UISwipeGestureRecognizer?
    
    var didAvatarChanged: ((UIImage?) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isCameraAvaileble || isPhotoLibraryAvaileble {
            btnAddAvatar.isEnabled = true
        }
        
        if let avatarUrl = AppManager.shared.loadAvatarUrl(), !avatarUrl.isEmpty {
            imgAvatarView.kf.setImage(with: URL(string: avatarUrl))
        }
        
        edgeSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
        
    }
    
    @objc func handleSwipes(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .right {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAvatarChangeClicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        
        imagePicker.sourceType = isCameraAvaileble ? .camera : .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }

    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        } else {
            image = nil
        }
        
        if let image = image,
           let smallImage = AppManager.shared.resizeAvatar(image) {
            imgAvatarView.image = smallImage
            
            AppManager.shared.saveAvatarToDisk(avatar: smallImage)
            
            didAvatarChanged?(smallImage)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


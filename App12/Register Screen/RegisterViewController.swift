//
//  RegisterViewController.swift
//  App12
//
//  Created by Sakib Miazi on 6/2/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI
import FirebaseStorage

class RegisterViewController: UIViewController {
    
    let database = Firestore.firestore()
    
    var currentUser:FirebaseAuth.User?
    
    let registerView = RegisterView()
    
    let childProgressView = ProgressSpinnerViewController()
    
    let users: [String] = ["Patient", "Doctor"]
        
    var selectedUser = "Patient"
    
    let storage = Storage.storage()
    
    //MARK: variable to store the picked Image...
    
    var pickedImage:UIImage?
    
    override func loadView() {
        view = registerView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: adding the PickerView delegate and data source...
        registerView.pickerUser.delegate = self
        registerView.pickerUser.dataSource = self
        
        registerView.buttonRegister.addTarget(self, action: #selector(onRegisterTapped), for: .touchUpInside)
        
        registerView.buttonTakePhoto.menu = getMenuImagePicker()

        title = "Register"
    }
    
    //MARK: menu for buttonTakePhoto setup...
    func getMenuImagePicker() -> UIMenu{
        let menuItems = [
            UIAction(title: "Camera",handler: {(_) in
                self.pickUsingCamera()
            }),
            UIAction(title: "Gallery",handler: {(_) in
                self.pickPhotoFromGallery()
            })
        ]
        
        return UIMenu(title: "Select source", children: menuItems)
    }
    
    //MARK: take Photo using Camera...
    func pickUsingCamera(){
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.allowsEditing = true
        cameraController.delegate = self
        present(cameraController, animated: true)
    }
    
    //MARK: pick Photo using Gallery...
    func pickPhotoFromGallery(){
        //MARK: Photo from Gallery...
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 1
        
        let photoPicker = PHPickerViewController(configuration: configuration)
        
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    
    @objc func onRegisterTapped(){
        if let email = registerView.textFieldEmail.text,
           let phone = registerView.textFieldPhone.text,
           let name = registerView.textFieldName.text,
           let aos = registerView.textFieldAoS.text,
           let password = registerView.textFieldPassword.text,
           let passwordVerify = registerView.textFieldPasswordVerify.text{
            if name.isEmpty || phone.isEmpty || password.isEmpty || email.isEmpty
                || aos.isEmpty {
                showErrorAlertText(text: "Please fill all of the fields")
            } else if !isValidEmail(email) {
                showErrorAlertText(text: "Invalid email!")
            } else if !isValidPhone(phone) {
                showErrorAlertText(text: "Invalid phone!")
            } else if password != passwordVerify {
                showErrorAlertText(text: "Passwords do not match!")
            }
            else{
                //MARK: creating a new user on Firebase...
                uploadProfilePhotoToStorage()
            }
        }
    }
    
    // Borrowed from Maxim Shoustin and Zandor Smith from https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift/25471164#25471164
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        return phone.count == 10 && Int(phone) != nil
    }
    
    func showErrorAlert(){
        let alert = UIAlertController(title: "Error!", message: "The fields cannot be empty!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showErrorAlertText(text:String){
        let alert = UIAlertController(title: "Error!", message: "\(text)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

//MARK: implementing user PickerView...
extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    //returns the number of columns/components in the Picker View...
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //returns the number of rows in the current component...
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return users.count
    }
    
    //set the title of currently picked row...
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedUser = users[row]
        registerView.swapAoS()
        return users[row]
    }
}

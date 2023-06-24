//
//  PLPViewController.swift
//  App12
//
//  Created by Victoria Adebiyi on 6/22/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PLPViewController: UIViewController {
    var plpScreen = PLPView()
    
    var currentUser:FirebaseAuth.User?
    
    var handleAuth: AuthStateDidChangeListenerHandle?
    
    let database = Firestore.firestore()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        view = plpScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: handling if the Authentication state is changed (sign in, sign out, register)...
        self.navigationItem.hidesBackButton = true;
        handleAuth = Auth.auth().addStateDidChangeListener{ auth, user in
            if user == nil{
                //MARK: not signed in...
                self.currentUser = nil
                self.plpScreen.labelName.text = "No User Data Found!"
                self.plpScreen.labelAge.text = "Age: Null"
                
            }else{
                //MARK: the user is signed in...
                self.currentUser = user
                if let lowercasedEmail = user!.email?.lowercased() {
                    let patDocuRef = self.database.collection("patient").document(lowercasedEmail)
                    
                    patDocuRef.getDocument(as: Patient.self) { result in
                        switch result {
                        case .success(let patient):
                            self.plpScreen.labelName.text = patient.name
                            self.plpScreen.labelAge.text = "Age: \(patient.age)"
                        case .failure(let error):
                            print("Error decoding patient: \(error)")
                        }
                    }
                }
                
//                //MARK: Observe Firestore database to display the contacts list...
//                self.database.collection("users")
//                    .document((self.currentUser?.email)!)
//                    .collection("contacts")
//                    .addSnapshotListener(includeMetadataChanges: false, listener: {querySnapshot, error in
//                        if let documents = querySnapshot?.documents{
//                            self.contactsList.removeAll()
//                            for document in documents{
//                                do{
//                                    let contact  = try document.data(as: Contact.self)
//                                    self.contactsList.append(contact)
//                                }catch{
//                                    print(error)
//                                }
//                            }
//                            self.contactsList.sort(by: {$0.name < $1.name})
//                            self.mainScreen.tableViewContacts.reloadData()
//                        }
//                    })
                        
                
            }
        }
    }

}

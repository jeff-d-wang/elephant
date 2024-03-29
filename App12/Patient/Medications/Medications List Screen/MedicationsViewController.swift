//
//  MedicationsViewController.swift
//  App12
//
//  Created by Victoria Adebiyi on 6/24/23.
//

import UIKit
import FirebaseFirestore

class MedicationsViewController: UIViewController {
    let medScreen = MedicationsView()
    
    var medList = [Medication]()
    
    let database = Firestore.firestore()
    
    var patientEmail:String!
    var patientName:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "\(patientName!)'s Medications"
        self.navigationItem.largeTitleDisplayMode = .never
        
        //MARK: patching table view delegate and data source...
        medScreen.tableViewMedications.delegate = self
        medScreen.tableViewMedications.dataSource = self
        
        //MARK: removing the separator line...
        medScreen.tableViewMedications.separatorStyle = .none
    }
    
    override func loadView() {
        view = medScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let barAddMedication = UIBarButtonItem(
            image: .add,
            style: .plain,
            target: self,
            action: #selector(onAddMedButtonTapped))
        
        database.collection("patient")
            .document((patientEmail)!)
            .collection("medications")
            .addSnapshotListener(includeMetadataChanges: false, listener: {querySnapshot, error in
                if let documents = querySnapshot?.documents{
                    self.medList.removeAll()
                    for document in documents{
                        print("\(document): Going through document list...")
                        do{
                            let medication  = try document.data(as: Medication.self)
                            self.medList.append(medication)
                            print("Appended medication to list")
                        }catch{
                            print(error)
                        }
                    }
                    self.medList.sort(by: {$0.name < $1.name})
                    self.medScreen.tableViewMedications.reloadData()
                }
            })

        
        self.navigationItem.rightBarButtonItem = barAddMedication

    }
    
    @objc func onAddMedButtonTapped() {
        let addMedView = AddMedicationViewController()
        addMedView.delegate = self
        addMedView.patientEmail = self.patientEmail
        self.navigationController?.pushViewController(addMedView, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


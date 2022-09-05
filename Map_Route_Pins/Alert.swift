//
//  Alert.swift
//  Map_Route_Pins
//
//  Created by Zhora Babakhanyan on 9/2/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alertAddAdress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void){
       
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let alertOk = UIAlertAction(title: "Ok", style: .default) { (action) in

            let textFieldText = alertController.textFields?.first
            guard let text = textFieldText?.text else {return}
            completionHandler(text)
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { (_) in
            print("Cancel")
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true)
        
    }
    
    func alertError(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOkayButton = UIAlertAction(title: "Ok", style: .default)
        
        alertController.addAction(alertOkayButton)
        
        present(alertController, animated: true)
    }
}

  

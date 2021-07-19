//
//  ViewController.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/14.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        //點擊外側取消keybooard
        let tap = UITapGestureRecognizer(target: view, action: #selector(textField.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult"{
            let destination = segue.destination as! ResultViewController
            destination.keyword = textField.text
        }
    }
}

extension SearchViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            performSegue(withIdentifier: "toResult", sender: self)
            textField.placeholder = ""
            textField.text = ""
            return true
        }else{
            textField.placeholder = "Type Something"
            return false
        }
    }
}
 //MARK: - 設定TextField的leftView

class SearchTextField: UITextField {
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            leftViewMode = .always
            let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            imageView.contentMode = .scaleAspectFit
            leftView = imageView
        }
        
        override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
            let width = UIImage(systemName: "magnifyingglass")?.size.width ?? 0
            return CGRect(x: 7, y: 0, width: width, height: 34)
        }
}

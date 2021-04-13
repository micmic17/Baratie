//
//  CheckoutViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 4/7/21.
//

import UIKit
import Braintree
import Firebase

class CheckoutViewController: UIViewController {
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var expDateTextField: UITextField!
    @IBOutlet weak var payNowButton: UIButton!

    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    let datePicker = DatePicker()
    var cartItems: [CartItem] = []
    var totalPrice:Double = 0.0
    var braintreeClient: BTAPIClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTableView.register(UINib(nibName: "CheckoutCell", bundle: nil), forCellReuseIdentifier: "CheckoutCell")
        cvcTextField.text = ""
        cardTextField.text = ""
        addressTextField.text = ""
        addressTextField.placeholder = "Billing Address"
        cardTextField.placeholder = "Card Number"
        expDateTextField.placeholder = "Exp Date"
        cvcTextField.placeholder = "CVC"
        cardTextField.delegate = self
        
        // Temporarily remove credit/debit card text fields
        nameTextField.removeFromSuperview()
        addressTextField.removeFromSuperview()
        cardTextField.removeFromSuperview()
        cvcTextField.removeFromSuperview()
        expDateTextField.removeFromSuperview()
        
        let customer = Customer.getCustoomerData()

        for data in customer {
            nameTextField.text = "\(String(describing: data.firstname!)) \(String(describing: data.lastname!))"
        }

        cvcTextField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        cvcTextField.isSecureTextEntry = true
        cardTextField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        expDateTextField.delegate = self
        datePicker.dataSource = datePicker
        datePicker.delegate = datePicker
        
        customButton(payNowButton)
    }
    
    @IBAction func payCheckoutPressed(_ sender: UIButton) {
        startCheckout()
    }

    func startCheckout() {
        braintreeClient = BTAPIClient(authorization: "sandbox_rzvv9hvn_k6gtx85ddd8n3b3v")!
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient!)
        let request = BTPayPalCheckoutRequest(amount: "\(totalPrice)")
        request.currencyCode = "USD"
    
        payPalDriver.tokenizePayPalAccount(with: request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")

                // Access additional information
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                
                print(email!, firstName!)
                
                CustomerOrder().createOrder(self.cartItems, self.totalPrice, true)
                self.updateFirestore()
                DispatchQueue.main.async {
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: HomeViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            } else if let error = error {
                print(error)
            } else {
                // cancel payment
            }
        }
    }
    
    func updateFirestore() {
        for item in cartItems {
            let ref = db.collection("menus").document(item.id)
            ref.getDocument { documentSnapshot, error in
                if let e = error {
                    print(e)
                } else {
                    if let doc = documentSnapshot?.data() {
                        let doc = doc["quantity"] as! Int16

                        documentSnapshot?.reference.updateData([
                            "quantity": doc - item.quantity
                        ])
                    }
                }
            }
        }
    }

    @objc private func editingChanged(sender: UITextField) {
        let maxLength = sender.placeholder! == "CVC" ? 3 : 16
        
        if let text = sender.text, text.count >= maxLength {
            sender.text = String(text.dropLast(text.count - maxLength))
            return
        }
    }
    
    @objc func doneDatePicker() {
        if expDateTextField.text == "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM222 - yyyy"
            
            expDateTextField.text = "\(dateFormatter)"
        }
        
        expDateTextField.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: .dateChanged, object: nil)
    }
    
    @objc func dateChanged(notification:Notification) {
        let userInfo = notification.userInfo
        if let date = userInfo?["date"] as? String{
            self.expDateTextField.text = date
        }
    }
    
    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertSpacesEveryFourDigitsIntoString(string: cardNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }

    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            } else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }

    func insertSpacesEveryFourDigitsIntoString(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            if i > 0 && (i % 4) == 0 {
                stringWithAddedSpaces.append(contentsOf: " ")
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }

            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
}

extension CheckoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "CheckoutCell", for: indexPath) as! CheckoutCell
        let totalPricePerItem = Double(cartItems[indexPath.row].quantity) * cartItems[indexPath.row].price
        totalPrice += totalPricePerItem

        cell.itemNameLabel.text = cartItems[indexPath.row].name
        cell.quantityLabel.text = "\(cartItems[indexPath.row].quantity)"
        cell.totalPricePerItemLabel.text = "\(totalPricePerItem)"
        return cell
    }
}

extension CheckoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 80))
        let explanationLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 80))
        explanationLabel.textColor = UIColor.darkGray
        explanationLabel.numberOfLines = 0
        explanationLabel.text = "Total: \(totalPrice)"
        explanationLabel.textAlignment = .right
        footerView.addSubview(explanationLabel as UIView)
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
}

extension CheckoutViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == expDateTextField {
            datePicker.selectRow(datePicker.selectedDate(), inComponent: 0, animated: true)
            textField.inputView = datePicker
            let toolBar = UIToolbar(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.frame.width, height: CGFloat(44))))
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDatePicker))
            
            toolBar.setItems([space,doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            toolBar.sizeToFit()
            
            textField.inputAccessoryView = toolBar
            NotificationCenter.default.addObserver(self, selector: #selector(dateChanged(notification:)), name:.dateChanged, object: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardTextField {
            previousTextFieldContent = textField.text;
            previousSelection = textField.selectedTextRange;
        }
        
        return true
    }
}

class DatePicker : UIPickerView {
    var dateCollection = [Date]()
    
    func selectedDate()->Int{
        dateCollection = buildDateCollection()
        var row = 0
        for index in dateCollection.indices{
            let today = Date()
            if Calendar.current.compare(today, to: dateCollection[index], toGranularity: .day) == .orderedSame{
                row = index
            }
        }
        return row
    }
    
    func buildDateCollection()-> [Date]{
        dateCollection.append(contentsOf: Date.previousYear())
        dateCollection.append(contentsOf: Date.nextYear())
        return dateCollection
    }
}

// MARK - Date extension
extension Date {
    static func nextYear() -> [Date]{
        return Date.next(numberOfDays: 365, from: Date())
    }
    
    static func previousYear()-> [Date]{
        return Date.next(numberOfDays: 365, from: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
    }
    
    static func next(numberOfDays: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfDays {
            if let date = Calendar.current.date(byAdding: .month, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
}

// MARK - UIPickerViewDelegate
extension DatePicker : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let date = formatDate(date: self.dateCollection[row])
        NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
        
    }
    func formatDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM - yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK - UIPickerViewDataSource
extension DatePicker : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateCollection.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let label = formatDatePicker(date: dateCollection[row])
        return label
    }
    
    func formatDatePicker(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM - yyyy"
        return dateFormatter.string(from: date)
    }
}

// MARK - Observer Notification Init
extension Notification.Name {
    static var dateChanged : Notification.Name {
        return .init("dateChanged")
    }
}

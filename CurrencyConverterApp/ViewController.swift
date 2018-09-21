//
//  ViewController.swift
//  CurrencyConverterApp
//
//  Created by Dattu Somineni on 9/21/18.
//  Copyright © 2018 Balu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var countryNameUIL : UILabel!
    @IBOutlet weak var amountUITF : UITextField!
    @IBOutlet weak var currencyRatesUITBV : UITableView!
    var currencyRates : CurrencyRates?
    var responceDictionary : NSDictionary = NSDictionary()
    var sortedArray : Array<String> = Array()
    var currencyRateDoubleValue : Double = 1.0
    var finalCurrencyrate : Double = 0.0
    private let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       getCurrentRates()
        if #available(iOS 10.0, *) {
            currencyRatesUITBV.refreshControl = refreshControl
        } else {
            currencyRatesUITBV.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshCurrentRatesData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.blue
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        currencyRatesUITBV.addGestureRecognizer(swipeDown)
    }
    /**
     * Method for disable keyboard while swife down tableview
     */
    @objc func handleGesture(gesture: UISwipeGestureRecognizer)  {
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            amountUITF.resignFirstResponder()
        }
    }
    /**
     * Method for pull to refresh
     */
    @objc private func refreshCurrentRatesData(_ sender: Any) {
        getCurrentRates()
    }
    /**
     * Method for get the currect currency rates using service
     */
    func getCurrentRates()  {
        if !Reachability.isConnectedToNetwork(){
            print("networkProblem")
            return
        }
        ServiceManager.sharedInstance.getResponseForURLWithParameters(url: "https://openexchangerates.org/api/latest.json?app_id=947bb6076b424a79a0c98409ca5903d8", userInfo: nil, type: "GET") { (data, response, error) in
            if error == nil {
                let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                let responseDict:NSDictionary? = jsonObject as? NSDictionary
                if (responseDict != nil) {
                    guard  (responseDict?["error"]) != nil else {
                        CoreDataManager.addNewCurrecncyRatess(responceData: data!)
                        self.currencyRates = CoreDataManager.fetchDetails(entityName: "CurrencyRates").last as? CurrencyRates
                        if let currecyRatesData = self.currencyRates?.exchangesRates{
                            let currecyRatesJsonObject = try? JSONSerialization.jsonObject(with: currecyRatesData, options: JSONSerialization.ReadingOptions.allowFragments)
                            let currecyRatesResponseDict:NSDictionary? = currecyRatesJsonObject as? NSDictionary
                            self.responceDictionary = currecyRatesResponseDict?["rates"] as! NSDictionary
                            print(self.responceDictionary)
                           self.sortedArray = self.responceDictionary.allKeys  as! Array<String>
                           self.sortedArray = self.sortedArray.sorted(by: <)
                            self.refreshControl.endRefreshing()
                            self.amountUITF.resignFirstResponder()
                            self.currencyRatesUITBV.reloadData()
                        }
                        return
                    }
                    print("error")
                }
            }
            else{
                print("Get Leave list failed : \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
// Mark:- Tableview Delegate and Data Source Methods
extension ViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell    =  UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "cell")
        let key = sortedArray[indexPath.row]
        cell.textLabel?.text = key
      //  print(responceDictionary[key])
        if let ratesStr = (responceDictionary[key]){
            if let value = ratesStr as? Double{
                    cell.detailTextLabel?.text = String(format: "%.6f",(value  * finalCurrencyrate))
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sortedArray[indexPath.row]
        countryNameUIL.text = key
        if let ratesStr = (responceDictionary[key]){
            if let value = ratesStr as? Double{
                currencyRateDoubleValue = value
                if let text = amountUITF?.text{
                    calculatingRates(str: text)
                }
            }
        }
    }
    func tableView( _ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let footerView = UIView()
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
//Mark:- TextField Delegate Methods
extension ViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return true
        }
      calculatingRates(str: updatedString)
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func calculatingRates(str : String){
        if let value = Double(str){
            finalCurrencyrate  = value/currencyRateDoubleValue
            currencyRatesUITBV.reloadData()
        }
    }
}

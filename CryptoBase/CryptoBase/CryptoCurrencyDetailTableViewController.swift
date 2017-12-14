//
//  CryptoCurrencyDetailTableViewController.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 12.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import UIKit
import CoreData

class CryptoCurrencyDetailTableViewController: UITableViewController {
    
    var cryptoCurrency: CryptoCurrency?
    
    var bankInput: String = ""
    
    //var bank = Bank()


    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var valueInUSD: UILabel!
    @IBOutlet weak var valueRecentHour: UILabel!
    @IBOutlet weak var valueRecent24Hrs: UILabel!
    @IBOutlet weak var valueRecent7Days: UILabel!
    @IBOutlet weak var valueInSelectedCryptoCurrency: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = cryptoCurrency?.name
        
        
        guard let cryptoCurrencySymbol = cryptoCurrency?.symbol else {
            return
        }
        bankInput = "saldo\(cryptoCurrencySymbol)"

        
        //PERSISTENT_STORAGE_TRIAL
        getDataFromPersistentStorage()
       
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Buy", style: .plain, target: self, action: #selector(buyTapped))
        
        symbolLabel.text = cryptoCurrency?.symbol
        valueInUSD.text = cryptoCurrency?.price_usd.map{"$" + $0}
        
        let data: [UILabel:String] = [
            valueRecentHour : (cryptoCurrency?.percent_change_1h)!,
            valueRecent24Hrs : (cryptoCurrency?.percent_change_24h)!,
            valueRecent7Days : (cryptoCurrency?.percent_change_7d)!
        ]
        
        for(key, value) in data {
            formatData(key: key, str: value, dict: data)
        }
    }
    
    func formatData(key: UILabel, str: String, dict: [UILabel:String]) {
        let appleRed : UIColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0)
        let appleGreen : UIColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        
        key.text = dict[key]!
        
        if dict[key]!.range(of: "-") != nil {
            key.text = dict[key].map{$0 + "%"}
            key.textColor = appleRed
        } else {
            key.text = dict[key].map{"+" + $0 + "%"}
            key.textColor = appleGreen
        }
    }
    
    @objc func buyTapped() {
        
        /*guard let cryptoCurrencySymbol = cryptoCurrency?.symbol else {
            return
        }*/
        
        let alert = UIAlertController(title: "Buy: \(String(describing: cryptoCurrency))", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "amount."
        })
        let cancelAction = UIAlertAction(title: "Abort", style: .default)
        
        let buyAction = UIAlertAction(title: "Confirm", style: .default, handler: {(action) in
            guard let sum = alert.textFields![0].text, let sumFormatted = Double(sum) else {return}
            
            //let bankInput = "saldo\(cryptoCurrencySymbol)" //MAKING GLOBAL
            
            self.addDataToPersisentStorage(sumFormatted: sumFormatted, bankInput: self.bankInput)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(buyAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addDataToPersisentStorage(sumFormatted: Double, bankInput: String) {
        
        //TRIAL PERSITENT_INSERT
        let entity = NSEntityDescription.entity(forEntityName: "Bank", in: PersistenceService.context)
        let bank = Bank(entity: entity!, insertInto: PersistenceService.context)
        
        
        var bankAccess: Bool = true
        
        let fetchRequest: NSFetchRequest<Bank> = Bank.fetchRequest()
        
        //var oldAmount: Double = 0.0
        //var newTotalAMount: Double = 0.0

        
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            for data in result {
                data.setValue(data.value(forKey: "\(self.bankInput)") as! Double + sumFormatted, forKey: "\(self.bankInput)")
                break
            }
        } catch {
            
        }
        
        
        
        if(bankAccess) {
            print("Bank access granted!")
            PersistenceService.saveContext()
        }
        
        
        
        getDataFromPersistentStorage()
        tableView.reloadData()
        
    }
    
    func getDataFromPersistentStorage() -> Double {
        
        let fetchRequest: NSFetchRequest<Bank> = Bank.fetchRequest()
        var cryptoCurrencyAmount: Double = 0
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            for data in result {
                cryptoCurrencyAmount += data.value(forKey: "\(self.bankInput)") as! Double
                //print("Whats in db for :" + "\(self.bankInput)")
                //print(cryptoCurrencyAmount)
            }
            self.valueInSelectedCryptoCurrency.text = String(cryptoCurrencyAmount)
        } catch {
            
        }
        guard let cryptoCurrencyInNok = self.cryptoCurrency?.price_nok else {
            return 0.0        }
        let total: Double = cryptoCurrencyAmount * Double(cryptoCurrencyInNok)!
        valueInSelectedCryptoCurrency.text = String(total)
        
        
        
        return cryptoCurrencyAmount
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        if(getDataFromPersistentStorage() == 0) {
            return count - 1
        }
        return count
    }
    
    

    
    
    

}






/*
 
 func addDataToPersisentStorage(sumFormatted: Double, bankInput: String) {
 
 //TRIAL PERSITENT_INSERT
 let entity = NSEntityDescription.entity(forEntityName: "Bank", in: PersistenceService.context)
 let bank = Bank(entity: entity!, insertInto: PersistenceService.context)
 
 
 //bank.setValue(22, forKey: "saldoBTC")
 
 
 var bankAccess: Bool = true
 getDataFromPersistentStorage()
 
 switch self.bankInput {
 case "saldoBTC":
 bank.saldoBTC = sumFormatted
 print("BTC")
 case "saldoETH":
 bank.saldoETH = sumFormatted
 print("ETH")
 case "saldoBCH":
 bank.saldoBCH = sumFormatted
 print("BCH")
 case "saldoLTC":
 bank.saldoLTC = sumFormatted
 print("LTC")
 case "saldoXRP":
 bank.saldoXRP = sumFormatted
 print("XRP")
 case "saldoMIOTA":
 bank.saldoMIOTA = sumFormatted
 print("MIOTA")
 case "saldoDASH":
 bank.saldoDASH = sumFormatted
 print("DASH")
 case "saldoXEM":
 bank.saldoXEM = sumFormatted
 print("XEM")
 case "saldoXMR":
 bank.saldoXMR = sumFormatted
 print("XMR")
 case "saldoBTG":
 bank.saldoBTG = sumFormatted
 print("BTG")
 
 default:
 bankAccess = false
 }
 
 if(bankAccess) {
 print("Currency: " + bankInput)
 print("Bank access granted!")
 PersistenceService.saveContext()
 }
 getDataFromPersistentStorage()
 
 }
 
 
 
 */


/* UGLY SWITCH.2
 
 
 
 switch self.bankInput {
 case "saldoBTC":
 let oldAmount = data.value(forKey: "saldoBTC") as! Double
 print("Old amount: " + "\(oldAmount)")
 //let newTotalAMount = oldAmount + sumFormatted
 //print("New total amount: " + "\(newTotalAMount)")
 
 //data.setValue((data.value(forKey: "saldoBTC") as! Double + sumFormatted), forKey: "saldoBTC")
 
 
 //data.setValue(newTotalAMount, forKey: "saldoBTC")
 //print("BTC")
 case "saldoETH":
 data.setValue(sumFormatted, forKey: "saldoETH")
 //print("ETH")
 case "saldoBCH":
 data.setValue(sumFormatted, forKey: "saldoBCH")
 //print("BCH")
 case "saldoLTC":
 data.setValue(sumFormatted, forKey: "saldoLTC")
 //print("LTC")
 case "saldoXRP":
 data.setValue(sumFormatted, forKey: "saldoXRP")
 //print("XRP")
 case "saldoMIOTA":
 data.setValue(sumFormatted, forKey: "saldoMIOTA")
 //print("MIOTA")
 case "saldoDASH":
 data.setValue(sumFormatted, forKey: "saldoDASH")
 //print("DASH")
 case "saldoXEM":
 data.setValue(sumFormatted, forKey: "saldoXEM")
 //print("XEM")
 case "saldoXMR":
 data.setValue(sumFormatted, forKey: "saldoXMR")
 //print("XMR")
 case "saldoBTG":
 data.setValue(sumFormatted, forKey: "saldoBTG")
 //print("BTG")
 default:
 bankAccess = false
 }
 
 
 
 */



/*
 
 func getDataFromPersistentStorage() -> Double {
 
 let fetchRequest: NSFetchRequest<Bank> = Bank.fetchRequest()
 var cryptoCurrencyAmount: Double = 0
 do {
 let result = try PersistenceService.context.fetch(fetchRequest)
 for data in result {
 cryptoCurrencyAmount += data.value(forKey: "\(self.bankInput)") as! Double
 }
 self.valueInSelectedCryptoCurrency.text = String(cryptoCurrencyAmount)
 } catch {
 
 }
 guard let cryptoCurrencyInNok = self.cryptoCurrency?.price_nok else {
 return 0.0        }
 let total: Double = cryptoCurrencyAmount * Double(cryptoCurrencyInNok)!
 valueInSelectedCryptoCurrency.text = String(total)
 
 print("Whats in db:")
 print(cryptoCurrencyAmount)
 
 return cryptoCurrencyAmount
 
 }
 
 
 */

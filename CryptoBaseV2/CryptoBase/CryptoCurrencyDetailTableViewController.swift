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
    var totalValueInNok: Double = 0

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var valueInUSD: UILabel!
    @IBOutlet weak var valueRecentHour: UILabel!
    @IBOutlet weak var valueRecent24Hrs: UILabel!
    @IBOutlet weak var valueRecent7Days: UILabel!
    @IBOutlet weak var valueInSelectedCryptoCurrency: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = cryptoCurrency?.name
        getDataFromPersistentStorage()
       
        SetUpUI()
    }
    
    func SetUpUI() {
        
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
        
        let alert = UIAlertController(title: "Buy: \(String(describing: cryptoCurrency))", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "amount."
        })
        let cancelAction = UIAlertAction(title: "Abort", style: .default)
        
        let buyAction = UIAlertAction(title: "Confirm", style: .default, handler: {(action) in
            guard let sum = alert.textFields![0].text, let sumFormatted = Double(sum) else {return}
            
            self.addDataToPersisentStorage(sumFormatted: sumFormatted)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(buyAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addDataToPersisentStorage(sumFormatted: Double?) {
        
        let cryptoCurrencyCD = CryptoCurrencyCD(context: PersistenceService.context)
        
        guard let symbol = self.cryptoCurrency?.symbol, let name = self.cryptoCurrency?.name,
        let price_nok = self.cryptoCurrency?.price_nok, let amount = sumFormatted else {
            return
        }
        cryptoCurrencyCD.symbol = symbol
        cryptoCurrencyCD.name = name
        cryptoCurrencyCD.price_nok = price_nok
        cryptoCurrencyCD.amount = String(amount)
        cryptoCurrencyCD.tablePosition = 0
        
        PersistenceService.saveContext()
        getDataFromPersistentStorage()
        tableView.reloadData()
    }
    
    func getDataFromPersistentStorage()  {
        
        let fetchRequest: NSFetchRequest<CryptoCurrencyCD> = CryptoCurrencyCD.fetchRequest()
        let sortCriteria = NSSortDescriptor(key: "symbol", ascending: true)
        fetchRequest.sortDescriptors = [sortCriteria]
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            
            guard let symbol = cryptoCurrency?.symbol else { return }

            let matches = result.filter{ $0.symbol == symbol }
            let mapMatches = matches.map{($0.amount as! NSString).doubleValue}
            let amountOfCC = mapMatches.reduce(0) { $0 + $1}
            
            guard let price_nok = cryptoCurrency?.price_nok else { return }
            self.totalValueInNok = (Double(price_nok)! * amountOfCC)
            self.valueInSelectedCryptoCurrency.text = String(self.totalValueInNok)
            
            tableView.reloadData()
        } catch {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        if(totalValueInNok == 0) {
            return count - 1
        }
        return count
    }
}

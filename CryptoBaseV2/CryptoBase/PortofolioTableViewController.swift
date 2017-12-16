//
//  PortofolioTableViewController.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 13.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import UIKit
import CoreData


class PortofolioTableViewController: UITableViewController {
    
    @IBOutlet var portofolioTableView: UITableView!
    
    final let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?convert=NOK&limit=10")
    
    private var cryptoCurrencies = [CryptoCurrency]()
    
    var cryptoCurrenciesFromDB = [NSDictionary()]
    
    var totalValueInNok: Double = 0
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        downLoadJSON()
        getDataFromPersistentStorage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cryptoCurrenciesFromDB = [NSDictionary()]
        cryptoCurrencies = [CryptoCurrency]()
        
    }
    
    func downLoadJSON() {
        guard let downloadUrl = url else { return }
        URLSession.shared.dataTask(with: downloadUrl) { (data, urlResponse, error) in
            guard let data = data, error == nil, urlResponse != nil else {
                print("somethin went wrong!")
                return
            }
            print("downloaded!")
            do {
                let decoder = JSONDecoder()
                let downloadedData = try decoder.decode([CryptoCurrency].self, from: data)
                self.cryptoCurrencies = downloadedData
                DispatchQueue.main.async {
                    self.totalValueInNok = 0
                    self.tableView.reloadData()
                }
            } catch {
                print("error after downloading!")
            }
            }.resume()
    }
    
    func getDataFromPersistentStorage() {
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append("symbol" as AnyObject)
        
        let keyPath = NSExpression(forKeyPath: "amount")
        let expression = NSExpression(forFunction: "sum:", arguments: [keyPath])
        let sumDescript = NSExpressionDescription()
        sumDescript.expression = expression
        sumDescript.name = "sum"
        sumDescript.expressionResultType = .integer64AttributeType
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CryptoCurrencyCD")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["symbol"]

        request.propertiesToFetch = ["symbol", sumDescript]
        request.resultType = .dictionaryResultType
        
        do {
            let results = try PersistenceService.context.fetch(request)
            if let results = results as? [NSDictionary] {
                self.cryptoCurrenciesFromDB = results
            }
            
        } catch _ {
            
        }
        tableView.reloadData()
    }
    
    func addDataToPersisentStorage(sumFormatted: Double?, cryptoCurrency: String) {
        self.totalValueInNok = 0

        guard let amount = sumFormatted else {
            return
        }
        
        let cryptoCurrencyCD = CryptoCurrencyCD(context: PersistenceService.context)
        
        cryptoCurrencyCD.symbol = cryptoCurrency
        cryptoCurrencyCD.amount = String(amount)
        cryptoCurrencyCD.tablePosition = 0
        
        PersistenceService.saveContext()
        getDataFromPersistentStorage()
        tableView.reloadData()
    }
}

extension PortofolioTableViewController {
    

   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        let totalNokFormatted = formatter.string(from: totalValueInNok as NSNumber)
        return "Total(NOK): \(totalNokFormatted!)"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptoCurrenciesFromDB.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortofolioCell", for: indexPath) as! PortofolioTableViewCell
        let currentSymbol: String = String(describing: cryptoCurrenciesFromDB[indexPath.row]["symbol"]!)
        cell.cryptoCurrencyLabel.text = currentSymbol
        cell.cryptoCurrencyAmountLabel.text = String(describing: cryptoCurrenciesFromDB[indexPath.row]["sum"]!)
        
        if(cryptoCurrencies.count > 0) {
            

            
            var valueInNok: String = ""
            
            for data in self.cryptoCurrencies {
                if(data.symbol! == currentSymbol) {
                    valueInNok = data.price_nok!
                }
            }
            
            let cryptoAMount: Double = (cryptoCurrenciesFromDB[indexPath.row]["sum"] as? Double)!
            let total: Double = Double(valueInNok)! * cryptoAMount
            
            self.totalValueInNok += total
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            let totalFormatted = formatter.string(from: total as NSNumber)
            
            cell.cryptoCurrencyInNok.text = totalFormatted
        }
        

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Manage Cryptocurrency", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "amount."
        })
        let cancelAction = UIAlertAction(title: "Abort", style: .default)
        
        let updateAction = UIAlertAction(title: "Confirm", style: .default, handler: {(action) in
            guard let sum = alert.textFields![0].text, let sumFormatted = Double(sum) else {return}
            let currentSymbol: String = String(describing: self.cryptoCurrenciesFromDB[indexPath.row]["symbol"]!)
            self.addDataToPersisentStorage(sumFormatted: sumFormatted, cryptoCurrency: currentSymbol)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(updateAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

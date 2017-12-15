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
   
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        downLoadJSON()



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
    
    
    
    

}


extension PortofolioTableViewController {
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Total"
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptoCurrenciesFromDB.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortofolioCell", for: indexPath) as! PortofolioTableViewCell
        cell.cryptoCurrencyLabel.text = String(describing: cryptoCurrenciesFromDB[indexPath.row]["symbol"]!)
        cell.cryptoCurrencyAmountLabel.text = String(describing: cryptoCurrenciesFromDB[indexPath.row]["sum"]!)
        
        
        if(cryptoCurrencies.count > 0) {
            guard let valueInNok = cryptoCurrencies[indexPath.row].price_nok else {
                return UITableViewCell()
            }
            let cryptoAMount: Double = (cryptoCurrenciesFromDB[indexPath.row]["sum"] as? Double)!
            let total: Double = Double(valueInNok)! * cryptoAMount
            let totalFormatted: String = String(format: "%.1f", total)
            cell.cryptoCurrencyInNok.text = totalFormatted
        }
        
        
        
        
        return cell
    }
}





/* YET ANOTHER FAIL
 
 
 let fetchRequest: NSFetchRequest<CryptoCurrencyCD> = CryptoCurrencyCD.fetchRequest()
 let symbol = "BTC"
 fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
 fetchRequest.resultType = .dictionaryResultType
 let sumExpression = NSExpression(format: "sum(amount)")
 let sumED = NSExpressionDescription()
 sumED.expression = sumExpression
 sumED.name = "sumOfAmount"
 sumED.expressionResultType = .doubleAttributeType
 fetchRequest.propertiesToFetch = ["symbol"]
 let sort = NSSortDescriptor(key: "symbol", ascending: false)
 fetchRequest.sortDescriptors = [sort]
 
 do {
 let results = try PersistenceService.context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
 
 
 } catch let error as NSError {
 print("Fetch failed: \(error.localizedDescription)")
 }

 
 /*for data in self.cryptoCurrencies {
 print("Data fro db: \(data.symbol!)")
 self.cryptoCurrencies.filter()
 }*/
 //let countedSet = NSCountedSet(array: self.cryptoCurrencies.map{$0.amount})
 /*let countedSet = NSCountedSet(array: result)
 for value in countedSet.allObjects {
 print("Element: \(value), count:, \(countedSet.count(for: value))")
 }*/
 
 //let counts = result.reduce(into: [:]) {counts, word in counts[word, default: 0] += 1}
 
 
 var arrays = [
 ["Product":"Item0", "Price":"15"],
 ["Product":"Item1", "Price":"53"],
 ["Product":"Item2", "Price":"12"],
 ["Product":"Item1", "Price":"83"],
 ["Product":"Item0", "Price":"10"],
 ["Product":"Item3", "Price":"88"],
 ["Product":"Item0", "Price":"44"]
 ]
 
 var result = [String : Int]()
 
 for product in arrays {
 
 if let productKey = product["Product"] {
 let value = Int(product["Price"] ?? "0")
 if result[productKey] == nil, let value = value {
 result[productKey] = value
 } else if let value = value {
 result[productKey]! += value
 }
 }
 }
 
 let newArray = result.map {["Product":$0, "Price": $1]}
 for data in newArray {
 print(data)
 }
 
 
 
 
 //V2
 
 
 var expressionDescriptions = [AnyObject]()
 expressionDescriptions.append("symbol" as AnyObject)
 
 
 let expressionDescription = NSExpressionDescription()
 expressionDescription.name = "amountCount"
 expressionDescription.expression = NSExpression(format: "@sum.amount")
 expressionDescription.expressionResultType = .stringAttributeType
 expressionDescriptions.append(expressionDescription)
 
 let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CryptoCurrencyCD.fetchRequest()
 fetchRequest.propertiesToGroupBy = ["symbol"]
 fetchRequest.resultType = .dictionaryResultType
 
 fetchRequest.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]
 fetchRequest.propertiesToFetch = expressionDescriptions
 
 var results:[[String:AnyObject]]?
 
 
 do {
 //let result = try PersistenceService.context.fetch(fetchRequest)
 //self.cryptoCurrencies = result
 results = try PersistenceService.context.fetch(fetchRequest) as? [[String:AnyObject]]
 
 //print(results)
 
 } catch _ {
 results = nil
 }
 //print(results)
 
 }
 
 func downloadJSON() {
 
 }
 
 
 
 }
 
 
 extension PortofolioTableViewController {
 
 override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
 return "Total"
 }
 
 
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return 0
 }
 
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let cell = tableView.dequeueReusableCell(withIdentifier: "PortofolioCell", for: indexPath) as! PortofolioTableViewCell
 
 
 
 return cell
 }
 }
 
 
 
 
 let arrCryptoVals = [
 "BTC",
 "ETH",
 "BCH",
 "LTC",
 "XRP",
 "MIOTA",
 "DASH",
 "XEM",
 "XMR",
 "BTG"
 ]
 
 for saldoType in arrCryptoVals {
 getDataFromPersistentStorage()
 }
 
 */

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
                    self.tableView.reloadData() //ORIGINAL
                }
            } catch {
                print("error after downloading!")
            }
            }.resume()
    }
    
    func getDataFromPersistentStorage() {
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append("symbol" as AnyObject)
        
        let predicate = NSPredicate(format: "symbol != nil")
        
        let keyPath = NSExpression(forKeyPath: "amount")
        let expression = NSExpression(forFunction: "sum:", arguments: [keyPath])
        let sumDescript = NSExpressionDescription()
        sumDescript.expression = expression
        sumDescript.name = "sum"
        sumDescript.expressionResultType = .integer64AttributeType
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CryptoCurrencyCD")
        
        request.predicate = predicate
        
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["symbol"]

        request.propertiesToFetch = ["symbol", sumDescript]
        request.resultType = .dictionaryResultType
        
        do {
            let results = try PersistenceService.context.fetch(request)
            if let results = results as? [NSDictionary] {
                self.cryptoCurrenciesFromDB = results //ORIGINAL
                tableView.reloadData() //ORIGINAL
            }
        } catch _ {
            
        }
    }
    
    func addDataToPersisentStorage(sumFormatted: Double?, cryptoCurrency: String) {
        self.totalValueInNok = 0

        guard let amount = sumFormatted else {
            return
        }
        
        let fetchRequest: NSFetchRequest<CryptoCurrencyCD> = CryptoCurrencyCD.fetchRequest()
        let cryptoCurrencyCD = CryptoCurrencyCD(context: PersistenceService.context)
        
        var amountOfCC: Double = 0

        
        //DELETE 0 OR MINUS VALUES
        if let result = try? PersistenceService.context.fetch(fetchRequest) {
            
            for data in result {
                print("Data in result: \(data.name ?? "undfined")")
                let matches = result.filter{ $0.symbol == cryptoCurrency }
                let mapMatches = matches.map{($0.amount! as NSString).doubleValue}
                amountOfCC = mapMatches.reduce(0) { $0 + $1}
                print("Total value for \(String(describing: data.symbol)): \(amountOfCC)")
                if(data.symbol == cryptoCurrency) {
                    break
                }
            }
            
        }
        
        print("Previous amount - input_amount: \(amountOfCC - fabs(amount))")
        
        
        if(amountOfCC - fabs(amount) <= 0) {
            print("DELETING OBJECT BECAUSE OF O OR MINUS VALUES")
            deleteFromPersistentStorage(symbol: cryptoCurrency)
        } else {
            cryptoCurrencyCD.symbol = cryptoCurrency
            cryptoCurrencyCD.amount = String(amount)
            cryptoCurrencyCD.tablePosition = 0
            PersistenceService.saveContext() //ORIGINAL
            getDataFromPersistentStorage()
            tableView.reloadData() //ORIGINAL
        }
    }
    
    func deleteFromPersistentStorage(symbol: String)  {
        print("Lets delete!")
        let fetchRequest: NSFetchRequest<CryptoCurrencyCD> = CryptoCurrencyCD.fetchRequest()

        
        if let result = try? PersistenceService.context.fetch(fetchRequest) {
            for data in result {
                if(data.symbol == symbol) {
                    cryptoCurrencies = [CryptoCurrency]() //EXPERIMENTAL
                    PersistenceService.context.delete(data)
                }
            }
            PersistenceService.saveContext()
            tableView.reloadData()
            getDataFromPersistentStorage()
            downLoadJSON()

        }
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
        print("WHATS ARR FOR DB COUNT? \(cryptoCurrenciesFromDB.count)")
        if(cryptoCurrenciesFromDB.count <= 0) {
            return 0
        } else {
            return cryptoCurrenciesFromDB.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortofolioCell", for: indexPath) as! PortofolioTableViewCell
        
        let currentSymbol: String = String(describing: cryptoCurrenciesFromDB[indexPath.row]["symbol"]!) //ORIGINAL
        cell.cryptoCurrencyLabel.text = currentSymbol
        cell.cryptoCurrencyAmountLabel.text = String(describing: cryptoCurrenciesFromDB[indexPath.row]["sum"]!) //ORIGINAL
        
        
        if(cryptoCurrencies.count > 0) {
            
            var valueInNok: String = ""
            
            for data in self.cryptoCurrencies {
                if(data.symbol! == currentSymbol as! String) {
                    valueInNok = data.price_nok!
                }
            }
            
            let cryptoAMount: Double = (cryptoCurrenciesFromDB[indexPath.row]["sum"] as? Double)! //ORIGINAL
            let total: Double = Double(valueInNok)! * cryptoAMount //ORIGINAL
            
            self.totalValueInNok += total //ORIGINAL
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 2
            let totalFormatted = formatter.string(from: total as NSNumber) //ORIGINAL
            
            cell.cryptoCurrencyInNok.text = totalFormatted //ORIGINAL
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
            
            let currentSymbol: String = String(describing: self.cryptoCurrenciesFromDB[indexPath.row]["symbol"]!) //ORIGINAL
            
            self.addDataToPersisentStorage(sumFormatted: sumFormatted, cryptoCurrency: currentSymbol)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(updateAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

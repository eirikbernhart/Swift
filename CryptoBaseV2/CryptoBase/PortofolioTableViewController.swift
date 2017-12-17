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
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        request.propertiesToGroupBy = ["symbol", "tablePosition"]

        request.propertiesToFetch = ["symbol", "tablePosition", sumDescript]
        request.resultType = .dictionaryResultType
        
        do {
            let results = try PersistenceService.context.fetch(request)
            if let results = results as? [NSDictionary] {
                
                //WILL INITIALY SORT BY SYMBOL-NAME
                self.cryptoCurrenciesFromDB = results //ORIGINAL
                for data in results {
                    //DATA WILL BE SORTED BY TABLE_POSITION AS TABLE-REORDERING HAS BEEN MADE
                    if(data["tablePosition"] as! Int > -1) {
                        self.cryptoCurrenciesFromDB.sort { ($0["tablePosition"] as! Int) < ($1["tablePosition"] as! Int) }
                    }
                }
                tableView.reloadData()
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
        
        
        
        
        
        
        //DELETE 0 OR MINUS VALUES
        if(amountOfCC - fabs(amount) <= 0) {
            deleteFromPersistentStorage(symbol: cryptoCurrency)
        } else {
            do {
                let result = try PersistenceService.context.fetch(fetchRequest)
                for data in result {
                    if(data.tablePosition > -1) {
                        cryptoCurrencyCD.symbol = cryptoCurrency
                        cryptoCurrencyCD.amount = String(amount)
                        cryptoCurrencyCD.tablePosition = data.tablePosition
                        PersistenceService.saveContext() //ORIGINAL
                        getDataFromPersistentStorage()
                        tableView.reloadData() //ORIGINAL
                    } else {
                        cryptoCurrencyCD.symbol = cryptoCurrency
                        cryptoCurrencyCD.amount = String(amount)
                        cryptoCurrencyCD.tablePosition = -1 //Experimental
                        PersistenceService.saveContext() //ORIGINAL
                        getDataFromPersistentStorage()
                        tableView.reloadData() //ORIGINAL
                    }
                }
            } catch {
                
            }
            
            //ORIGINAL BLOCK!
            //cryptoCurrencyCD.symbol = cryptoCurrency
            //cryptoCurrencyCD.amount = String(amount)
            //cryptoCurrencyCD.tablePosition = 0 //ORIGINAL
            //PersistenceService.saveContext() //ORIGINAL
            //getDataFromPersistentStorage()
            //tableView.reloadData() //ORIGINAL
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
    
    func updateCellPositon(symbolOnCurrentCell: String, newPosition: Int) {
        
        print("Symbol in updateCellPosition: \(symbolOnCurrentCell)")
        
        let fetchRequest: NSFetchRequest<CryptoCurrencyCD> = CryptoCurrencyCD.fetchRequest()
        
        if let result = try? PersistenceService.context.fetch(fetchRequest) {
            for data in result {
                if(data.symbol == symbolOnCurrentCell) {
                    data.tablePosition = Int16(newPosition)
                    //print("(\(symbolOnCurrentCell)), Changed to pos: \(newPosition)")
                }
            }
            PersistenceService.saveContext()
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
        
        let currentPosInDB: String = String(describing: cryptoCurrenciesFromDB[indexPath.row]["tablePosition"]!) //ORIGINAL
        print("Current position in DB: \(currentPosInDB)")

        
        if(cryptoCurrencies.count > 0) {
            
            var valueInNok: String = ""
            
            for data in self.cryptoCurrencies {
                if(data.symbol! == currentSymbol) {
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
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("METHOD RUNNING?")
        
        guard let currentCell = cryptoCurrenciesFromDB[sourceIndexPath.row] as NSDictionary? else { return }
        guard let currentSymbol = cryptoCurrenciesFromDB[sourceIndexPath.row]["symbol"] else { return }
        

        cryptoCurrenciesFromDB.remove(at: sourceIndexPath.row)
        cryptoCurrenciesFromDB.insert(currentCell, at: destinationIndexPath.row)
        
        var index = 0;
        for (data) in cryptoCurrenciesFromDB {
            updateCellPositon(symbolOnCurrentCell: data["symbol"] as! String, newPosition: index)
            //print("\(data["symbol"]!) is at: \(index), after re-oredering")
            index += 1
            
        }
        
        //updateCellPositon(symbolOnCurrentCell: currentSymbol as! String, newPosition: destinationIndexPath.row)
        
        totalValueInNok = 0
        
        print("METHOD MADE IT TO THE END?")


        tableView.reloadData()
    }
}

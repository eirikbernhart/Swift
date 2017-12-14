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

    var cryptoCurrencies = [CryptoCurrency]()
    var cryptoCurrencyTypes = [String]()
    var cryptoCurrencyAmounts = [Double]()
    var cryptoCurrenciesInNok = [String?]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        


        //print("ViewDidLoad")
        //self.portofolioTableView.reloadData()
        //setUp()


        
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downLoadJSON()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cryptoCurrencyTypes = [String]()
        self.cryptoCurrencyAmounts = [Double]()
        self.cryptoCurrencies = [CryptoCurrency]()
        self.cryptoCurrenciesInNok = [String?]()
    }
    
    func setUp() {
        
        print("Hva haru?!?!?")

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
            getDataFromPersistentStorage(saldoType: saldoType)
        }
        
        
        
        
    }
    
    
    func getDataFromPersistentStorage(saldoType: String) {
        
        
        let fetchRequest: NSFetchRequest<Bank> = Bank.fetchRequest()
        var cryptoCurrencyAmount: Double = 0
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            for data in result {
                cryptoCurrencyAmount += data.value(forKey: "saldo\(saldoType)") as! Double
                

            }
            if(cryptoCurrencyAmount > 0) {
                self.cryptoCurrencyAmounts.append(cryptoCurrencyAmount)
                self.cryptoCurrencyTypes.append(saldoType)
                print("Cryptocurrencies length: \(self.cryptoCurrencies.count)")
                for val in self.cryptoCurrencies {
                    print("DID IT RUN ON REFRESH?")
                    if(val.symbol == saldoType) {
                        guard let nok = val.price_nok else { return }
                        self.cryptoCurrenciesInNok.append(nok)
                    }
                }

                
            }

            
        } catch {
            
        }
        
        print("You have: \(cryptoCurrencyAmount) of \(saldoType)")
        DispatchQueue.main.async {
            self.portofolioTableView.reloadData()
        }
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
                print("HVA ERE I DENNE JSON BULKEN: \(self.cryptoCurrencies)")
                DispatchQueue.main.async {
                    self.portofolioTableView.reloadData()
                }
                self.setUp() //RE-runs
            } catch {
                print("error after downloading!")
            }
            }.resume()
    }
    
    

}


extension PortofolioTableViewController {
    
    
    
    
    
    
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Total"
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptoCurrencyAmounts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortofolioCell", for: indexPath) as! PortofolioTableViewCell
        
        cell.cryptoCurrencyLabel.text = cryptoCurrencyTypes[indexPath.row]
        cell.cryptoCurrencyAmountLabel.text = String(cryptoCurrencyAmounts[indexPath.row])
        
        
        if(self.cryptoCurrenciesInNok.count > 0) {
            
            
            guard let valueInNok = self.cryptoCurrenciesInNok[indexPath.row] else {
                return UITableViewCell()
            }
            
            let cryptoAmount: Double = cryptoCurrencyAmounts[indexPath.row]
            let total: Double = Double(valueInNok)! * cryptoAmount
            let totalFormatted: String = String(format: "%.1f", total)
            cell.cryptoCurrencyInNok.text = String(totalFormatted)
 
            
        }
        return cell
    }
    
    
    
    
    
}



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
 
 print("COUNT: \(self.cryptoCurrencies.count)")
 
 guard let cryptoSymbol = self.cryptoCurrencies[indexPath.row].symbol else {
 return UITableViewCell()
 }
 print("NAME: \(cryptoSymbol)")
 if(cryptoSymbol != cryptoCurrencyTypes[indexPath.row]) {
 //self.cryptoCurrencies.remove(at: indexPath.row)
 }
 

 
 */
    
    
    
    
    
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



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

   
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //downLoadJSON()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setUp() {
        
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
        
        
        let fetchRequest: NSFetchRequest<CryptoCurrencyCD> = CryptoCurrencyCD.fetchRequest()
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            for data in result {
                print("Data fro db: \(data)")
            }
            
        } catch {
            
        }
    }
    
    func downLoadJSON() {
    
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
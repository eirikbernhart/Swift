//
//  DashBoardViewController.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 11.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import UIKit

class DashboardTableViewController: UITableViewController {
    
    final let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?convert=NOK&limit=10")
    private var cryptoCurrencies = [CryptoCurrency]()
    @IBOutlet var dashboardTableView: UITableView!
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        downLoadJSON()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
                    self.dashboardTableView.reloadData()
                }
            } catch {
                print("error after downloading!")
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detailViewController = segue.destination as? CryptoCurrencyDetailTableViewController, let indexPath = tableView.indexPathForSelectedRow {
            
            
            let cryptoCurrency = cryptoCurrencies[indexPath.row]
            detailViewController.cryptoCurrency = cryptoCurrency
        }
        
    }
    
    
}

extension DashboardTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptoCurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardTableViewCell
        let cryptoCurrency = cryptoCurrencies[indexPath.row]
       
        
        guard let value = cryptoCurrency.price_nok, let name = cryptoCurrency.name  else {
            return UITableViewCell()
        }
        let priceFormatted = String(format: "%.1f", Double(value)!) + " kr"
        
        cell.currencyLabel?.text = name
        cell.currencyValueLabel?.text = priceFormatted



        return cell
    }
    
    
}







// MARK: - Table view data source

/*
 override func numberOfSections(in tableView: UITableView) -> Int {
 // #warning Incomplete implementation, return the number of sections
 return 0
 }
 
 
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

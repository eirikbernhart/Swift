//
//  FetchData.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 15.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import Foundation

class FetchData: Decodable {
    
    private init() {
        
    }
    
    static let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/?convert=NOK&limit=10")

    
    
    
    static func downLoadJSON() -> [CryptoCurrency] {
        
        var downloadedData = [CryptoCurrency]()
        
        guard let downloadUrl = url else { return [CryptoCurrency]() }
        
        URLSession.shared.dataTask(with: downloadUrl) { (data, urlResponse, error) in
            guard let data = data, error == nil, urlResponse != nil else {
                print("somethin went wrong!")
                return
            }
            print("downloaded!")
            do {
                let decoder = JSONDecoder()
                let fetchedData = try decoder.decode([CryptoCurrency].self, from: data)
                downloadedData = fetchedData
                print("DOWNLOADED DATA: \(downloadedData)")

            } catch {
                print("error after downloading!")
            }
            }.resume()
        return downloadedData
        
    }
    
}



/*
 DispatchQueue.main.async {
 self.dashboardTableView.reloadData()
 }
 
 */


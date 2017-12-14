//
//  CryptoCurrency.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 11.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import Foundation

/*class CryptoCurrencies: Codable {
    let cryptoCurrencies: [CryptoCurrency]
    
    init(cryptoCurrencies: [CryptoCurrency]) {
        self.cryptoCurrencies = cryptoCurrencies
    }
}*/

class CryptoCurrency: Codable {
    let name: String?
    let price_usd: String?
    let price_nok: String?
    let symbol: String?
    let percent_change_1h: String?
    let percent_change_24h: String?
    let percent_change_7d: String?

    
    /*init(name: String, price_usd: String) {
        self.name = name
        self.price_usd = price_usd
    }*/
}



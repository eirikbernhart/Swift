//
//  CryptoCurrency.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 11.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//

import Foundation


class CryptoCurrency: Codable {
    let name: String?
    let price_usd: String?
    let price_nok: String?
    let symbol: String?
    let percent_change_1h: String?
    let percent_change_24h: String?
    let percent_change_7d: String?
    var hasValue: Int { return (symbol?.hashValue)! }
}



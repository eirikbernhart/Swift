//
//  CryptoCurrencyCD+CoreDataProperties.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 14.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//
//

import Foundation
import CoreData


extension CryptoCurrencyCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CryptoCurrencyCD> {
        return NSFetchRequest<CryptoCurrencyCD>(entityName: "CryptoCurrencyCD")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var name: String?
    @NSManaged public var amount: String?
    @NSManaged public var tablePosition: Int16
    @NSManaged public var price_nok: String?
    @NSManaged public var price_usd: String?

}

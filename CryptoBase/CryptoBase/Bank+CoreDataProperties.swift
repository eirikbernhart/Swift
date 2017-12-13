//
//  Bank+CoreDataProperties.swift
//  CryptoBase
//
//  Created by eirik Bernhart on 12.12.2017.
//  Copyright © 2017 eirik Bernhart. All rights reserved.
//
//

import Foundation
import CoreData


extension Bank {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bank> {
        return NSFetchRequest<Bank>(entityName: "Bank")
    }
    
    

    @NSManaged public var saldoBTC: Double
    @NSManaged public var saldoETH: Double
    @NSManaged public var saldoBCH: Double
    @NSManaged public var saldoLTC: Double
    @NSManaged public var saldoMIOTA: Double
    @NSManaged public var saldoXRP: Double
    @NSManaged public var saldoDASH: Double
    @NSManaged public var saldoXEM: Double
    @NSManaged public var saldoXMR: Double
    @NSManaged public var saldoBTG: Double
    @NSManaged public var saldoNOK: Double

}

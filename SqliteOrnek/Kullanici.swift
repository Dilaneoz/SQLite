//
//  Kullanici.swift
//  SqliteOrnek
//
//  Created by Dilan Öztürk on 12.03.2023.
//

import Foundation

class Kullanici {
    
    var Id : Int
    var Adi : String?
    var Soyadi : String?
    
    init(Id: Int, Adi: String? = nil, Soyadi: String? = nil) {
        self.Id = Id
        self.Adi = Adi
        self.Soyadi = Soyadi
    }
    
    
    
    
}

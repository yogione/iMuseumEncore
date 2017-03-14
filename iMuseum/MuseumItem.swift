//
//  MuseumItem.swift
//  iMuseum
//
//  Created by Srini Motheram on 2/13/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit

class MuseumItem: NSObject {
    var museumName  :String!
    var street      :String!
    var city        :String!
    var state       :String!
    var locationLat     :Double!
    var locationLon     :Double!
    
    init(museumName: String, street: String, city: String, state: String, lat: Double, lon: Double) {
        
        self.museumName = museumName
        self.street = street
        self.city = city
        self.state = state
        self.locationLat = lat
        self.locationLon = lon
    }

}

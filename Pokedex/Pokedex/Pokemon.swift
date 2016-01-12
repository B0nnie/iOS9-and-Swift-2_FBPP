//
//  Pokemon.swift
//  Pokedex
//
//  Created by Ebony Nyenya on 1/7/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation

class Pokemon {
    
    private (set) var name: String!
    private (set) var pokedexId: Int!
    private (set) var description: String!
    private (set) var type: String!
    private (set) var defense: String!
    private (set) var height: String!
    private (set) var weight: String!
    private (set) var attack: String!
    private (set) var nextEvolutionTxt: String!
    
    
    init(name: String, pokedexId: Int) {
        self.name = name
        self.pokedexId = pokedexId
        
        
    }
    
    
    
    
}
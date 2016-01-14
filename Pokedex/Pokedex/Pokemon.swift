//
//  Pokemon.swift
//  Pokedex
//
//  Created by Ebony Nyenya on 1/7/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

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
    private (set) var pokemonURL: String!
    
    
    init(name: String, pokedexId: Int) {
        self.name = name
        self.pokedexId = pokedexId
        pokemonURL = "\(BASE_URL)\(POKEMON_URL)\(pokedexId)/"
        
    }
    
    //downloading json from pokemon API and parsing json
    func downloadPokemonDetails(completed: DownloadComplete) {
        
        //getting json
        let url = NSURL(string: pokemonURL)!
        Alamofire.request(.GET, url).responseJSON { response in
            
            let json = JSON(response.result.value!)
            
            //parsing json
            
            if let weight = json["weight"].string {
                
                self.weight = weight
            }
            
            if let height = json["height"].string {
                
                self.height = height
            }
            
            if let attack = json["attack"].int {
                
                self.attack = String(attack)
            }
            
            if let defense = json["defense"].int {
                
                self.defense = String(defense)
            }
            
            print("Weight: \(self.weight)")
            print("Height: \(self.height)")
            print("Attack: \(self.attack)")
            print("Defense: \(self.defense)")
            
            if let types = json["types"].array where types.count > 0 {
                
                
                
                if let name = types[0]["name"].string {
                    
                    self.type = name
                }
                
                
                if types.count > 1 {
                    
                    for var i = 1; i < types.count; i++ {
                        if let name = types[i]["name"].string {
                            self.type! += "/\(name)"
                        }
                    }
                    
                } else {
                    
                    self.type = ""
                }
                print("Type(s): \(self.type)")
            }
        }
    }
    
}
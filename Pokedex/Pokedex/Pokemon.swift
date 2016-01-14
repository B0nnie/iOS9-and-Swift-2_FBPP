//
//  Pokemon.swift
//  Pokedex
//
//  Created by Ebony Nyenya on 1/7/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import Foundation
import Alamofire

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
       
     let url = NSURL(string: pokemonURL)!
        Alamofire.request(.GET, url).responseJSON { response in
            let result = response.result
            
            print("JSON get request result: \(result.value.debugDescription)")
            
            //WANT TO PARSE JSON HERE
            if let jsonDictionary = result.value as? [String:AnyObject] {
                
                if let weight = jsonDictionary["weight"] as? String {
                    
                    self.weight = weight
                }
                
                if let height = jsonDictionary["height"] as? String {
                    
                    self.height = height
                }
                
                if let attack = jsonDictionary["attack"] as? Int {
                    
                    self.attack = String(attack)
                }
                
                if let defense = jsonDictionary["defense"] as? Int {
                    
                    self.defense = String(defense)
                }
                
                print("Weight: \(self.weight)")
                print("Height: \(self.height)")
                print("Attack: \(self.attack)")
                print("Defense: \(self.defense)")
                
                if let types = jsonDictionary["types"] as? [[String:String]] where types.count > 0 {
                    
                    if let name = types[0]["name"] {
                        
                        self.type = name
                    }
                    
                    if types.count > 1 {
                        
                        for var i = 1; i < types.count; i++ {
                            if let name = types[i]["name"] {
                                self.type! += "/\(name)"
                            }
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
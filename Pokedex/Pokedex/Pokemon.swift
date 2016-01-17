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
    private var pokemonURL: String!
    
    private (set) var description: String = ""
    private (set) var type: String = ""
    private (set) var defense: String = ""
    private (set) var height: String = ""
    private (set) var weight: String = ""
    private (set) var attack: String = ""
    private (set) var nextEvolutionTxt: String = ""
    private (set) var nextEvolutionId: String = ""
    private (set) var nextEvolutionLvl: String = ""
    
    
    
    init(name: String, pokedexId: Int) {
        self.name = name
        self.pokedexId = pokedexId
        pokemonURL = "\(BASE_URL)\(POKEMON_URL)\(self.pokedexId)/"
        
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
                            self.type += "/\(name)"
                        }
                    }
                    
                }
            } else {
                self.type = ""
            }
            print("Type(s): \(self.type)")
            
            if let descArr = json["descriptions"].array where descArr.count > 0, let url = descArr[0]["resource_uri"].string, let nsurl = NSURL(string: "\(BASE_URL)\(url)")    {
                Alamofire.request(.GET, nsurl).responseJSON { response in
                    
                    let descDict = JSON(response.result.value!)
                    
                    if let description = descDict["description"].string {
                        
                        self.description = description
                        
                        print("Description: \(self.description)")
                    }
                    
                    completed()
                }
                
                
                
                
            } else {
                self.description = ""
            }
            
            if let evolutions = json["evolutions"].array where evolutions.count > 0 {
                
                if let to = evolutions[0]["to"].string {
                    
                    //omitting mega evolutions right now
                    if to.rangeOfString("mega") == nil {
                        
                        if let uri = evolutions[0]["resource_uri"].string {
                            let newString = uri.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                            let numberString = newString.stringByReplacingOccurrencesOfString("/", withString: "")
                            
                            self.nextEvolutionId = numberString
                            self.nextEvolutionTxt = to
                        
                        }
                        
                        if let level = evolutions[0]["level"].int {
                            self.nextEvolutionLvl = String(level)
                            
                        }
                        
                        
                    }
                    
                }
                
                
                print("EvoID: \(self.nextEvolutionId), EvoName: \(self.nextEvolutionTxt), EvoLevel: \(self.nextEvolutionLvl)")
                
            }
            
            
        }
    }
    
    
}
//
//  PokemonDetailVC.swift
//  Pokedex
//
//  Created by Ebony Nyenya on 1/10/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit

class PokemonDetailVC: UIViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var defenseLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var attackLbl: UILabel!
    @IBOutlet weak var pokedexLbl: UILabel!
    @IBOutlet weak var currentEvoImg: UIImageView!
    @IBOutlet weak var nextEvoImg: UIImageView!
    @IBOutlet weak var evoLbl: UILabel!
    
    var poke: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.text = poke.name.capitalizedString
        let img = UIImage(named: "\(poke.pokedexId)")
        mainImg.image = img
        currentEvoImg.image = img
        
        poke.downloadPokemonDetails { () -> () in
            
            //this code will be called after download is done
            self.updateUI()
            
        }
        
    }
    
    private func updateUI(){
        descriptionLbl.text = poke.description
        typeLbl.text = poke.type
        defenseLbl.text = poke.defense
        heightLbl.text = poke.height
        pokedexLbl.text = String(poke.pokedexId)
        weightLbl.text = poke.weight
        attackLbl.text = poke.attack
        
        if poke.nextEvolutionId == "" {
            evoLbl.text = "No Evolutions"
            nextEvoImg.hidden = true
        } else {
            evoLbl.text = "Next Evolution: \(poke.nextEvolutionTxt)"
            
            if poke.nextEvolutionLvl != "" {
                evoLbl.text? += " - LVL \(poke.nextEvolutionLvl)"
            }
            
            nextEvoImg.hidden = false
            nextEvoImg.image = UIImage(named: poke.nextEvolutionId)
        }
        
        
    }
    
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}

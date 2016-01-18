//
//  PokeCell.swift
//  Pokedex
//
//  Created by Ebony Nyenya on 1/7/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    private var pokemon: Pokemon!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5.0
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        
//        layer.cornerRadius = 5.0
//        
//    }
    
     func configureCell(pokemon: Pokemon) {
        self.pokemon = pokemon
        thumbImg.image = UIImage(named: "\(self.pokemon.pokedexId)")
        nameLbl.text = self.pokemon.name.capitalizedString
        
    }
    
    
}

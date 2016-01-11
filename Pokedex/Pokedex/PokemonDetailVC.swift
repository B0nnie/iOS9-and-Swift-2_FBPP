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
    var poke: Pokemon!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.text = poke.name

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  Pokedex
//
//  Created by Ebony Nyenya on 1/7/16.
//  Copyright © 2016 Ebony Nyenya. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var poke: Pokemon!
    var pokemonArray = [Pokemon]()
    var filteredArray = [Pokemon]()
    var musicPlayer: AVAudioPlayer!
    var inSearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = .Done
        searchBar.enablesReturnKeyAutomatically = false
        
        initAudio()
        parsePokemonCSV()
       
    }
    
    func initAudio(){
        
        let path = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!
        
        do {
           musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
        } catch let err as NSError {
            
            print("Error: \(err.debugDescription)")
        }
    }
    
    
    func parsePokemonCSV(){
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        
        do{
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name: name, pokedexId: pokeId)
                pokemonArray.append(poke)
            }
            
           
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
            
            if inSearchMode{
                poke = filteredArray[indexPath.row]
                
            } else {
                poke = pokemonArray[indexPath.row]
                
            }
            
            
            cell.configureCell(poke)
            
            return cell
        } else {
            
            return UICollectionViewCell()
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if inSearchMode{
            poke = filteredArray[indexPath.row]
        } else {
            poke = pokemonArray[indexPath.row]
        }
        
        performSegueWithIdentifier("PokemonDetailVC", sender: poke)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode{
            return filteredArray.count
        }
        
        return pokemonArray.count
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(105, 105)
    }

    @IBAction func musicBtnPressed(sender: UIButton) {
        
        if musicPlayer.playing {
            musicPlayer.stop()
            let soundOffImg = UIImage(named: "soundOff")
            sender.setImage(soundOffImg, forState: .Normal)
            
            
        } else {
            musicPlayer.play()
            let soundOnImg = UIImage(named: "soundOn")
            sender.setImage(soundOnImg, forState: .Normal)
            
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            collection.reloadData()
            
        } else {
            inSearchMode = true
           // let lower = searchText!.lowercaseString
            //filteredArray = pokemonArray.filter({$0.name.rangeOfString(lower) != nil})
            
            filteredArray = pokemonArray.filter {$0.name.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil }
            collection.reloadData()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailVC = segue.destinationViewController as? PokemonDetailVC, let poke = sender as? Pokemon {
                    detailVC.poke = poke
                }
            }
            
    }
    
   

}


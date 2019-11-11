//
//  ViewController.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 5/20/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//

import UIKit
import Kingfisher


class FavoritesManager {
    
    static let shared = FavoritesManager()

    
    var favorites: [Game] {
        get {
            if let favoriteStuff = UserDefaults.standard.data(forKey: "favorites") {
                if let favoritesData = try? JSONDecoder().decode([Game].self, from: favoriteStuff) {
                    let favoriteGames = favoritesData
                    return favoriteGames
                }
            }
            return []
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: "favorites")
            } catch {
                NSLog("Error saving favorites: \(error)")
            }
        }
    }
    
}


class FavoritesCollectionViewController: UICollectionViewController {
    let unfavoriteButton = UIButton(type: .system)

    
    override func viewWillAppear(_ animated: Bool) {
        collectionView!.reloadData()
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(editingFavorites))
        longPressGesture.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGesture)
        self.title = "Favorites"
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if FavoritesManager.shared.favorites.count == 0 {
            self.collectionView?.setEmptyMessage("To add favorites, tap on the heart button when checking out a game!")
        } else {
            self.collectionView?.restore()
        }
        return FavoritesManager.shared.favorites.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoritesCell", for: indexPath) as! FavoritesCollectionViewCell
        let url = URL(string: FavoritesManager.shared.favorites[indexPath.row].assets.coverMedium.uri)
        cell.favoriteGameCellImageView.kf.setImage(with: url)
        cell.closeButton.layer.setValue(indexPath.row, forKey: "index")
        cell.closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        cell.favoritesNameLabel.text = FavoritesManager.shared.favorites[indexPath.row].names.international
        
        //Configure cell shadow
        
        
        cell.favoriteGameCellImageView.layer.shadowColor = UIColor.black.cgColor
        cell.favoriteGameCellImageView.layer.shadowOpacity = 1
        cell.favoriteGameCellImageView.layer.shadowOffset = CGSize(width: 3, height: -3)
     
        return cell
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        unfavoriteButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        unfavoriteButton.imageView?.contentMode = .scaleAspectFit

        let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameView") as? GameViewController
        gameViewController?.game = FavoritesManager.shared.favorites[indexPath.row]
        gameViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.unfavoriteButton)
        self.navigationController?.pushViewController(gameViewController!, animated: true)
        
    }
    
    @objc func closeButtonPressed(sender: UIButton) {
        
        let index : Int = sender.layer.value(forKey: "index") as! Int
        print(index)
        FavoritesManager.shared.favorites.remove(at: index)
        collectionView?.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem) {
        isEditing = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem = nil
        if let cells = self.collectionView?.visibleCells {
            for cell in cells {
                if let cell = cell as? FavoritesCollectionViewCell {
                    UIView.animate(withDuration: 0.20, animations: {
                        cell.favoriteGameCellImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        cell.closeButton.alpha = 0
                    })
                }
            }
        }
    }
    
    @objc func editingFavorites(sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.isEditing = !isEditing
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
            self.navigationItem.rightBarButtonItem = done
            self.navigationItem.rightBarButtonItem?.isEnabled = true

            if let cells = self.collectionView?.visibleCells {
                switch isEditing {
                case true:
                    for cell in cells {
                        if let cell = cell as? FavoritesCollectionViewCell {
                            UIView.animate(withDuration: 0.20, animations: {
                                cell.favoriteGameCellImageView.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
                                cell.closeButton.alpha = 1.0
                            })
                        }
                    }
                case false:
                    for cell in cells {
                        if let cell = cell as? FavoritesCollectionViewCell {
                            UIView.animate(withDuration: 0.20, animations: {
                                cell.favoriteGameCellImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                cell.closeButton.alpha = 0
                            })
                        }

                        
                    }
                }
            }

        }
        
        
    }
    
    
    

    
    
}


extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}


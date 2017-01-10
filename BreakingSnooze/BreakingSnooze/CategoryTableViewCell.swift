//
//  CategoryTableViewCell.swift
//  BreakingSnooze
//
//  Created by Cris on 1/10/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
fileprivate let collectionViewReusableID = "SourceCollectionViewIdentifier"

class CategoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sourceCollectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sourceCollectionView.delegate = self
        sourceCollectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReusableID, for: indexPath)
        
        return cell
    }
}

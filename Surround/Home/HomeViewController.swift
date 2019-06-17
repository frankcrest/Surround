//
//  ViewController.swift
//  Surround
//
//  Created by Frank Chen on 2019-04-17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import CoreLocation

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        postCollectionView.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = self.postCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            flowLayout.itemSize = CGSize(width: self.postCollectionView.bounds.width, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = self.view.frame.width
        height += 25
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        let post = posts[indexPath.item]
        cell.backgroundColor = .white
        let colour = post.colour
        cell.layer.borderColor = UIColor(hexFromString: colour).cgColor
        cell.layer.borderWidth = 3
        
        let imageUrl = post.imageUrl
        if let url = URL(string: imageUrl){
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                cell.postImage.image = image
            }
        }
        
        let postDate = post.creationDate
        let elapsedInterval = Date().timeIntervalSince(postDate)
        let durationInSeconds = Int(elapsedInterval)
        let timeElapsed = calculateHoursAndDays(seconds: durationInSeconds)
        cell.dateLabel.text = timeElapsed
        
        let postLocation = CLLocation(latitude: post.lat, longitude: post.long)
        cell.distanceLabel.text = calculateDistanceFrom(location1: postLocation)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    var posts = [Post]()
    
    fileprivate func fetchPosts(){
        posts = [Post]()
        let postRef = Firestore.firestore().collection("posts")
        postRef.getDocuments { (snapshot, err) in
            if let err = err{
                print("Error getting documents", err)
                return
            }
            for document in snapshot!.documents{
                let latitude = document.get("latitude") as! Double
                let longitude = document.get("longitude") as! Double
                let uid = document.get("id") as! String
                let timeStamp = document.get("date") as! Double
                let date = Date(timeIntervalSince1970: timeStamp)
                let imageUrl = document.get("imageUrl") as! String
                let colour = document.get("colour") as! String
                let dictionary = ["latitude":latitude, "longitude":longitude, "uid":uid, "creationDate":date, "imageUrl":imageUrl, "colour":colour] as [String : Any]
                let post = Post(dictionary: dictionary)
                self.posts.append(post)
            }
            self.postCollectionView.reloadData()
        }
    }
    
    fileprivate func calculateHoursAndDays(seconds:Int) -> String{
        switch seconds {
        case 0...3600:
            return "1 HOUR AGO"
        case 3600...86400:
            return "\(seconds/3600) HOURS AGO"
        case 3600...172800:
            return "1 DAY AGO"
        default:
            return "\(seconds/86400) DAYS AGO"
        }
    }
    
    fileprivate func calculateDistanceFrom(location1: CLLocation) -> String{
        let myAppDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentLocation = myAppDelegate.currentLocation
        
        let distanceInMeters = location1.distance(from: currentLocation ?? CLLocation(latitude: 0, longitude: 0))
        
        switch distanceInMeters {
        case 0...100:
            return "100M AWAY"
        case 100...200:
            return "200M AWAY"
        case 200...300:
            return "300M AWAY"
        case 300...400:
            return "400M AWAY"
        case 400...500:
            return "500M AWAY"
        case 500...600:
            return "600M AWAY"
        case 600...700:
            return "700M AWAY"
        case 700...800:
            return "800M AWAY"
        case 800...900:
            return "900M AWAY"
        case 900...1000:
            return "1KM AWAY"
        default:
            let distance = Int(distanceInMeters/1000)
            return "\(distance)KM AWAY"
        }

    }
    
}

//
//  TopStoriesWebViewController.swift
//  BreakingSnooze
//
//  Created by Kadell on 1/11/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import WebKit

class TopStoriesWebViewController: UIViewController, WKUIDelegate {

    var article: SourceArticles!
   
    var webView: WKWebView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        setupWebView()
        

        let myURL = URL(string: article.articleURL)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
//
//    func initializeFetchedResultsController() {
//        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Favorite.title), ascending: false)]
//        controller = NSFetchedResultsController(fetchRequest: request,
//                                                managedObjectContext: mainContext,
//                                                sectionNameKeyPath: nil,
//                                                cacheName: nil)
//        controller.delegate = self
//        
//        do {
//            try controller.performFetch()
//            // self.tableView.reloadData()
//        } catch {
//            fatalError("Failed to initialize FetchedResultsController: \(error)")
//        }
//    }
//    
//    func isThisInCoreData(article: SourceArticles) -> Favorite? {
//        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
//        let predicate: NSPredicate = NSPredicate(format: "title = %@", article.title)
//        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Favorite.title), ascending: false)]
//        request.predicate = predicate
//        let isItInThereController = NSFetchedResultsController(fetchRequest: request,
//                                                               managedObjectContext: mainContext,
//                                                               sectionNameKeyPath: nil,
//                                                               cacheName: nil)
//        do {
//            try isItInThereController.performFetch()
//        } catch {
//            print(error)
//        }
//        
//        guard let resultsArr = isItInThereController.fetchedObjects,
//            resultsArr.count > 0,
//            let result = resultsArr.first else { return nil }
//        
//        return result
//    }
//    
//    lazy var webViewContainterView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    lazy var backButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("👈", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
//        button.clipsToBounds = true
//        button.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
//        return button
//    }()
//    
//    lazy var favouriteButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("🖤", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
//        button.addTarget(self, action: #selector(favouritesButtonPresses(sender:)), for: .touchUpInside)
//        return button
//    }()
//    
//    lazy var shareButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Share on Slack", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightHeavy)
//        return button
//    }()
//    
//    lazy var saveButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Save Offline", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightHeavy)
//        return button
//    }()
//    
//    lazy var titleLabel: UILabel = {
//        let font: UIFont = UIFont.boldSystemFont(ofSize: 16.0)
//        let label: UILabel = UILabel()
//        label.font = font
//        label.text = "Detail"
//        label.sizeToFit()
//        return label
//    }()
//

    
    private func setupWebView() {
        self.edgesForExtendedLayout = []
        let webConfiguration = WKWebViewConfiguration()

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        if let containerView = view.viewWithTag(1) {
            containerView.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            webView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            webView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        }

    }
    
    
    //MARK: -Actions
//    
//    func backButtonPressed (sender: UIButton) {
//        webView.goBack()
//    }
//    
//    func favouritesButtonPresses (sender: UIButton) {
//        if let favourite = isThisInCoreData(article: currentArticle) {
//            mainContext.delete(favourite)
//            sender.setTitle("🖤", for: .normal)
//            print("deletedFromCoreData")
//        } else {
//            let favorite = Favorite(context: mainContext)
//            favorite.populate(article: currentArticle)
//            do {
//                try mainContext.save()
//                print("working")
//                sender.setTitle("❤️", for: .normal)
//                
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
}

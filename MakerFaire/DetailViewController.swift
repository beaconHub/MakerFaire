//
//  DetailViewController.swift
//  MakerFaire
//
//  Created by Harry Ng on 12/10/14.
//  Copyright (c) 2014 request. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                let object = detail as CLBeacon
                label.text =  "\(object.proximityUUID.UUIDString)\nmajor: \(object.major)\nminor: \(object.minor)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


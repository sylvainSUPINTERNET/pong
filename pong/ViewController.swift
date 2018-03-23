//
//  ViewController.swift
//  pong
//
//  Created by SUP'Internet 15 on 16/03/2018.
//  Copyright © 2018 SUP'Internet 08. All rights reserved.
//

import Foundation
import UIKit


class ViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
       let controller = segue.destination as! GameViewController
        controller.level = segue.identifier!
    }
    
}

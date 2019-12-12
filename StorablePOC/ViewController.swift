//
//  ViewController.swift
//  StorablePOC
//
//  Created by Jp LaFond on 12/6/19.
//  Copyright © 2019 Jp LaFond. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let key = "ios.jp.key"
    let value = "saved"

    var userDefaults: Storable = UserDefaults()
    var keychain: Storable = StorableKeychain()

    @IBOutlet weak var keychainLabel: UILabel!
    @IBOutlet weak var userDefaultsLabel: UILabel!

    @IBOutlet weak var saveKeychain: UIButton! {
        didSet {
            saveKeychain.tag = 1
        }
    }
    @IBOutlet weak var saveUserDefaults: UIButton! {
        didSet {
            saveUserDefaults.tag = 2
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender.tag == saveKeychain.tag {
            keychain.safeSet(key: key, value: value)
        } else if sender.tag == saveUserDefaults.tag {
            userDefaults.safeSet(key: key, value: value)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        keychainLabel.text = retrieve(key, in: keychain)

        userDefaultsLabel.text = retrieve(key, in: userDefaults)

        if StorableManager.shared.safeGet(key: StorableManager.Key.firstRun) ?? false {
            print("First Run")
        } else {
            print("Already had first run")
        }
    }

    func retrieve(_ key: String, in storable: Storable) -> String {
        guard let result: String = storable.safeGet(key: key) else {
            return "Nothing set"
        }
        return result
    }
}


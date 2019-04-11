//
//  ViewController.swift
//  APICrawler
//
//  Created by Apple User on 4/10/19.
//  Copyright © 2019 Apple User. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var baseURL: String? = "https://pokeapi.co/api/v2/"
    var initialDictionary = [String: Any]() {
        didSet {
            self.useDictionary = true
        }
    }
    var initialArray = [Any]() {
        didSet {
            self.useDictionary = false
        }
    }
    var useDictionary = false
    var dictionaryKeys: [String] {
        return initialDictionary.keys.sorted()
    }

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        guard let unwrappedUrlString = baseURL, let unwrappedUrl = URL(string: unwrappedUrlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: unwrappedUrl) { (data, _, _) in
            guard let data = data, let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
            if let jsonArray = jsonObject as? [Any] {
                self.initialArray = jsonArray
            } else if let jsonDictionary = jsonObject as? [String: Any] {
                self.initialDictionary = jsonDictionary
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard useDictionary else{ return initialArray.count}
        return initialDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if useDictionary {
            let key = dictionaryKeys[indexPath.row]
            cell.textLabel?.text = key
            let value = initialDictionary[key]
            let stringToShow: String
            if let stringValue = value as? String {
                stringToShow = stringValue
            } else if let intValue = value as? Int {
                stringToShow = String(intValue)
            } else if value is NSNull {
                stringToShow = "404: no value"
            } else if let arrayValue = value as? [Any] {
                stringToShow = "Elements in the array: \(arrayValue.count)"
            } else if let dictionaryValue = value as? [String: Any] {
                stringToShow = "Elements in the dictionary: \(dictionaryValue.count)"
            } else if let boolValue = value as? Bool {
                stringToShow = String(boolValue)
            } else {
                stringToShow = "STOP SENDING INVALID JSON"
            }
            cell.detailTextLabel?.text = stringToShow
        } else {
            if let stringValue = initialArray[indexPath.row] as? String {
                cell.textLabel?.text = stringValue
            } else {
                cell.textLabel?.text = "Array element at index \(indexPath)"
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if useDictionary {
            if let tappedUrl = initialDictionary[dictionaryKeys[indexPath.row]] as? String {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                if tappedUrl.contains("https://") {
                    vc.baseURL = tappedUrl
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    return
                }
            } else if let tappedArray = initialDictionary[dictionaryKeys[indexPath.row]] as? [Any] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.baseURL = nil
                vc.initialArray = tappedArray
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let tappedDictionary = initialDictionary[dictionaryKeys[indexPath.row]] as? [String: Any] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.baseURL = nil
                vc.initialDictionary = tappedDictionary
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let value = initialArray[indexPath.row]
            if let stringValue = value as? String {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.baseURL = stringValue
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let arrayValue = value as? [Any] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.baseURL = nil
                vc.initialArray = arrayValue
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let dictionaryValue = value as? [String: Any] {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.baseURL = nil
                vc.initialDictionary = dictionaryValue
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

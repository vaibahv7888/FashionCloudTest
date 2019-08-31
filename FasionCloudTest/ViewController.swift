//
//  ViewController.swift
//  FasionCloudTest
//
//  Created by Vaibhav Bangde on 8/31/19.
//  Copyright © 2019 Vaibhav Bangde. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pricat = readDataFromFile(file: "pricat") {            
            self.textView.text = filterColumns(csv: pricat)
        }
    }


    func readDataFromFile(file:String)-> String? {
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv") else { return nil }
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String {
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch {
                print("error")
                //Access error here
            }
        }
        return ""
    }
    
    func filterColumns(csv:String) -> String {
        let csvArray = getCSV(data: csv)
        guard csvArray.isEmpty == false else { return "Error" }
     
        var categoryArray : [String : Any] = [:]
        var categoryColumns : [String] = []
        
        guard let categoryFields = getCategoryFeilds(csvStringArray: csvArray) else { return "Error" }
        
        categoryArray = categoryFields.0
        categoryColumns = categoryFields.1
        
        categoryArray.updateValue(getArticals(csvStringArray: csvArray, categoryColumns: categoryColumns), forKey: "articles")
        
        let json = JSONStringify(value: categoryArray as AnyObject, prettyPrinted: true)
        
        return json
        
    }
    
    func getCategoryFeilds(csvStringArray:[[String]]?) -> ([String : Any], [String])? {
        guard let csv = csvStringArray else { return nil }
        
        var categoryArray : [String : Any] = [:]
        var categoryColumns : [String] = []
        
        for column in 0..<csv[0].count {
            let value = csv[1][column]
            var isNoChange = true
            for row in 1..<csv.count {
                if value != csv[row][column] {
                    isNoChange = false
                }
            }
            if isNoChange {
                categoryColumns.append(csv[0][column])
                categoryArray.updateValue(value, forKey: csv[0][column])
            }
        }
        return (categoryArray, categoryColumns)
    }
    
    func getArticals(csvStringArray:[[String]]?, categoryColumns:[String]) -> [Any] {
        guard let csv = csvStringArray else { return [] }
        
        var varients = [[String : Any]]()
        var article : [String : Any] = [:]
        var articles : [Any] = []
        var articleKeys = [String]()
        var dictTemp = [String : Any]()
        
        for row in 1..<csv.count {
            for column in 0..<csv[row].count {
                let columnName = csv[0][column]
                if !categoryColumns.contains(columnName) {
                    article.updateValue(csv[row][column], forKey: columnName)
                }
                if (columnName == "article_number") {
                    articleKeys.append(csv[row][column])
                }
            }
            articles.append(article)
            varients.append(article)
        }
        let uniqueSourceKeyArray = Set.init(articleKeys)
        print(uniqueSourceKeyArray)
        for obj in uniqueSourceKeyArray {
            let dict = (varients).filter({$0["article_number"] as! String == obj })
            dictTemp.updateValue(dict, forKey: ("article_number: " + obj))
        }
        
        return [dictTemp as Any]
    }
    
    func getCSV(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\r\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        return result
    }
}


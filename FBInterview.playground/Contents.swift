////: Playground - noun: a place where people can play
//
import UIKit
//
//var str = "Hello, playground"
//
////Given two NSRanges determine if they intersect or not.
//
//func rangesIntersect(a: NSRange, b: NSRange) -> Bool {
//
//
//    let aMin = a.location
//    let aMax = a.location + length
//
//    let bMin = b.location
//    let bMax = b.location + length
//
//    if a.max >= bmin && a.max <= bMax {
//
//        return true
//    }
//
//    if a.min >= bmin && a.min <= bMax {
//
//        return true
//    }
//
//    return false
//}
//// (10, 1) (11, 2)
//// Test cases: a < b, a > b, a max intersects lower bound, a min intersects b upperbound, a == b
//
//assert(rangesIntersect(a: NSRange.init(location: 1, length: 10), b: NSRange.init(location: 2, length: 9))
//
//////////////////////////////
//
//
//
//class SearchViewController: UIViewController {
//    var resultTable: UITableView
//    var resultContents: [SearchResult]
//    ...
//
//    private func textFieldDidChange(textField: UITextField) {
//
//        // resultContents = serverConnection.autocompleteForSearchText(searchField.text)
//        let timer = Timer(duration: 0.5, selector(timerMethod), repeating: false)
//
//        timer.start
//
//    }
//
//    func timerMethod() {
//        resultsForSearch( text: searchField.text, completionHandler: {
//
//            DispatchQueue.main {
//                resultTable.reloadData()
//            }
//        }
//
//
//        func resultsForSearch( text: String, completionHandler: @escaping ()->Void) {
//
//            DispatchQueue.async {
//                resultContents = serverConnection.autocompleteForSearchText(searchField.text)
//
//                completionHandler()
//            }
//
//
//        }
//
//
//
//}

let now = Date()
let formatter = ISO8601DateFormatter.init()
formatter.formatOptions = [.withFullDate]
let iso = formatter.string(from: now)
print(iso)


//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ExamplesViewController: UIViewController {
    
    enum Example {
        case longScrollView
        case longNestedScrollView
        case longTableView
        case viewSizeScrollView
    }
    
    // MARK: - Properties
    
    private let examples: [Example] = [.longScrollView, .longNestedScrollView, .viewSizeScrollView]
    
    // MARK: - Outlets
    
    @IBOutlet weak private var examplesTableView: UITableView!
    
    // MARK: - Life Cycle
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "Choose Example"
        
        //examplesTableView
        examplesTableView.register(UINib(nibName: ExampleCell.nibName, bundle: nil), forCellReuseIdentifier: ExampleCell.reuseIdentifier)
        examplesTableView.rowHeight = 80
        examplesTableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ExamplesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let example: Example = examples[indexPath.row]
        
        switch example {
            
        case .longScrollView:
            performSegue(withIdentifier: "showLongScrollView", sender: nil)
        
        case .longNestedScrollView:
            performSegue(withIdentifier: "showLongNestedScrollView", sender: nil)
        
        case .longTableView:
            performSegue(withIdentifier: "showLongTableView", sender: nil)
            
        case .viewSizeScrollView:
            performSegue(withIdentifier: "showViewSizeScrollView", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ExampleCell = examplesTableView.dequeueReusableCell(withIdentifier: ExampleCell.reuseIdentifier, for: indexPath) as! ExampleCell
        let example: Example = examples[indexPath.row]
        let isLastRow: Bool = indexPath.row == examples.count - 1
        
        cell.selectionStyle = .none
        cell.title = ""
        
        switch example {
            
        case .longScrollView:
            cell.title = "Long ScrollView"
            
        case .longNestedScrollView:
            cell.title = "Long Nested ScrollView"
            
        case .longTableView:
            cell.title = "Long TableView"
            
        case .viewSizeScrollView:
            cell.title = "View Size ScrollView"
        }
        
        cell.separatorLineIsHidden = isLastRow
        
        return cell
    }
}

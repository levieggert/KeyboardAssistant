//
//  Created by Levi Eggert.
//  Copyright © 2019 Levi Eggert. All rights reserved.
//

import UIKit

class ExamplesViewController: UIViewController
{
    enum Example
    {
        case longScrollView
        case longNestedScrollView
        case longTableView
        case viewSizeScrollView
    }
    
    // MARK: - Properties
    
    private let examples: [Example] = [.longScrollView, .longNestedScrollView, .viewSizeScrollView]
    
    // MARK: - Outlets
    
    @IBOutlet weak var examplesTableView: UITableView!
    
    // MARK: - Life Cycle
    
    deinit
    {
        print("deinit: \(type(of: self))")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Choose Example"
        
        //examplesTableView
        self.examplesTableView.register(UINib(nibName: ExampleCell.nibName, bundle: nil), forCellReuseIdentifier: ExampleCell.reuseIdentifier)
        self.examplesTableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ExamplesViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.examples.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let example: Example = self.examples[indexPath.row]
        
        switch (example)
        {
        case .longScrollView:
            self.performSegue(withIdentifier: "showLongScrollView", sender: nil)
        
        case .longNestedScrollView:
            self.performSegue(withIdentifier: "showLongNestedScrollView", sender: nil)
        
        case .longTableView:
            self.performSegue(withIdentifier: "showLongTableView", sender: nil)
            
        case .viewSizeScrollView:
            self.performSegue(withIdentifier: "showViewSizeScrollView", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: ExampleCell = self.examplesTableView.dequeueReusableCell(withIdentifier: ExampleCell.reuseIdentifier, for: indexPath) as! ExampleCell
        let example: Example = self.examples[indexPath.row]
        let isLastRow: Bool = indexPath.row == self.examples.count - 1
        
        cell.selectionStyle = .none
        cell.lbTitle.text = ""
        
        switch (example)
        {
        case .longScrollView:
            cell.lbTitle.text = "Long ScrollView"
            
        case .longNestedScrollView:
            cell.lbTitle.text = "Long Nested ScrollView"
            
        case .longTableView:
            cell.lbTitle.text = "Long TableView"
            
        case .viewSizeScrollView:
            cell.lbTitle.text = "View Size ScrollView"
        }
        
        if (!isLastRow)
        {
            cell.separatorLine.isHidden = false
        }
        else
        {
            cell.separatorLine.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
}

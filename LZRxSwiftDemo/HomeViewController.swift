//
//  ViewController.swift
//  LZRxSwiftDemo
//
//  Created by lizhi on 2021/9/9.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class HomeViewController: UIViewController {
    var items = Observable.just(  ["RxSwift tableView刷新","Driver用法demo","c"] )
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: view.bounds)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "荔枝的RxSwiftDemo"
        setupTable()
    }
    
    func setupTable()  {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element)"
                cell.accessoryType = .disclosureIndicator
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { indexpath in
            print("- row =" + String( indexpath.row))
            switch indexpath.row {
            case 0:
                let vc = ReloadTableViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let driverStoryBoard = UIStoryboard.init(name: "Driver", bundle: nil)
                let vc = driverStoryBoard.instantiateViewController(identifier: "DriverViewController")
                self.navigationController?.pushViewController(vc, animated: true)
            default :
                break
            }
        }).disposed(by: rx.disposeBag)
    }
    
}


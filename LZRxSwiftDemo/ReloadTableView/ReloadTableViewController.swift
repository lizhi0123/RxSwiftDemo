//
//  ReloadTableViewController.swift
//  LZRxSwiftDemo
//
//  Created by lizhi on 2021/9/9.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class ReloadTableViewController: UIViewController {
    lazy var tableView: UITableView = {
        let table = UITableView(frame: view.bounds)
        return table
    }()
    
    /// SectionModel<Sting,String>中string都可以修改为你自己定义的model类或者结构体
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { _, tableview, indexPath, item in
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = "当前显示的cell" + item
        return cell
    })
    
    /* RxSwift中的subject，subject是observable和Observer之间的桥梁，一个subject既是一个obserable也是一个observe，它既可以发出事件也可以监听事件
     1.publicSubject:订阅publicSubject时，只能接收到订阅他之后发生的事件，subject.onNext()发出onNext事件，对应的还有onError()和onComplete()事件
     2.replaySubject:订阅replaySubject时，可以接收到订阅他之后的事件，但也可以接受订阅他之前发出的事件，接受几个事件取决于bufferSize的大小
     3.BehaviorSubject:订阅behaviorSubject,可以接收到订阅之前的最后一个事件，这个在tableView中用的比较多，一般就是初始化数据显示空值
     */
    /// 定义一个BehaviorSubject类型的数据源
    var dataListArr = BehaviorSubject(value: [SectionModel<String, String>]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Rx 刷新tableView"
        setupTable()
        setupNavBar()
    }
    
    func setupTable() {
        dataSource.configureCell = { _, tableview, indexPath, model in
            let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = "当前显示的cell" + model
            return cell
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // 绑定数据
        dataListArr.asObserver().bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        // 初始化显示数组
        let myOrignal = SectionModel(model: "first", items: ["张歆艺", "张美琪", "张雅芝", "李佳琪"])
        dataListArr.onNext([myOrignal])
        
        tableView.rx.itemSelected.subscribe(onNext: { indexpath in
            print("- row =" + String(indexpath.row))
            switch indexpath.row {
            case 0:
                let vc = ReloadTableViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
    }

    func setupNavBar() {
        let customerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        let refreshBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let loadMoreBtn = UIButton(frame: CGRect(x: 50, y: 0, width: 50, height: 50))
        customerView.addSubview(refreshBtn)
        customerView.addSubview(loadMoreBtn)
        
        refreshBtn.setTitle("刷新", for: .normal)
        refreshBtn.setTitleColor(.black, for: .normal)
        refreshBtn.addTarget(self, action: #selector(Self.refreshClick), for: .touchUpInside)
        
        loadMoreBtn.setTitle("更多", for: .normal)
        loadMoreBtn.setTitleColor(.black, for: .normal)
        loadMoreBtn.addTarget(self, action: #selector(Self.loadMoreClick), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customerView)
    }

    @objc func refreshClick() {
        // 初始化显示数组
        let myOrignal = SectionModel(model: "first", items: ["郭佳佳", "李梅梅", "赵德刚", "王雅琪"])
        dataListArr.onNext([myOrignal])
    }
    
    @objc func loadMoreClick() {
        // 取出模型数据
        var tempArr = try! dataListArr.value()
        // 模型数据添加新数据
        tempArr[0].items.append(contentsOf: ["郭佳佳", "李梅梅", "赵德刚", "王雅琪"])
        dataListArr.onNext(tempArr)
    }
}

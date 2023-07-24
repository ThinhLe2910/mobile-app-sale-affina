//
//  NewsTableView.swift
//  affina
//
//  Created by Intelin MacHD on 28/07/2022.
//

import UIKit
import SnapKit

protocol NewsTableViewDelegate {
    func handleOnPressNewsItem(id: String)
    
    func likeNewsItem(id: String, isLiked: Bool)
    func commentNewsItem(id: String)
    
}

class NewsBaseTableView: BaseTableView<NewsItemTableViewCell, NewsItemTableViewModel> {
    
    var likeCallBack: ((Int) -> Void)?
    var commentCallBack: ((Int) -> Void)?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? NewsItemTableViewCell else {
            return UITableViewCell()
        }
        cell.item = items[indexPath.row]
        
        cell.likeCallBack = {
            self.likeCallBack?(indexPath.row)
        }
        
        cell.commentCallBack = {
            self.commentCallBack?(indexPath.row)
        }
        
        return cell
    }
    
}

class NewsTableView: UIView {

    private var delegate: NewsTableViewDelegate?
    private lazy var tableView: NewsBaseTableView = {
        let table = NewsBaseTableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.registerCell(nibName: NewsItemTableViewCell.nib)
        table.setRowHeight(cellHeight + cellPadding)
        table.setBackgroundColor(.clear)
        table.disableBounces()
        return table
    }()
    private var viewHeightConstraint: Constraint!
    private let cellHeight: CGFloat = 144.0 + 40.0 + 56.0
    private let cellPadding: CGFloat = 16
    
    var data: [NewsItemTableViewModel]? {
        didSet {
            guard let data = data else {
                tableView.items = [NewsItemTableViewModel]()
                tableView.reloadData()
                return
            }
            viewHeightConstraint.update(offset: (cellHeight + cellPadding) * CGFloat(data.count))
            tableView.items = data
            tableView.reloadData()
        }
    }
    
    
    func setDelegate(_ viewController: NewsTableViewDelegate) {
        self.delegate = viewController
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        backgroundColor = .clear
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            viewHeightConstraint = make.height.equalTo(100).constraint
        }
        
        tableView.setDidSelectRowHandler { item, indexPath in
            self.delegate?.handleOnPressNewsItem(id: item.id ?? "")
        }
        
        tableView.likeCallBack = { index in
            guard let data = self.data else { return }
            self.delegate?.likeNewsItem(id: data[index].id ?? "", isLiked: data[index].isLiked != 0)
        }
        
        tableView.commentCallBack = { index in
            guard let data = self.data else { return }
//            self.delegate?.commentNewsItem(id: data[index].id ?? "")
            self.delegate?.handleOnPressNewsItem(id: data[index].id ?? "")
        }
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
}

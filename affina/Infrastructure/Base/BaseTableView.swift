//
//  BaseTableView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit
import Network

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

class BaseTableViewCell<U>: PaddingTableViewCell {
    var item: U?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayout()
    }
    
    func initLayout() {}
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class BaseTableView<T: BaseTableViewCell<U>, U>: UIView, UITableViewDelegate, UITableViewDataSource {
    var items = [U]()
    
    private lazy var tableView = UITableView()
    private lazy var refreshControl = UIRefreshControl()
    
    private var canDelete: Bool = false
    
    private var didSelectRowHandler: ((_ item: U, _ indexPath: IndexPath) -> Void)?
    private var deleteRowHandler: ((_ item: U, _ indexPath: IndexPath) -> Void)?
    
    private var rowHeight: CGFloat = 50.0
    
    var isScrollEnabled: Bool = true {
        didSet {
            tableView.isScrollEnabled = isScrollEnabled
        }
    }
    
    var showsVerticalScrollIndicator: Bool = true {
        didSet {
            tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initBaseTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initBaseTable() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // tableView.addSubview(refreshControl)
        
        tableView.backgroundColor = UIColor.appColor(.blackMain)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func registerCell(nibName: String? = nil) {
        guard let nibName = nibName else {
            tableView.register(T.self, forCellReuseIdentifier: "Cell")
            return
        }
        tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setDidSelectRowHandler(_ handler: @escaping ((_ item: U, _ indexPath: IndexPath) -> Void)) {
        self.didSelectRowHandler = handler
    }
    
    func setRowHeight(_ rowHeight: CGFloat) {
        self.rowHeight = rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? T else {
            return UITableViewCell()
        }
        cell.item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectRowHandler?(items[indexPath.row], indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canDelete
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteRowHandler?(items[indexPath.row], indexPath)
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        tableView.backgroundColor = color
    }
    
    func disableBounces() {
        tableView.bounces = false
    }
}

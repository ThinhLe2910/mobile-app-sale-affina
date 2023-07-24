//
//  CardBlackListView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 27/07/2022.
//

import UIKit

class CardBlackListView: UIView {
    
    static let nib = "CardBlackListView"
    class func instanceFromNib() -> CardBlackListView {
        return UINib(nibName: CardBlackListView.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardBlackListView
    }
    
    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var searchTextField: TextFieldAnimBase!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    var items: [HospitalModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isLoadingMore: Bool = false
    var endReached: Bool = false
    
    var navigateCallBack: ((BaseViewController) -> ())?
    var searchCallBack: ((String) -> ())?
    
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(CardBlackListView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        
        containerView.addTapGestureRecognizer {
            self.endEditing(true)
        }
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        
        let view = BaseView(frame: .init(x: 0, y: 0, width: 50, height: 50))
        let imageView = UIImageView(frame: .init(x: 13, y: 13, width: 24, height: 24))
        imageView.image = UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .appColor(.black)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        searchTextField.rightViewMode = .always
        searchTextField.rightView = view
        searchTextField.layer.masksToBounds = true
        
        tableView.register(UINib(nibName: CardBlackListTableViewCell.nib, bundle: nil), forCellReuseIdentifier: CardBlackListTableViewCell.cellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        
//        textField.rightView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 0))
//        textField.rightViewMode = .always
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @objc private func searchHospital() {
        searchCallBack?(searchTextField.text ?? "")
    }
}

// MARK: UITextFieldDelegate
extension CardBlackListView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            timer?.invalidate()
            searchCallBack?(text)
        }
        return true
    }
    
    @objc private func textFieldDidChanged() {
        guard let _ = searchTextField.text else { return }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchHospital), userInfo: nil, repeats: false)
    }
}

extension CardBlackListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardBlackListTableViewCell.cellId, for: indexPath) as? CardBlackListTableViewCell else { return UITableViewCell() }
        cell.item = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let vc = CardHospitalDetailViewController()
//        vc.item = items[indexPath.row]
//        navigateCallBack?(vc)
    }
    
}

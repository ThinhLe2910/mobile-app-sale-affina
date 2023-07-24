//
//  NewsDetailViewController.swift
//  affina
//
//  Created by Intelin MacHD on 28/07/2022.
//

import UIKit
import WebKit
class NewsDetailViewController: BaseViewController {
    static let nib = "NewsDetailViewController"
    var id: String = ""

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: HyperlinkLabel!
    @IBOutlet weak var backButton: UIImageView!
    
    @IBOutlet weak var commentsTableView: ContentSizedTableView!
    @IBOutlet weak var emptyLabel: BaseLabel!
    
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeLabel: BaseLabel!
    
    @IBOutlet weak var likeCountLabel: BaseLabel!
    @IBOutlet weak var commentCountLabel: BaseLabel!
    
    @IBOutlet weak var likeView: BaseView!
    @IBOutlet weak var commentView: BaseView!
    
    @IBOutlet weak var bottomView: BaseView!
    @IBOutlet weak var commentTextField: TextFieldAnimBase!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    private let currentDate = "\(Date().timeIntervalSince1970)".timestampToFormatedDate(format: "dd/MM/yyyy")
    
    private var isShowingError: Bool = false
    var comments: [CommentModel] = [] {
        didSet {
            if comments.isEmpty {
//                emptyLabel.show()
                commentsTableView.hide()
            }
            else {
                emptyLabel.hide()
                commentsTableView.show()
            }
        }
    }
    
    private var data: NewsDetailModel? {
        didSet {
            guard let data = data else {
                titleLabel.text = nil
                timeLabel.text = nil
                contentLabel.text = nil
                imageView.image = UIImage()
                comments = []
                commentsTableView.reloadData()
                return
            }
            if let url = URL(string: API.STATIC_RESOURCE + data.getNewsImage2()) {
                CacheManager.shared.imageFor(url: url) { image, error in
                    guard let image = image else {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
            titleLabel.text = data.getNewsName()
            timeLabel.text = Date(timeIntervalSince1970: Double(data.getCreatedAt()) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY")
    
            contentLabel.attributedText = data.getNewsContent().htmlToAttributedString?.attributedStringWithResizedImages(with: UIConstants.Layout.screenWidth - 23.width * 2)
            
            comments = data.getListComments()
            commentsTableView.reloadData()
            
            commentCountLabel.text = "\(data.getNumberComments()) \("COMMENT".localize())"
            likeCountLabel.text = "\(data.getNumberLikes()) \("NUMBER_LIKES".localize() + (data.getNumberLikes() > 1 ? "s" : ""))"
            
            if data.getIsLiked() == IsLiked.YES.rawValue {
                likeImageView.image = UIImage(named: "ic_heart_big")
                likeLabel.textColor = .appColor(.pinkMain)
            }
            else {
                likeImageView.image = UIImage(named: "ic_heart_gray")
                likeLabel.textColor = .appColor(.subText)
            }
            
        }
    }
    
    var likeCallBack: ((Bool) -> Void)?
    var commentCallBack: (([CommentModel]) -> Void)?

    private lazy var newsPresenter: NewsPresenter = {
        let presenter = NewsPresenter()
        presenter.setDetailDelegate(self)
        return presenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addBlurStatusBar()
        // Do any additional setup after loading the view.
        fetchNewsDetailFromServer()
        
        contentLabel.didTapOnURL = { url in
            print("Did tap on: \(url)")
//            if let url = url {
                UIApplication.shared.open(url)
//            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
        
        if UIConstants.isLoggedIn, !CacheManager.shared.isExistCacheWithKey(Key.profile.rawValue), let token = UserDefaults.standard.string(forKey: Key.token.rawValue), !token.isEmpty {
            let presenter = HomeViewPresenter()
            presenter.getProfile { _ in
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (tabBarController as? BaseTabBarViewController)?.showTabBar()
    }
    
    func setupView() {
        hideHeaderBase()
        containerBaseView.hide()
        
        addBlurEffect(bottomView)
        
        let searchView = UIView(frame: .init(x: 0, y: 0, width: 40, height: 48))
        let searchIcon = UIImageView(image: UIImage(named: "ic_send"))
        searchView.addSubview(searchIcon)
        searchIcon.frame = .init(x: 0, y: 12, width: 24, height: 24)
        commentTextField.rightViewMode = .always
        commentTextField.rightView = searchView
        
        searchView.addTapGestureRecognizer {
            self.didTapSendComment()
        }
        
        commentTextField.delegate = self
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        emptyLabel.hide(isImmediate: true)
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(UINib(nibName: CommentTableViewCell.nib, bundle: nil), forCellReuseIdentifier: CommentTableViewCell.cellId)
        
        likeView.addTapGestureRecognizer {
            if !UIConstants.isLoggedIn {
                self.commentTextField.resignFirstResponder()
                self.queueBasePopup(icon: UIImage(named: "ic_lock"), title: "YOU_ARE_NOT_LOGGED_IN".localize(), desc: "TO_USE_FEATURE_NEED_TO_LOG_IN".localize(), okTitle: "LOG_IN".localize(), cancelTitle: "LATER".localize()) {
                    self.hideBasePopup()
                    let vc = UINavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
                    self.presentInFullScreen(vc, animated: true, completion: nil)
                } handler: {
                    
                }
                return
            }
            
            guard let data = self.data else { return }
            self.newsPresenter.likeNews(newsId: data.getNewsId(), isLiked: data.getIsLiked() == IsLiked.YES.rawValue)
        }
        
        commentView.addTapGestureRecognizer {
            self.commentTextField.becomeFirstResponder()
        }
    }

    override func initViews() {
        backButton.layer.cornerRadius = 20
        backButton.layer.masksToBounds = false
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        backButton.layer.shadowRadius = 6
        backButton.layer.shadowOpacity = 0.5
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackButtonPressed)))
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        bottomViewConstraint.constant = 0
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomViewConstraint.constant = keyboardSize.height - 24
            let yOffset = (commentsTableView?.convert(commentsTableView?.bounds.origin ?? .zero, to: contentView).y ?? 0)
            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height), animated: true)
        }
    }
    
    @objc func onBackButtonPressed() {
        popViewController()
    }
    
    func didTapSendComment() {
        if !UIConstants.isLoggedIn {
            self.commentTextField.resignFirstResponder()
            self.queueBasePopup(icon: UIImage(named: "ic_lock"), title: "YOU_ARE_NOT_LOGGED_IN".localize(), desc: "TO_USE_FEATURE_NEED_TO_LOG_IN".localize(), okTitle: "LOG_IN".localize(), cancelTitle: "LATER".localize()) {
                self.hideBasePopup()
                let vc = UINavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
                self.presentInFullScreen(vc, animated: true, completion: nil)
            } handler: {
                
            }
            return
        }
        
        guard let comment = commentTextField.text?.trim(), !comment.isEmpty, let data = data else { return }
        commentTextField.resignFirstResponder()
    
        newsPresenter.createComment(newsId: data.getNewsId(), comment: comment)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case commentTextField:
                
                break
            default: break
        }
    }
}

// MARK: NewsPresenterDetailDelegate
extension NewsDetailViewController: NewsPresenterDetailDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func showAlert() {
        
    }
    
    func showError(error: ApiError) {
        if isShowingError { return }
        isShowingError = true
        commentTextField.text = ""
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", okHandler: {
            self.hideBasePopup()
            self.isShowingError = false
        }, handler: {})
    }
    
    func fetchNewsDetailFromServer() {
        newsPresenter.fetchNewsDetail(of: id)
    }
    
    func handleGetDetailSuccess(_ detail: NewsDetailModel) {
        data = detail
    }
    
    func likeNewsSuccess(newsId: String) {
        guard let data = data else { return }
        if data.getIsLiked() == IsLiked.YES.rawValue {
            data.setIsLiked(IsLiked.NO.rawValue)
            data.setNumberLikes(data.getNumberLikes() - 1)
            likeImageView.image = UIImage(named: "ic_heart_gray")
            likeLabel.textColor = .appColor(.subText)
        }
        else {
            data.setIsLiked(IsLiked.YES.rawValue)
            data.setNumberLikes(data.getNumberLikes() + 1)
            likeImageView.image = UIImage(named: "ic_heart_big")
            likeLabel.textColor = .appColor(.pinkMain)
        }
        likeCountLabel.text = "\(data.getNumberLikes()) \("NUMBER_LIKES".localize() + (data.getNumberLikes() > 1 ? "s" : ""))"
        
        
        likeCallBack?(data.getIsLiked() == IsLiked.YES.rawValue)
    }
    
    func sendCommentSuccess() {
        guard let comment = commentTextField.text?.trim(), !comment.isEmpty, let data = data else { return }
        commentTextField.text = ""
        ParseCache.parseCacheToItem(key: Key.profile.rawValue, modelType: ProfileModel.self) { result in
            switch result {
                case .success(let profile):
                    let model = CommentModel(id: "", userID: profile.userID, newsID: data.getNewsId(), content: comment, createdAt: Int(Date().timeIntervalSince1970 * 1000), createdBy: "", modifiedAt: Int(Date().timeIntervalSince1970 * 1000), modifiedBy: "", name: profile.name, avatar: profile.avatar ?? "")
                    
                    self.comments.insert(model, at: 0)
                    self.commentCountLabel.text = "\(self.comments.count) \("COMMENT".localize())"
                    self.commentCallBack?(self.comments)
                    DispatchQueue.main.async {
                        self.commentsTableView.reloadData()
                    }
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
            }
        }
    }
}

// MARK: UITableViewDelegate
extension NewsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.cellId, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        let comment = comments[indexPath.row]
        
        let distance = Int(Date().timeIntervalSince1970) * 1000 - comment.createdAt
        let minutes = Int(distance/1000/60)
        let hours = Int(floor((minutes / 60) > 0 ? Double((minutes / 60)) : 0))
        let days = Int(floor((hours / 24) > 0 ? Double((hours / 24)) : 0))
        
        if distance <= 60000 {
            cell.dateLabel.text = "JUST_NOW".localize()
        }
        else if distance > 60000 && distance < 86400 * 1000 {
            cell.dateLabel.text = "\(hours > 0 ? "\(hours) " + "HOURS_AGO".localize() : "\(minutes) " + "MINUTES_AGO".localize())"
        }
        else if distance < 86400 * 1000 * 7 {
            cell.dateLabel.text = "\(days > 0 ? ("\(days) " + "DAYS_AGO".localize()) : "")"
        }
        else {
            cell.dateLabel.text = "\(comment.createdAt/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
        }
        
        cell.usernameLabel.text = comment.name
        cell.commentLabel.text = comment.content
        if comment.avatar == nil || comment.avatar == "" {
            cell.defaultImageView.show()
            cell.avatarImageView.hide(isImmediate: true)
            return cell
        }
        guard let url = URL(string: API.STATIC_RESOURCE + (comment.avatar ?? "")) else {
            cell.defaultImageView.show()
            cell.avatarImageView.hide(isImmediate: true)
            return cell
        }
        CacheManager.shared.imageFor(url: url) { image, error in
            if error != nil {
                cell.defaultImageView.show()
                cell.avatarImageView.hide(isImmediate: true)
                return
            }
            
            DispatchQueue.main.async {
                cell.avatarImageView.image = image
                cell.avatarImageView.show()
                cell.defaultImageView.hide(isImmediate: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
}

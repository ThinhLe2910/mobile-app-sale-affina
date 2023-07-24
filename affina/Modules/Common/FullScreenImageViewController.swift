//
//  FullScreenImageViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 23/06/2022.
//

import UIKit
import SnapKit

class FullScreenImageViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return imageView
    }()


    private lazy var imageViewLandscapeConstraint: NSLayoutConstraint = {
        if #available(iOS 11.0, *) {
            return pokemonImageView.heightAnchor.constraint(equalTo: wrapperView.safeAreaLayoutGuide.heightAnchor)
        } else {
            return pokemonImageView.heightAnchor.constraint(equalTo: wrapperView.heightAnchor)
        }
    }()
    
    private lazy var imageViewPortraitConstraint: NSLayoutConstraint = {
        if #available(iOS 11.0, *) {
            return pokemonImageView.widthAnchor.constraint(equalTo: wrapperView.safeAreaLayoutGuide.widthAnchor)
        } else {
            return pokemonImageView.widthAnchor.constraint(equalTo: wrapperView.widthAnchor)
        }
    }()

    init(image: UIImage, tag: Int) {
        super.init(nibName: nil, bundle: nil)
        pokemonImageView.tag = tag
        pokemonImageView.image = image // UIImage(contentsOfFile: pokemonImage.imagePath)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Force any ongoing scrolling to stop and prevent the image view jumping during dismiss animation.
        // Which is caused by the scroll animation and dismiss animation running at the same time.
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }

    private func configureUI() {
        view.backgroundColor = .clear

        view.addSubview(scrollView)

        scrollView.addSubview(wrapperView)
        wrapperView.addSubview(pokemonImageView)

        scrollView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
//        wrapperView.anchor(top: scrollView.contentLayoutGuide.topAnchor, leading: scrollView.contentLayoutGuide.leadingAnchor, bottom: scrollView.contentLayoutGuide.bottomAnchor, trailing: scrollView.contentLayoutGuide.trailingAnchor)
//        wrapperView.setWidthEqual(to: scrollView)
//        wrapperView.setHeightEqual(to: scrollView)
        wrapperView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.leading.bottom.trailing.equalTo(scrollView.contentLayoutGuide)
            } else {
                // Fallback on earlier versions
                make.top.leading.bottom.trailing.equalTo(scrollView)
            }
            make.width.height.equalTo(scrollView)
        }

        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = pokemonImageView.intrinsicContentSize.height / pokemonImageView.intrinsicContentSize.width
        pokemonImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        pokemonImageView.heightAnchor.constraint(equalTo: pokemonImageView.widthAnchor, multiplier: aspectRatio).isActive = true
    }

    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        // scrollView.maximumZoomScale = 1.0001 // "Hack" to enable bouncy zoom without zooming
        scrollView.maximumZoomScale = 2.0

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }

    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }

    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate
extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        pokemonImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        pokemonImageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                          y: currentContentSize.height * 0.5 + offsetY)
    }
}
final class FullScreenTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    private let anchorViewTag: Int
    private weak var anchorView: UIView?

    init(anchorViewTag: Int) {
        self.anchorViewTag = anchorViewTag
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        anchorView = (presenting ?? source).view.viewWithTag(anchorViewTag)
        return FullScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FullScreenAnimationController(animationType: .present, anchorView: anchorView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FullScreenAnimationController(animationType: .dismiss, anchorView: anchorView)
    }
}

final class FullScreenPresentationController: UIPresentationController {
    private lazy var closeButtonContainer: UIVisualEffectView = {
        let closeButtonBlurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))

        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_close"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .primaryActionTriggered)

        closeButtonBlurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(button)

        button.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        vibrancyEffectView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }

        closeButtonBlurEffectView.layer.cornerRadius = 24
        closeButtonBlurEffectView.clipsToBounds = true
        closeButtonBlurEffectView.frame.size = CGSize(width: 48, height: 48)
        return closeButtonBlurEffectView
    }()

    private lazy var backgroundView: UIVisualEffectView = {
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.effect = nil
        return blurVisualEffectView
    }()

    private let blurEffect: UIBlurEffect = {
        if #available(iOS 13.0, *) {
            return UIBlurEffect(style: .systemThinMaterial)
        } else {
            // Fallback on earlier versions
            return UIBlurEffect(style: .prominent)
        }
    }()

    @objc private func close(_ button: UIButton) {
        presentedViewController.dismiss(animated: true)
    }
}

// MARK: UIPresentationController
extension FullScreenPresentationController {
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        containerView.addSubview(backgroundView)
        containerView.addSubview(closeButtonContainer)
        backgroundView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        closeButtonContainer.snp.makeConstraints { make in
            make.top.equalTo(containerView.safeArea.top).inset(UIPadding.size16)
            make.trailing.equalTo(containerView.safeArea.trailing).inset(UIPadding.size16)
        }

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }

        closeButtonContainer.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        transitionCoordinator.animate(alongsideTransition: { context in
            self.backgroundView.effect = self.blurEffect
            self.closeButtonContainer.transform = .identity
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView.removeFromSuperview()
            closeButtonContainer.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }

        transitionCoordinator.animate(alongsideTransition: { context in
            self.backgroundView.effect = nil
            self.closeButtonContainer.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
            closeButtonContainer.removeFromSuperview()
        }
    }
}

final class FullScreenAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate enum AnimationType {
        case present
        case dismiss
    }

    private let animationType: AnimationType
    private let animationDuration: TimeInterval
    private weak var anchorView: UIView?

    private let anchorViewCenter: CGPoint
    private let anchorViewSize: CGSize
    private let anchorViewTag: Int

    private var propertyAnimator: UIViewPropertyAnimator?

    fileprivate init(animationType: AnimationType, animationDuration: TimeInterval = 0.3, anchorView: UIView?) {
        self.animationType = animationType
        self.anchorView = anchorView
        self.animationDuration = animationDuration

        if let anchorView = anchorView {
            anchorViewCenter = anchorView.superview?.convert(anchorView.center, to: nil) ?? .zero
            anchorViewSize = anchorView.bounds.size
            anchorViewTag = anchorView.tag
        } else {
            anchorViewCenter = .zero
            anchorViewSize = .zero
            anchorViewTag = 0
        }
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animationType {
        case .present:
            guard
                let toViewController = transitionContext.viewController(forKey: .to)
                else {
                return transitionContext.completeTransition(false)
            }
            transitionContext.containerView.insertSubview(toViewController.view, at: 1) // In between the presentations controller's background and close button
            toViewController.view.snp.makeConstraints { make in
                make.top.leading.trailing.bottom.equalToSuperview()
            }
            toViewController.view.layoutIfNeeded()
            propertyAnimator = presentAnimator(with: transitionContext, animating: toViewController)
        case .dismiss:
            guard
                let fromViewController = transitionContext.viewController(forKey: .from)
                else {
                return transitionContext.completeTransition(false)
            }
            propertyAnimator = dismissAnimator(with: transitionContext, animating: fromViewController)
        }
    }

    private func presentAnimator(with transitionContext: UIViewControllerContextTransitioning,
                                 animating viewController: UIViewController) -> UIViewPropertyAnimator {
        let view: UIView = viewController.view.viewWithTag(anchorViewTag) ?? viewController.view
        let finalSize = view.bounds.size
        let finalCenter = view.center
        view.transform = CGAffineTransform(scaleX: anchorViewSize.width / finalSize.width,
                                           y: anchorViewSize.height / finalSize.height)
        view.center = view.superview!.convert(anchorViewCenter, from: nil)
        anchorView?.isHidden = true
        return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseInOut], animations: {
            view.transform = .identity
            view.center = finalCenter
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    private func dismissAnimator(with transitionContext: UIViewControllerContextTransitioning,
                                 animating viewController: UIViewController) -> UIViewPropertyAnimator {
        let view: UIView = viewController.view.viewWithTag(anchorViewTag) ?? viewController.view
        let initialSize = view.bounds.size
        let finalCenter = view.superview!.convert(anchorViewCenter, from: nil)
        let finalTransform = CGAffineTransform(scaleX: self.anchorViewSize.width / initialSize.width,
                                               y: self.anchorViewSize.height / initialSize.height)
        return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseInOut], animations: {
            view.transform = finalTransform
            view.center = finalCenter
        }, completion: { _ in
            self.anchorView?.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


//
//  NavigationBarManager.swift
//  Pods
//
//  Created by Sarun Wongpatcharapakorn on 12/1/16.
//
//

import Foundation

public class NavigationBarManager {
    public var scrollView: UIScrollView
    public var navigationController: UINavigationController
    public var viewController: UIViewController
    
    private var extensionViewTopConstraint: NSLayoutConstraint?
    public var extensionView: UIView? {
        didSet {
            if let extensionView = extensionView {
                extensionView.translatesAutoresizingMaskIntoConstraints = false
                
                let view: UIView = viewController.view
                view.addSubview(extensionView)
                
                extensionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                extensionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                extensionViewTopConstraint = extensionView.topAnchor.constraint(equalTo: viewController.topLayoutGuide.bottomAnchor)
                extensionViewTopConstraint?.isActive = true
                extensionView.heightAnchor.constraint(equalToConstant: extensionView.bounds.size.height).isActive = true
                
                var insets = scrollView.contentInset
                if let oldValue = oldValue {
                    insets.top -= oldValue.bounds.size.height
                }
                
                insets.top += extensionView.bounds.size.height
                
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
            } else {
                oldValue?.removeFromSuperview()
                
                var insets = scrollView.contentInset
                if let oldValue = oldValue {
                    insets.top -= oldValue.bounds.size.height
                }
                
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
            }
        }
    }
    
    private func updateInsets() {
        
    }
    
    public init?(viewController: UIViewController, scrollView: UIScrollView) {
        guard let navigationController = viewController.navigationController else {
            return nil
        }
    
        self.viewController = viewController
        self.navigationController = navigationController
        self.scrollView = scrollView
        
        viewController.extendedLayoutIncludesOpaqueBars = true
    }
    
    
    /// This method will add snap behavior
    ///
    /// - Parameter scrollView:
    public func handleScrollViewDidEnd(scrollView: UIScrollView) {
        guard shouldHandleHiding() else {
            return
        }
        
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        let height = navigationController.navigationBar.bounds.size.height + statusBarHeight()
        print("xxx \(height)")
        let threshold = height
        
        // Move only when extension view is go behind nav
        let extensionViewHeight = (extensionView?.bounds.size.height ?? 0)
        let navOffset = max(0, yOffset - extensionViewHeight)
        
        let sumHeight = extensionViewHeight + height
        
        if yOffset < extensionViewHeight {
            // go back to original
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { 
                scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
                self.handleScrolling(scrollView: scrollView)
            }, completion: { (finished) in
                
            })
            
            print("go back")
        } else if yOffset < sumHeight {
            
            print("go go")
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top + sumHeight)
                self.handleScrolling(scrollView: scrollView)
            }, completion: { (finished) in
                
            })
            
        } else {
            // Hiding already, no need to do anything
        }
    }
    
    public func handleScrollViewDidScroll(scrollView: UIScrollView) {
        handleScrolling(scrollView: scrollView)
    }
    
    
    /// This method will add fade and hiding behavior of nav and extension view
    ///
    /// - Parameter scrollView: <#scrollView description#>
    private func handleScrolling(scrollView: UIScrollView) {
        guard shouldHandleHiding() else {
            return
        }
        
        
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        print("offset \(yOffset)")
        
        if let extensionView = extensionView {
            var offset: CGFloat = 0
            // Got extension move extension first
            if yOffset > 0 {
                // scroll up
                offset = yOffset
            }
            
            extensionView.transform = CGAffineTransform.init(translationX: 0, y: -offset)
        }
        
        let height = navigationController.navigationBar.bounds.size.height + statusBarHeight()
        print("xxx \(height)")
        let threshold = height
        
        var alpha: CGFloat = 1
        var yTransition: CGFloat = 0
        
        // Move only when extension view is go behind nav
        let extensionViewHeight = (extensionView?.bounds.size.height ?? 0)
        let navOffset = max(0, yOffset - extensionViewHeight)
        if yOffset > extensionViewHeight {
            alpha = max(0, (threshold - navOffset))/threshold + CGFloat(FLT_EPSILON)
            
            yTransition = min(navigationController.navigationBar.bounds.size.height, navOffset)
            print("transition \(yTransition)")
        }
        
        
        navigationController.navigationBar.transform = CGAffineTransform.init(translationX: 0, y: -yTransition)
        navigationController.navigationBar.sw_setContenAlpha(alpha)
    }
    
    /// If `content size` - `viewable size` > `top view` enable hiding, otherwise content is too small to hide.
    ///
    /// - Top view is `nav + status + extension view`
    /// - Viewable size is `scroll view frame size - (Top view)` or `scroll view frame size - scroll view content inset top + bottom`
    private func shouldHandleHiding() -> Bool {
        let viewableHeight = scrollView.bounds.size.height - (scrollView.contentInset.top + scrollView.contentInset.bottom)
        let contentSizeHeight = scrollView.contentSize.height
        
        let extensionViewHeight = (extensionView?.bounds.size.height ?? 0)
        let topViewHeight = statusBarHeight() + navigationController.navigationBar.bounds.size.height + extensionViewHeight
        
        return contentSizeHeight - viewableHeight > topViewHeight
    }
}

extension UINavigationBar {
    func sw_setContenAlpha(_ alpha: CGFloat) {
        for view in subviews {
            let isBackgroundView = (view == subviews[0])
            let isViewHidden = (view.isHidden || view.alpha < CGFloat(FLT_EPSILON))
            
            if isBackgroundView == false && isViewHidden == false {
                view.alpha = alpha
            }
        }
    }
}

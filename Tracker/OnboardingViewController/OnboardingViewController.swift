//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Алия Давлетова on 01.09.2023.
//

import Foundation

import UIKit

final class OnboardingViewController: UIPageViewController {
    private let defaults = UserDefaults.standard
    
    lazy var pages: [UIViewController] = {
        guard let backgroundImage1 = UIImage(named: "background1") else {
            assertionFailure("Onboarding: failed t get background image")
            return [UIViewController]()
        }
        let title1 = NSLocalizedString("onboarding.page1", comment: "текст на первой онбординг странице")
        let bluePage = PageViewController(title: title1, backgroundImage: backgroundImage1)
        
        guard let backgroundImage2 = UIImage(named: "background2") else {
            assertionFailure("Onboarding: failed t get background image")
            return [UIViewController]()
        }
        let title2 =  NSLocalizedString("onboarding.page2", comment: "текст на второй онбординг странице")
        let redPage = PageViewController(title: title2, backgroundImage: backgroundImage2)
        
        return [bluePage, redPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor.getAppColors(.blackDay)
        pageControl.pageIndicatorTintColor = UIColor.getAppColors(.blackDay).withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupPageControl()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        defaults.set(true, forKey: isOnbordingShown)
    }
    
    func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34 - buttonHeight),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

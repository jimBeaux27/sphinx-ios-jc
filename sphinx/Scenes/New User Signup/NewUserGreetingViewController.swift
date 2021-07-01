//
//  NewUserGreetingViewController.swift
//  sphinx
//
//  Created by Brian Sipple on 6/23/21.
//  Copyright © 2021 sphinx. All rights reserved.
//

import UIKit

class NewUserGreetingViewController: UIViewController {
    @IBOutlet weak var lightningNetworkImage: UIImageView!
    @IBOutlet weak var screenHeadlineLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var continueButtonContainer: UIView!
    @IBOutlet weak var pulsingCircleView: UIView!
    
    private var rootViewController: RootViewController!

    
    static func instantiate(
        rootViewController: RootViewController
    ) -> NewUserGreetingViewController {
        let viewController = StoryboardScene.NewUserSignup.newUserGreetingViewController.instantiate()
        
        viewController.rootViewController = rootViewController
        
        return viewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        screenHeadlineLabel.text = "signup.greeting.headline".localized

        setupContinueButton()
        setupPulsingCircle()
    }
    
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let setNickNameVC = SetNickNameViewController.instantiate(
            rootViewController: rootViewController
        )
        
        self.navigationController?.pushViewController(setNickNameVC, animated: true)
    }
}


extension NewUserGreetingViewController {
 
    private func setupContinueButton() {
        continueButton.layer.cornerRadius = continueButton.frame.size.height / 2
        continueButton.clipsToBounds = true
        continueButton.addShadow(location: .bottom, opacity: 0.12, radius: 2.0)
        continueButton.setTitle(
            "signup.greeting.continue".localized,
            for: .normal
        )
    }
    
    private func setupPulsingCircle() {
        pulsingCircleView.layer.cornerRadius = pulsingCircleView.frame.size.height / 2
        
        pulsingCircleView.alpha = 1.0
        pulsingCircleView.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
        
        UIView.animate(
            withDuration: 1.6,
            delay: 0.0,
            options: [.repeat, .curveEaseOut],
            animations: { [unowned self] in
                self.pulsingCircleView.alpha = 0.0
                self.pulsingCircleView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            },
            completion: { bool in
            
            }
        )
    }
}


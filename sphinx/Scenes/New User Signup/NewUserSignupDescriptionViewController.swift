//
//  NewUserSignupDescriptionViewController.swift
//  sphinx
//
//  Created by Brian Sipple on 6/22/21.
//  Copyright © 2021 sphinx. All rights reserved.
//

import UIKit

class NewUserSignupDescriptionViewController: UIViewController {

    @IBOutlet weak var imageSubtitle: UILabel!
    @IBOutlet weak var continueButtonContainer: UIView!
    @IBOutlet weak var continueButton: UIButton!

    private var rootViewController: RootViewController!

    
    static func instantiate(
        rootViewController: RootViewController
    ) -> NewUserSignupDescriptionViewController {
        let viewController = StoryboardScene.NewUserSignup.newUserSignupDescriptionViewController.instantiate()
        
        viewController.rootViewController = rootViewController
        
        return viewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContinueButton()
        setAttributedTextSubtitle()
    }
    
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let newUserSignupFormVC = NewUserSignupFormViewController.instantiate(
            rootViewController: rootViewController
        )
        
        self.navigationController?.pushViewController(newUserSignupFormVC, animated: true)
    }
}


extension NewUserSignupDescriptionViewController {
 
    private func setupContinueButton() {
        continueButton.layer.cornerRadius = continueButton.frame.size.height / 2
        continueButton.clipsToBounds = true
        continueButton.addShadow(location: .bottom, opacity: 0.12, radius: 2.0)
        continueButton.setTitle(
            "signup.description.continue".localized,
            for: .normal
        )
    }
    
    
    private func setAttributedTextSubtitle() {
        let labelText = "signup.description.label".localized
        let boldLabels = [
            "signup.description.paste".localized,
            "signup.description.connection-code".localized,
        ]
        
        let normalFont = UIFont(name: "Roboto-Light", size: 15.0)!
        let boldFont = UIFont(name: "Roboto-Bold", size: 15.0)!
        
        
        imageSubtitle.attributedText =  String.getAttributedText(
            string: labelText,
            boldStrings: boldLabels,
            font: normalFont,
            boldFont: boldFont
        )
    }
}

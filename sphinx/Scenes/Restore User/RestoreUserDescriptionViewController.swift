//
//  RestoreUserDescriptionViewController.swift
//  sphinx
//
//  Created by Brian Sipple on 6/17/21.
//  Copyright © 2021 sphinx. All rights reserved.
//

import UIKit

class RestoreUserDescriptionViewController: UIViewController {
    @IBOutlet weak var imageSubtitle: UILabel!
    @IBOutlet weak var continueButtonContainer: UIView!
    @IBOutlet weak var continueButton: UIButton!

    private var rootViewController: RootViewController!

    
    static func instantiate(
        rootViewController: RootViewController
    ) -> RestoreUserDescriptionViewController {
        let viewController = StoryboardScene.RestoreUser.restoreUserDescriptionViewController.instantiate()
        
        viewController.rootViewController = rootViewController
        
        return viewController
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonContinueButton()
        setAttributedTextSubtitle()
    }
    
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let restoreExistingFormVC = RestoreUserFormViewController.instantiate(
            rootViewController: rootViewController
        )
        
        self.navigationController?.pushViewController(restoreExistingFormVC, animated: true)
    }
}


extension RestoreUserDescriptionViewController {
 
    private func setupButtonContinueButton() {
        continueButton.layer.cornerRadius = continueButton.frame.size.height / 2
        continueButton.clipsToBounds = true
        continueButton.addShadow(location: .bottom, opacity: 0.12, radius: 2.0)
        continueButton.setTitle(
            "restore.description.continue".localized,
            for: .normal
        )
    }
    
    
    private func setAttributedTextSubtitle() {
        let labelText = "restore.description.label".localized
        let boldLabels = ["restore.copy.keys".localized]
        
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

//
//  WalletBalanceService.swift
//  sphinx
//
//  Created by Tomas Timinskas on 04/10/2019.
//  Copyright © 2019 Sphinx. All rights reserved.
//

import Foundation
import UIKit

public final class WalletBalanceService {
    
    var balance: Int {
        get {
            return UserDefaults.Keys.channelBalance.get() ?? 0 as Int
        }
        set {
            UserDefaults.Keys.channelBalance.set(newValue)
        }
    }
    
    var remoteBalance: Int {
        get {
            return UserDefaults.Keys.remoteBalance.get() ?? 0 as Int
        }
        set {
            UserDefaults.Keys.remoteBalance.set(newValue)
        }
    }
    
    init() {
        
    }
    
    func getBalance(completion: @escaping (Int) -> ()) -> Int {
        API.sharedInstance.getWalletBalance(callback: { updatedBalance in
            self.balance = updatedBalance
            completion(updatedBalance)
        }, errorCallback: {
            completion(self.balance)
        })
        return balance
    }
    
    func getBalanceAll(completion: @escaping (Int, Int) -> ()) -> (Int, Int) {
        API.sharedInstance.getWalletLocalAndRemote(callback: { local, remote in
            self.balance = local
            self.remoteBalance = remote
            completion(local, remote)
        }, errorCallback: {
            completion(self.balance, self.remoteBalance)
        })
        return (balance, remoteBalance)
    }
    
    func updateBalance(labels: [UILabel]) {
        let storedBalance = getBalance() { updatedBalance in
            self.updateLabels(labels: labels, balance: updatedBalance.formattedWithSeparator)
        }
        updateLabels(labels: labels, balance: storedBalance.formattedWithSeparator)
    }
    
    func updateLabels(labels: [UILabel], balance: String) {
        for label in labels {
            label.text = balance
        }
    }
}

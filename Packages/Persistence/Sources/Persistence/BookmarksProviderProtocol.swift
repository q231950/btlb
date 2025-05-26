//
//  BookmarksProviderProtocol.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 17/01/2017.
//  Copyright © 2017 neoneon. All rights reserved.
//

import Foundation

public protocol BookmarksProvider {
    func removeFavourite(forLoan loan: Persistence.Loan) async
    func addFavourite(forLoan loan: Persistence.Loan)
}

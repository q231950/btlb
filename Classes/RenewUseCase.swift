//
//  RenewUseCase.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 04.10.24.
//  Copyright © 2024 neoneon. All rights reserved.
//
import Foundation
import Paper
import LibraryCore

public struct RenewUseCase: RenewingUseCase {

    public init() {}

    public func renew(item: String, renewalToken: String?, for account: String?, password: String?, in library: LibraryModel?) async throws -> (dueDateString: String, renewalCount: Int, canRenew: Bool) {
        guard let library, let apiConfiguration = ApiConfiguration(library: library) else {
            throw PaperErrorInternal.LibraryNotSupportedError
        }

        let configuration = Paper.Configuration(
            username: account,
            password: password,
            apiConfiguration: apiConfiguration
        )
        let renewalService = Paper.RenewalService()

        do {
            let loan = try await renewalService.renew(itemNumber: item, renewalToken: renewalToken, configuration: configuration)

            return (loan.dateDue, Int(loan.renewalsCount), loan.canRenew)
        } catch(let error as PaperErrorInternal) {
            throw error
        } catch {
            // if timeout, maybe notify user about library servers possibly being down
            throw PaperErrorInternal.unhandledError(error.localizedDescription)
        }

    }
}

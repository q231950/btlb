//
//  DeviceAppAttest.swift
//  Bookmarks
//

@preconcurrency import DeviceCheck
import Foundation

/// App Attest on this device: a P-256 key in the Secure Enclave, which Apple certifies belongs to
/// a genuine BTLB install. neoneon only serves recommendations to requests signed by such a key.
///
/// Keys are created in Apple's sandbox for Xcode-signed builds (the
/// `com.apple.developer.devicecheck.appattest-environment` entitlement is `development`) and in
/// production for TestFlight and App Store builds, which ignore the entitlement. neoneon accepts
/// sandbox keys only while `APP_ATTEST_ALLOW_DEVELOPMENT=true`.
struct DeviceAppAttest: AppAttestProviding {
    /// `false` on the Simulator and some Macs; the recommender is hidden there.
    var isSupported: Bool {
        DCAppAttestService.shared.isSupported
    }

    func generateKey() async throws -> String {
        try await DCAppAttestService.shared.generateKey()
    }

    func attestKey(_ keyID: String, clientDataHash: Data) async throws -> Data {
        try await DCAppAttestService.shared.attestKey(keyID, clientDataHash: clientDataHash)
    }

    func generateAssertion(_ keyID: String, clientDataHash: Data) async throws -> Data {
        try await DCAppAttestService.shared.generateAssertion(keyID, clientDataHash: clientDataHash)
    }

    func classify(_ error: any Error) -> AppAttestFailure {
        guard let error = error as? DCError else { return .other }
        switch error.code {
        case .invalidKey: return .invalidKey
        case .serverUnavailable: return .serviceUnavailable
        default: return .other
        }
    }
}

/// Keeps the attested key's identifier in `UserDefaults`.
///
/// Not the Keychain on purpose: the identifier isn't secret (it is a hash of the public key; the
/// private key never leaves the Secure Enclave), and `UserDefaults` goes away with the app, just
/// as App Attest keys do on reinstall. A Keychain entry would outlive the key it names.
struct UserDefaultsAppAttestKeyStore: AppAttestKeyStoring {
    static let defaultsKey = "btlb.recommender.appAttestKeyID"

    func load() -> String? {
        UserDefaults.standard.string(forKey: Self.defaultsKey)
    }

    func save(_ keyID: String) {
        UserDefaults.standard.set(keyID, forKey: Self.defaultsKey)
    }

    func delete() {
        UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
    }
}

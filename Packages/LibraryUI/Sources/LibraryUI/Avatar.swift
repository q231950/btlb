//
//  Avatar.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 16.02.25.
//

import Foundation

public struct Avatar {
    public let imageName: String

    public init(imageName: String?) {
        self.imageName = imageName ?? "avatar-cat"
    }
}

public extension Avatar {
    static let cat: Avatar = Avatar(imageName: "avatar-cat")
//    static let chick: Avatar = Avatar(imageName: "avatar-chick")
    static let duck: Avatar = Avatar(imageName: "avatar-duck")
    static let fox: Avatar = Avatar(imageName: "avatar-fox")
    static let horse: Avatar = Avatar(imageName: "avatar-horse")
    static let lion: Avatar = Avatar(imageName: "avatar-lion")
    static let mouse: Avatar = Avatar(imageName: "avatar-mouse")
    static let panda: Avatar = Avatar(imageName: "avatar-panda")
    static let poodle: Avatar = Avatar(imageName: "avatar-poodle")
    static let rabbit: Avatar = Avatar(imageName: "avatar-rabbit")
    static let tiger: Avatar = Avatar(imageName: "avatar-tiger")
    static let turtle: Avatar = Avatar(imageName: "avatar-turtle")
    static let wolf: Avatar = Avatar(imageName: "avatar-wolf")
}

//
//  AvatarView.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 13.02.25.
//

import Foundation
import SwiftUI

public enum AvatarSize {
    case small
    case standard
    case large

    var width: CGFloat {
        switch self {
        case .small: 50
        case .standard: 120
        case .large: 250
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .small: 2
        case .standard: 4
        case .large: 10
        }
    }
}

public struct AvatarView: View {
    let editAction: (() -> Void)?
    var avatar: Avatar
    private let selected: Bool
    private let size: AvatarSize

    public init(_ avatarName: String?, size: AvatarSize = .standard, selected: Bool = false, editAction: (() -> Void)? = nil) {
        self.avatar = Avatar(imageName: avatarName)
        self.selected = selected
        self.size = size
        self.editAction = editAction
    }

    init(_ avatar: Avatar?, size: AvatarSize = .standard, selected: Bool = false, editAction: (() -> Void)? = nil) {
        self.avatar = avatar ?? Avatar(imageName: nil)
        self.selected = selected
        self.size = size
        self.editAction = editAction
    }

    public var body: some View {
        Image(avatar.imageName, bundle: .module)
            .resizable()
            .frame(width: size.width, height: size.width)
            .clipShape(Circle())
            .if(editAction != nil) { v in
                v.overlay {
                    Button {
                        editAction?()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .offset(CGSizeMake(0, -2))
                    }
                    .foregroundStyle(.primary)
                    .padding(5)
                    .background(.thinMaterial, in: .circle)
                    .frame(width: 40, height: 40)
                    .offset(CGSize(width: size.width * 0.375, height: size.width * 0.375))
                    .buttonStyle(.borderless)
                }
            }
            .if(selected) { v in
                    v.background {
                        Circle()
                            .stroke(.primary.opacity(0.8), lineWidth: size.lineWidth)
                    }
                    .background {
                        Circle()
                            .stroke(.ultraThickMaterial, lineWidth: size.lineWidth*2)
                    }
            }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ScrollView {
        AvatarView("avatar-cat", size: .large) {}

        AvatarView("avatar-cat", size: .large, selected: true)

        AvatarView("avatar-cat", selected: true)

        AvatarView("avatar-cat") {}

        AvatarView(.init(imageName: "avatar-horse"))

        AvatarView("avatar-cat", size: .small)
    }
}

//
//  DescriptiveToggle.swift
//  
//
//  Created by Martin Kim Dung-Pham on 09.05.23.
//

import SwiftUI

public struct DescriptiveToggle: View, Identifiable {

    public var id = UUID()

    private let title: LocalizedStringKey
    private let description: LocalizedStringKey
    private let bundle: Bundle?
    private var isOn: Binding<Bool>

    public init(title: LocalizedStringKey, description: LocalizedStringKey, bundle: Bundle?, isOn: Binding<Bool>) {
        self.title = title
        self.description = description
        self.bundle = bundle
        self.isOn = isOn
    }

    public var body: some View {
        VStack {
            Toggle(isOn: isOn) {
                Text(title, bundle: bundle)
            }
            .bold()
            .padding(.bottom, 5)

            Text(description, bundle: bundle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
        }
    }
}

#if DEBUG
struct DescriptiveToggle_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            DescriptiveToggle(title: "Dystopia", description: "Turning this on will end the world.", bundle: nil, isOn: .constant(false))

            DescriptiveToggle(title: "Utopia", description: "Turning this on will put an end to climate change.", bundle: nil, isOn: .constant(true))

            DescriptiveToggle(title: "Utopia", description: "Turning this on will put an end to climate change. Turning this on will put an ge. Turning this on will put an end to climate change.", bundle: nil, isOn: .constant(true))
        }
    }
}
#endif

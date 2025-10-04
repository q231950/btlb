//
//  DescriptiveSlider.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.05.23.
//

import Foundation
import SwiftUI
import Localization

public struct DescriptiveSlider: View {

    public class ViewModel: ObservableObject {
        let title: LocalizedStringKey
        let description: LocalizedStringKey
        let bundle: Bundle?
        @Binding private var selectedValue: UInt
        let range: ClosedRange<UInt>

        /// 0..1
        @Published var relativeValue: Float = 0

        public init(title: LocalizedStringKey, description: LocalizedStringKey, bundle: Bundle?, selectedValue: Binding<UInt>, in range: ClosedRange<UInt>) {
            self.title = title
            self.description = description
            self.bundle = bundle
            _selectedValue = selectedValue
            self.range = range

            defer {
                self.relativeValue = relativeValue(from: selectedValue.wrappedValue, in: range)
                self.latestHightlight = highlight(at: self.relativeValue)
            }
        }

        var daysCountDescriptionDigit: LocalizedStringKey {
            constructDaysCountDescriptionDigit(from: relativeValue)
        }
        var daysCountDescription: LocalizedStringKey {
            constructDaysCountDescription(from: relativeValue)
        }

        func snapToClosestValue() {
            selectedValue = value(from: relativeValue, in: range)
            let relativeValue = relativeValue(from: selectedValue, in: range)
                self.relativeValue = relativeValue
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1)
        }

        private var latestHightlight: Float = 0
        func highlightClosestValue() {
            let newHighlight = highlight(at: relativeValue)
            if latestHightlight != newHighlight {
                latestHightlight = newHighlight
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
            }
        }

        func highlight(at target: Float) -> Float {
            let highlights = snappingPoints.map {
                (key: $0, distance: $0.distance(to: target))
            }
            .sorted { a, b in
                abs(a.distance) < abs(b.distance)
            }

            return highlights.first?.key ?? Float(0)
        }

        private func constructDaysCountDescriptionDigit(from relativeValue: Float) -> LocalizedStringKey {
            let days = value(from: relativeValue, in: range)

            return "**\(days)**"
        }

        private func constructDaysCountDescription(from relativeValue: Float) -> LocalizedStringKey {
            let days = value(from: relativeValue, in: range)

            return "\(days == 1 ? Localization.Settings.Text.day : Localization.Settings.Text.days)"
        }

        private var snappingPoints: [Float] {
            (0..<steps).enumerated().map { step in
                Float(step.element) * Float(1) / Float(steps)
            }
        }

        private var steps: UInt {
            range.upperBound - range.lowerBound
        }

        func value(from relativeValue: Float, in range: ClosedRange<UInt>) -> UInt {
            return range.lowerBound + UInt((Float(steps) * relativeValue).rounded())
        }

        func relativeValue(from selectedValue: UInt, in range: ClosedRange<UInt>) -> Float {
            Float(selectedValue - range.lowerBound) / Float(steps)
        }
    }

    @ObservedObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            Text(viewModel.title, bundle: viewModel.bundle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)

            Text(viewModel.description, bundle: viewModel.bundle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .center) {

                HStack {
                    Text(viewModel.daysCountDescriptionDigit)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.title2)
                        .padding(.top, 5)
                        .animation(.default, value: viewModel.daysCountDescriptionDigit)

                    Text(viewModel.daysCountDescription)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .padding(.top, 5)
                        .animation(.default, value: viewModel.daysCountDescription)
                }

                Slider(value: $viewModel.relativeValue, label: {
                    Text(viewModel.title)
                }, minimumValueLabel: {
                    Text("\(viewModel.range.lowerBound)")
                }, maximumValueLabel: {
                    Text("\(viewModel.range.upperBound)")
                }) { editing in
                    if !editing {
                        viewModel.snapToClosestValue()
                    }
                }
                .padding(.bottom, 10)
                .onChange(of: viewModel.relativeValue) { newValue in
                    viewModel.highlightClosestValue()
                }
            }
            .padding([.leading, .trailing])
        }
    }
}

struct DescriptiveSlider_Previews: PreviewProvider {

    struct Preview: View {
        @State private var value: UInt = 5

        var body: some View {
            let viewModel = DescriptiveSlider.ViewModel(
                title: "title asd asd  adas    sdasdasdl    jalsd  l",
                description: "description description description description description description description",
                bundle: nil,
                selectedValue: $value,
                in: ClosedRange(uncheckedBounds: (lower: 2, upper: 10))
            )

            return DescriptiveSlider(viewModel: viewModel)
        }
    }
    static var previews: some View {
        Preview()
    }
}

//
//  BookSecondaryDetailsView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct BookSecondaryDetails: View {
    var book: Book
    
    var body: some View {
        HStack(alignment: .top) {
            detailSection(title: "Publisher", image: AnyView(FakePublisherLogo()))
            Divider()
            detailSection(title: "Released", mainText: book.releaseDate?.yearString, subText: book.releaseDate?.formattedString)
            Divider()
            detailSection(title: "Length", mainText: "\(book.pageCount)", subText: "Pages")
        }
        .padding(.top)
        .frame(height: 65)
    }
    
    private func detailSection(title: String, image: AnyView? = nil, mainText: String? = nil, subText: String? = nil) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
            Spacer().frame(height: 1)
            if let imageView = image {
                imageView
                    .scaledToFit()
                    .frame(height: 40)
            } else {
                Text(mainText ?? "")
                Spacer().frame(height: 1)
                Text(subText ?? "")
                    .font(.caption)
            }
            Spacer()
        }
        .frame(width: 120)
    }
}

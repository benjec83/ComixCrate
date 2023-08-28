//
//  BookTileModel.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/29/22.
//

import SwiftUI
import CoreData


struct BookTileModel: View {
    
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.fileName, ascending: true)])
//    private var book: FetchedResults<Book>
    let book: Book
    // Computed property to get series name
    var seriesName: String? {
        book.series?.name
    }

    // Computed property to get publisher name
    var publisherName: String? {
        book.publisher?.name
    }

    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if let url = URL(string: book.thumbnailPath ?? ""), let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("placeholderImageName")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            

            .shadow(radius: 1)
            .frame(height: 266)
            
            VStack(alignment: .leading) {
                
                Text("#" + "\(book.issueNumber)" + " - " + "\(book.title ?? "")")
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text("\(seriesName ?? "")" + " (" + "\(book.volumeYear)" + ")")
                    .font(.caption2)
                    .lineLimit(1)
//                BookStatusBar(book: book)
                Spacer()
                
            }
        }
        .frame(width: 180, height: 345)
        .padding()
        .scaledToFit()
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)

    }
}


//struct BookTileViewModel_Previews: PreviewProvider {
//    static var previews: some View {
//        BookTileModel(book: books[0])
//
//    }
//}

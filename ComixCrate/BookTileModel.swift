//
//  BookTileModel.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/29/22.
//

import SwiftUI


struct BookTileModel: View {
    
    var book: Book

    
    var readColor: Color {
        if book.read ?? 0 >= 100 {
            return Color.blue
        } else {
            return Color("NotTrueColor")
        }
    }

    var favoriteColor: Color {
        if book.favorite == true {
            return Color.blue
        } else {
            return Color("NotTrueColor")
        }
    }

    var downloadColor: Color {
        if book.downloaded == true {
            return Color.blue
        } else {
            return Color("NotTrueColor")
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                book.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .shadow(radius: 1)
            .frame(height: 266)
            
            VStack(alignment: .leading) {
                
                Text("#" + "\(book.issue)" + " - " + (book.title ?? ""))
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text(book.series + " (" + "\(book.volume)" + ")")
                    .font(.caption2)
                    .lineLimit(1)
                BookStatusBar(book: book)
                Spacer()
                
            }
        }
        .frame(width: 180, height: 345)
        .padding()
        .scaledToFit()
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
        .contextMenu {
            Button {
                
            } label: {
                Label("Read Now", systemImage: "magazine")
            }
            Button {

            } label: {
                Label("Mark As Read", systemImage: "checkmark.circle")
            }
            Button {

            } label: {
                Label("Add to Favorite", systemImage: "star")
            }
            Button {

            } label: {
                Label("Add to Reading Pile", systemImage: "square.stack.3d.up")
            }
            Button {

            } label: {
                Label("Add to a Reading List", systemImage: "list.bullet.rectangle.portrait")
            }
            Divider()
            Menu("Manage Book") {
                Button {

                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) {

                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        
    }
}


struct BookTileViewModel_Previews: PreviewProvider {
    static var previews: some View {
        BookTileModel(book: books[0])

    }
}

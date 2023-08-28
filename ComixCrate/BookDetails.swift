//
//  BookDetails.swift
//  Comic Reader
//
//  Created by Benjamin Carney on 1/14/23.
//

import SwiftUI

struct BookMainDetails: View {
    
    var book: Book
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("#" + "\(book.issue)" + " - " + (book.title ?? ""))
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                Text(book.series + " (" + "\(book.volume)" + ")")
                    .font(.caption2)
                    .lineLimit(2)
                Text((book.storyArc ?? ""))
                    .font(.caption2)
                    .fontWeight(.light)
                    .lineLimit(1)
                
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: 360)
    }
}



struct BookSecondaryDetails: View {
    var book: Book
    
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .center) {
                
                Text("Publisher")
                    .font(.subheadline)
                Spacer()
                    .frame(height: 1)
                PublisherLogo(publisherLogo: book.logo)
                    .scaledToFit()
                    .frame(height: 40)
                Spacer()
            }
            .frame(width: 120)
            
            Divider()
            
            //Released
            VStack {
                
                Text("Released")
                    .font(.subheadline)
                Spacer()
                    .frame(height: 1)
                Text("Year")
                Spacer()
                    .frame(height: 1)
                Text("Month DD")
                    .font(.caption)
                Spacer()
            }
            .frame(width: 120)
            Divider()
            
            //Pages
            VStack {
                
                Text("Length")
                    .font(.subheadline)
                Spacer()
                    .frame(height: 1)
                Text("2000")
                Spacer()
                    .frame(height: 1)
                Text("Pages")
                    .font(.caption)
                Spacer()
            }
            .frame(width: 120)
            Spacer()
        }
        .padding(.top)
        .frame(height: 65)
        //        Divider()
    }
}


struct BookActionButtons: View {
    
    var book: Book
    
    var body: some View {
        
        
        VStack {
            Spacer()
            HStack {
                Button {
                    print("Read Now " + (book.title ?? "") + " pressed")
                } label: {
                    Label("Read Now", systemImage: "magazine")
                }
                .frame(width: 345.0, height: 55.0)
                .accessibilityAddTraits([.isButton])
                .accessibilityLabel("Read Now")
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
                .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/51.0/*@END_MENU_TOKEN@*/)
                .font(/*@START_MENU_TOKEN@*/.headline/*@END_MENU_TOKEN@*/)
            }
            .frame(width: 345.0, height: 55)
            .background(Color.blue)
            
            .cornerRadius(51.0)
            .foregroundColor(.white)
            .font(.headline)
            
            HStack {
                Button {
                    print("Mark As Read " + (book.title ?? "") + " pressed")
                } label: {
                    Label("Mark As Read", systemImage: "checkmark.circle")
                }
                .frame(width: 345.0, height: 55.0)
                .accessibilityAddTraits([.isButton])
                .accessibilityLabel("Mark As Read")
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
                .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/51.0/*@END_MENU_TOKEN@*/)
                .font(/*@START_MENU_TOKEN@*/.headline/*@END_MENU_TOKEN@*/)
            }
            
            
            HStack {
                Button {
                    print("Add to Reading Pile " + (book.title ?? "") + " pressed")
                } label: {
                    Label("Add to Reading Pile", systemImage: "square.stack.3d.up")
                }
                .frame(width: 345.0, height: 55.0)
                .accessibilityAddTraits([.isButton])
                .accessibilityLabel("Add to Reading Pile")
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
                .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/51.0/*@END_MENU_TOKEN@*/)
                .font(/*@START_MENU_TOKEN@*/.headline/*@END_MENU_TOKEN@*/)
            }
            
            .frame(width: 345.0, height: 55)
            .background(Color.blue)
            
            .cornerRadius(51.0)
            
            .foregroundColor(.white)
            .font(.headline)
            Spacer()
            //Ratings
            HStack {
                Spacer()
                VStack{
                    Text("Personal Rating")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    HStack(spacing: -1.0) {
                        Image(systemName: "star")
                        Image(systemName: "star")
                        Image(systemName: "star")
                        Image(systemName: "star")
                        Image(systemName: "star")
                    }
                    .foregroundColor(Color.gray)
                }
                Spacer()
                VStack {
                    Text("Community Rating")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    HStack(spacing: -1.0) {
                        Image(systemName: "star")
                        Image(systemName: "star")
                        Image(systemName: "star")
                        Image(systemName: "star")
                        Image(systemName: "star")
                    }
                    .foregroundColor(Color.gray)
                }
                Spacer()
            }
        }
        .frame(height: 250)
    }
}

struct BookDetailTabs: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var bookIndex: Int {
        modelData.books.firstIndex(where: { $0.id == book.id })!
    }
        
    var book: Book
    
    var body: some View {
        
        TabView {
            BookDetailsMainView(book: book)
                .tabItem {
                    Image(systemName: "info")
                    Text("Information")
                }
            BookDetailsCreativesView(book: book)
                .tabItem {
                    Image(systemName: "photo.artframe")
                    Text("Creative Team")
                }
            BookDetailsDetailsView(book: book)
                .tabItem {
                    Image(systemName: "star")
                    Text("Details")
                }
            BookDetailsLibraryView(book: book)
                .tabItem {
                    Image(systemName: "rectangle.grid.3x2")
                    Text("Collection")
                }
        }
        .navigationTitle("#" + "\(book.issue)" + " - " + (book.title ?? book.series))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                HStack {
            Button{
                print("Edit " + (book.title ?? "") + " pressed")
            } label: {
                Label("Edit", systemImage: "pencil")
            }
                        FavoriteButton(isSet: $modelData.books[bookIndex].favorite)
            Menu {
                Button{
                    
                } label: {
                    Label("Button 1", systemImage: "pencil")
                }
                Button{
                    
                } label: {
                    Label("Button 2", systemImage: "pencil")
                }
                Divider()
                Button{
                    
                } label: {
                    Label("Button 3", systemImage: "pencil")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        )
    }
    
}

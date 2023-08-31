//
//  BookDetails.swift
//  Comic Reader
//
//  Created by Benjamin Carney on 1/14/23.
//

import SwiftUI
import CoreData

struct BookMainDetails: View {
    let book: Book
    /// Computed property to get series name
    var seriesName: String? {
        book.series?.name
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("#\(String(book.issueNumber)) - \(book.title ?? "")")
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                Text("\(seriesName ?? "")" + " " + "(\(book.volumeYear))")
                    .font(.caption2)
                    .lineLimit(2)
                Text("Story Arc")
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
            detailSection(title: "Publisher", image: AnyView(FakePublisherLogo()))
            Divider()
            detailSection(title: "Released", mainText: "Year", subText: "Month DD")
            Divider()
            detailSection(title: "Length", mainText: "2000", subText: "Pages")
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

struct BookActionButtons: View {
    var book: Book
    
    var body: some View {
        VStack {
            Spacer()
            actionButton(title: "Read Now", icon: "magazine")
            actionButton(title: "Mark As Read", icon: "checkmark.circle")
            actionButton(title: "Add to Reading Pile", icon: "square.stack.3d.up")
            Spacer()
            ratingsSection(title: "Personal Rating")
            ratingsSection(title: "Community Rating")
        }
        .frame(height: 250)
    }
    
    private func actionButton(title: String, icon: String) -> some View {
        Button {
            print("\(title) \(book.title ?? "") pressed")
        } label: {
            Label(title, systemImage: icon)
                .frame(width: 345.0, height: 55.0)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(51.0)
                .font(.headline)
        }
    }
    
    private func ratingsSection(title: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            HStack(spacing: -1.0) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star")
                }
            }
            .foregroundColor(Color.gray)
        }
    }
}

struct BookDetailTabs: View {
    let book: Book
    @State private var isFavorite: Bool


    public init(book: Book) {
        self.book = book
        _isFavorite = State(initialValue: book.isFavorite)
    }
    
    /// Computed property to get series name
    var seriesName: String? {
        book.series?.name
    }
    
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
        .navigationTitle("#" + "\(book.issueNumber)" + " - " + "\(book.title ?? seriesName ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                HStack {
            Button{
                print("Edit " + (book.title ?? "") + " pressed")
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            FavoriteButton(book: book, context: book.managedObjectContext ?? PersistenceController.shared.container.viewContext)

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



public struct BookDetailsMainView: View {
    let book: Book
    @State private var shouldCacheHighQualityThumbnail: Bool = false

    public init(book: Book) {
        self.book = book
    }
    
    public var body: some View {
        
        ScrollView {
            HStack {
                HStack(alignment: .center) {
                    ThumbnailProvider(book: book, isHighQuality: true)
                        .scaledToFit()
                        .frame(height: 390.0)
                        .frame(maxWidth: 255)
                        .padding(.all)
                        .shadow(radius: 1)
                }
                VStack {
                    //Book Details
                    
                    // Main Book Details
                    HStack {
                        BookMainDetails(book: book)
                    }
                    // Secondary Book Details
                    BookSecondaryDetails(book: book)
                    
                    //Action Buttons
                    BookActionButtons(book: book)
                }
                .padding(.all)
                .frame(width: 380)
            }
            .frame(width: 710)
            
            Divider()
                .padding(.horizontal, 30.0)
            VStack(alignment: .leading) {
                HStack {
                    Text("Description:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5.0)
                    Spacer()
                }
                Text(book.sypnosis ?? "")
            }
            .font(.subheadline)
            .padding(.horizontal)
            .frame(maxWidth: 690)
            
        }
        // When the BookDetailsMainView appears, set the trigger to true
        .onAppear {
            shouldCacheHighQualityThumbnail = true
        }

        ThumbnailProvider(book: book, isHighQuality: true, shouldCacheHighQuality: $shouldCacheHighQualityThumbnail)
    }
}

public struct BookDetailsLibraryView: View {
    
    let book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Library View")

        }
    }
}

public struct BookDetailsDetailsView: View {
    
    let book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Details View")

        }
        
    }
}

public struct BookDetailsCreativesView: View {
    let book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Creatives View")
        }
    }
}

struct FakePublisherLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
            
            Text("P")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}



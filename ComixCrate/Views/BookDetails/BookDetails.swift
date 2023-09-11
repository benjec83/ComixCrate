//
//  BookDetailsView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI
import CoreData

struct BookDetails: View {
    @ObservedObject var viewModel: SelectedBookViewModel
    
    @State private var isFavorite: Bool
    @State private var isEditing: Bool = false
    
    @ObservedObject var book: Book
    
    public init(book: Book) {
        self.book = book
        _isFavorite = State(initialValue: book.isFavorite)
    }
    
    private var seriesName: String? {
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
            BookDetailsMoreView(book: book)
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
        .navigationTitle("#" + "\(String(book.issueNumber))" + " - " + "\(book.title ?? seriesName ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                HStack {
            Button {
                isEditing = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .sheet(isPresented: $isEditing) {
                EditBookView(book: book)
            }
            FavoriteButton(book: book, context: book.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            
            Menu {
                Button(action: {}) {
                    Label("Button 1", systemImage: "pencil")
                }
                Button(action: {}) {
                    Label("Button 2", systemImage: "pencil")
                }
                Divider()
                Button(action: {}) {
                    Label("Button 3", systemImage: "pencil")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        )
    }
}


func ratingsSection(title: String, rating: Double) -> some View {
    @ObservedObject var viewModel: SelectedBookViewModel

    VStack {
        Text(title)
            .font(.caption)
            .multilineTextAlignment(.center)
            .lineLimit(1)
        HStack(spacing: -1.0) {
            ForEach(0..<5) { index in
                starImage(for: index, in: rating)
                    .onTapGesture {
                        updateUserRating(to: Double(index) + 0.5)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let width = value.location.x
                                let computedRating = Double(width / 30)
                                updateUserRating(to: min(max(computedRating, 0.5), 5))
                            }
                    )
            }
        }
    }
}

private func starImage(for index: Int, in rating: Double) -> some View {
    if rating > Double(index) + 0.5 {
        return Image(systemName: "star.fill").foregroundColor(Color.yellow)
    } else if rating > Double(index) {
        return Image(systemName: "star.leadinghalf.fill").foregroundColor(Color.yellow)
    } else {
        return Image(systemName: "star").foregroundColor(Color.gray)
    }
}

struct BookActionButtons: View {
    @ObservedObject var viewModel: SelectedBookViewModel
    
    @ObservedObject var book: Book
    @State private var userRating: Double
    @Environment(\.managedObjectContext) private var viewContext
    
    enum ActionTitle: String {
        case readNow = "Read Now"
        case markAsRead = "Mark As Read"
        case markAsUnread = "Mark As Unread"
        case addToReadingPile = "Add to Reading Pile"
    }
    
    init(book: Book) {
        self.book = book
        _userRating = State(initialValue: Double(book.personalRating) / 2.0)
    }
    
    var body: some View {
        VStack {
            Spacer()
            actionButton(title: .readNow, icon: "magazine")
            actionButton(title: bookIsRead ? .markAsUnread : .markAsRead, icon: "checkmark.circle")
            actionButton(title: .addToReadingPile, icon: "square.stack.3d.up")
            Spacer()
            ratingsSection(title: "Personal Rating", rating: userRating)
        }
        .frame(height: 250)
        .onAppear {
            userRating = book.personalRating
        }
    }
    
    private var bookIsRead: Bool {
        book.read == 1
    }
    
    private func actionButton(title: ActionTitle, icon: String) -> some View {
        Button {
            switch title {
            case .markAsRead:
                viewModel.markBookAsRead()
            case .markAsUnread:
                viewModel.markBookAsUnread()
            default:
                print("\(title.rawValue) \(viewModel.book.title ?? "") pressed")
            }
        } label: {
            // ... rest of the code
        }
    }
}


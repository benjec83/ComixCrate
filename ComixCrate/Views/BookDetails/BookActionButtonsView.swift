//
//  BookActionButtonsView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

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
    
    init(book: Book, viewModel: SelectedBookViewModel) {
        self.book = book // Initialize book here
        self.viewModel = viewModel // Initialize viewModel here
        _userRating = State(initialValue: Double(viewModel.book.personalRating) / 2.0)
    }
    
    var body: some View {
        VStack {
            Spacer()
            actionButton(title: .readNow, icon: "magazine")
            actionButton(title: viewModel.bookIsRead ? .markAsUnread : .markAsRead, icon: "checkmark.circle")
            actionButton(title: .addToReadingPile, icon: "square.stack.3d.up")
            Spacer()
            ratingsSection(title: "Personal Rating", rating: userRating)
        }
        .frame(height: 250)
        .onAppear {
            userRating = book.personalRating
        }
    }
    
    func ratingsSection(title: String, rating: Double) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            HStack(spacing: -1.0) {
                ForEach(0..<5) { index in
                    BookActionButtons.starImage(for: index, in: rating)
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
    
    func updateUserRating(to newRating: Double) {
        userRating = newRating
        book.personalRating = newRating
        saveContext()
    }
    
    static func starImage(for index: Int, in rating: Double) -> some View {
        if rating > Double(index) + 0.5 {
            return Image(systemName: "star.fill").foregroundColor(Color.yellow)
        } else if rating > Double(index) {
            return Image(systemName: "star.leadinghalf.fill").foregroundColor(Color.yellow)
        } else {
            return Image(systemName: "star").foregroundColor(Color.gray)
        }
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
            Label(title.rawValue, systemImage: icon)
                .frame(width: 345.0, height: 55.0)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(51.0)
                .font(.headline)
        }
    }
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to update read status: \(error)")
        }
    }
}

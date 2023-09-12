//
//  IndividualChip.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct IndividualChip: View {
    @ObservedObject var viewModel: SelectedBookViewModel
    
    
    var chip: TempChipData
    var showIcon: Bool = true
    var showDeleteButton: Bool = true
    var maxWidth: CGFloat = 100  // Default value, you can adjust this or set it when creating the Chip
    var label: String
    var type: EntityType
        
        var onDeleteChip: (() -> Void)? = nil

    var body: some View {
        HStack {
            if showIcon {
                Image(systemName: iconName())
                    .foregroundColor(.white)
            }
            Text(label)
                .lineLimit(1)
                .truncationMode(.tail)
            if showDeleteButton, let onDeleteChip = onDeleteChip {
                Button(action: onDeleteChip) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, label.count < 10 ? 10 : 14)  // Conditional padding
        .padding(.vertical, 5)
        .background(Color.accentColor)
        .foregroundColor(.white)
        .cornerRadius(20)
    }
    
    func iconName() -> String {
        return type.iconName
    }
}


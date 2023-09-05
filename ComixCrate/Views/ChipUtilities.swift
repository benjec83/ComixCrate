//
//  ChipUtilities.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/4/23.
//

import SwiftUI
import CoreData

enum ChipType: String {
    case storyArc = "BookStoryArcs"
    case creator
    // Add other types as needed

    func iconName() -> String {
        switch self {
        case .storyArc:
            return "sparkles.rectangle.stack.fill"
        case .creator:
            return "person.circle.fill"
        }
    }
}

struct Chip: View {
    var label: String
    var onDelete: (() -> Void)? = nil
    var type: ChipType
    var showIcon: Bool = true
    var showDeleteButton: Bool = true
    var maxWidth: CGFloat = 100  // Default value, you can adjust this or set it when creating the Chip
    
    var body: some View {
        HStack {
            if showIcon {
                Image(systemName: iconName())
                    .foregroundColor(.white)
            }
            Text(label)
                .lineLimit(1)
                .truncationMode(.tail)
            if showDeleteButton, let onDelete = onDelete {
                Button(action: onDelete) {
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
        return type.iconName()
    }
}


struct ChipView: View {
    @Binding var chips: [TempChipData]
    
    @Binding var editedStoryArcName: String
    @Binding var editedStoryArcPart: String
    
    @Binding var chipViewHeight: CGFloat
    
    var fontSize: CGFloat = 16
    
    let estimatedRowHeight: CGFloat = 40  // This is an estimate based on your chip design
    
    

    
    // Adding Geometry Effect to Chip...
    @Namespace var animation
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(getRows(containerWidth: containerWidth), id: \.self) { rows in
                    HStack(spacing: 1) {
                        ForEach(rows) { row in
                            RowView(chip: row)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
            .fixedSize(horizontal: false, vertical: true)
            .animation(.easeInOut, value: chips)
            .background(GeometryReader { gp -> Color in
                DispatchQueue.main.async {
                    // Update on next cycle with calculated height of VStack
                    self.chipViewHeight = gp.size.height
                }
                return Color.clear
            })
        }
    }
    
    func createLabel(for chip: TempChipData) -> String {
        switch chip.value2 {
        case .string:
            return chip.value1
        case .int16(let intValue):
            return (intValue != 0) ? "\(chip.value1) - Part \(intValue)" : chip.value1
        }
    }

    @ViewBuilder
    func RowView(chip: TempChipData) -> some View {
        let label = createLabel(for: chip)

        Chip(label: label, onDelete: {
            if let index = chips.firstIndex(where: {
                $0.value1 == chip.value1 &&
                (String(describing: $0.value2) == String(describing: chip.value2))
            }) {
                chips.remove(at: index)
            }
        }, type: .storyArc, showIcon: true, showDeleteButton: true)
        .font(.system(size: fontSize))
        .padding(.horizontal, 5)
        .lineLimit(1)
        .frame(maxWidth: 300)
        .matchedGeometryEffect(id: chip.id, in: animation)
        .onTapGesture {
            if let index = chips.firstIndex(where: {
                $0.value1 == chip.value1 &&
                (String(describing: $0.value2) == String(describing: chip.value2))
            }) {
                editedStoryArcName = chip.value1
                switch chip.value2 {
                case .string(let stringValue):
                    editedStoryArcPart = stringValue
                case .int16(let intValue):
                    editedStoryArcPart = "\(intValue)"
                }
                chips.remove(at: index) // Remove the old chip
            }
        }
    }

    
    func getRows(containerWidth: CGFloat) -> [[TempChipData]] {
        var rows: [[TempChipData]] = []
        var currentRow: [TempChipData] = []
        
        var totalWidth: CGFloat = 0
        
        chips.forEach { chip in
            let label: String
            switch chip.value2 {
            case .string(_):
                label = chip.value1
            case .int16(let intValue):
                label = intValue != 0 ? "\(chip.value1) - Part \(intValue)" : chip.value1
            }
            let font = UIFont.systemFont(ofSize: fontSize)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (label as NSString).size(withAttributes: attributes)
            
            // updating total width...
            totalWidth += (size.width + 40)
            
            // checking if total width is greater than size...
            if totalWidth > containerWidth {
                rows.append(currentRow)
                currentRow.removeAll()
                currentRow.append(chip)
                totalWidth = size.width + 40  // Reset total width for the new row
            } else {
                currentRow.append(chip)
            }
        }
        
        // Safe check...
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
}
//
//  ChipUtilities.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/4/23.
//

import SwiftUI
import CoreData

// MARK: - ChipType Enum
enum ChipType: String {
    case bookStoryArc = "BookStoryArcs"
    case bookEvents = "BookEvents"
    case creator = "Creators"
    // Add other types as needed
    
    func iconName() -> String {
        switch self {
        case .bookStoryArc:
            return "sparkles.rectangle.stack.fill"
        case .bookEvents:
            return "theatermasks.fill"
        case .creator:
            return "paintpalette.fill"
        }
    }
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        switch self {
        case .bookStoryArc:
            return StoryArc.fetchRequest()
        case .bookEvents:
            return Event.fetchRequest()
        case .creator:
            // Assuming you have a Creator entity
            return Creator.fetchRequest()
        }
    }
    var correspondingTextFieldEntity: TextFieldEntities {
        switch self {
        case .bookStoryArc:
            return .bookStoryArcs(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
        case .bookEvents:
            return .bookEvents(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
        case .creator:
            return .bookCreatorRole(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
        }
    }
}


// MARK: - Chip View
struct Chip: View {
    var label: String
    var onDeleteChip: (() -> Void)? = nil
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
        return type.iconName()
    }
}


struct ChipView: View {
    @Binding var chips: [TempChipData]
    
    @Binding var editedAttribute1: String
    @Binding var editedAttribute2: String
    var type: ChipType
    
    @Binding var chipViewHeight: CGFloat
    
    var fontSize: CGFloat = 16
    let estimatedRowHeight: CGFloat = 40  // This is an estimate based on your chip design
    
    // Adding Geometry Effect to Chip...
    @Namespace var animation
    
    // Filter the chips based on the ChipType
    var filteredChips: [TempChipData] {
        return chips.filter { ChipType(entity: $0.entity) == type }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(getRows(containerWidth: containerWidth, chips: filteredChips), id: \.self) { rows in
                    HStack(spacing: 1) {
                        ForEach(rows) { row in
                            RowView(chip: row)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 250)
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
        switch chip.tempValue2 {
        case .string:
            return chip.tempValue1
        case .int16(let intValue):
            if chip.entity == "BookStoryArcs" {
                return (intValue != 0) ? "\(chip.tempValue1) - Part \(intValue)" : chip.tempValue1
            } else if chip.entity == "BookEvents" { // Handle events
                return (intValue != 0) ? "\(chip.tempValue1) - Part \(intValue)" : chip.tempValue1
            } else {
                return chip.tempValue1
            }
        }
    }
    
    // MARK: - RowView Function
    @ViewBuilder
    func RowView(chip: TempChipData) -> some View {
        if let chipType = ChipType(entity: chip.entity) {
            let label = createLabel(for: chip)
            Chip(label: label, onDeleteChip: {
                // Print the values of chip.tempValue1 and chip.tempValue2
                print("Attempting to delete chip with tempValue1: \(chip.tempValue1) and tempValue2: \(chip.tempValue2)")
                
                if let index = chips.firstIndex(where: {
                    $0.tempValue1 == chip.tempValue1 &&
                    (String(describing: $0.tempValue2) == String(describing: chip.tempValue2))
                }) {
                    // Print the index of the chip found
                    print("Found chip at index: \(index). Deleting...")
                    chips.remove(at: index)
                } else {
                    // Print a message if the chip is not found
                    print("Chip not found in the array.")
                }
            }, type: chipType, showIcon: true, showDeleteButton: true)
            .font(.system(size: fontSize))
            .padding(.horizontal, 5)
            .lineLimit(1)
            .frame(maxWidth: 300)
            .matchedGeometryEffect(id: chip.id, in: animation)
            .onTapGesture {
                if let index = chips.firstIndex(where: {
                    $0.tempValue1 == chip.tempValue1 &&
                    (String(describing: $0.tempValue2) == String(describing: chip.tempValue2))
                }) {
                    editedAttribute1 = chip.tempValue1
                    switch chip.tempValue2 {
                    case .string(let stringValue):
                        editedAttribute1 = stringValue
                    case .int16(let intValue):
                        editedAttribute2 = "\(intValue)"
                    }
                    chips.remove(at: index) // Remove the old chip
                }
            }
        } else {
            // Handle the error case, perhaps with a Text view displaying an error message
            Text("Invalid entity provided: \(chip.entity)")
        }
    }
    
    
    
    func getRows(containerWidth: CGFloat, chips: [TempChipData]) -> [[TempChipData]] {
        var rows: [[TempChipData]] = []
        var currentRow: [TempChipData] = []
        
        var totalWidth: CGFloat = 0
        
        chips.forEach { chip in
            let label: String
            switch chip.tempValue2 {
            case .string(_):
                label = chip.tempValue1
            case .int16(let intValue):
                label = intValue != 0 ? "\(chip.tempValue1) - Part \(intValue)" : chip.tempValue1
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

// MARK: - ChipType Extension
extension ChipType {
    init?(entity: String) {
        switch entity {
        case "BookStoryArcs":
            self = .bookStoryArc
        case "BookEvents":
            self = .bookEvents
        case "Creators":
            self = .creator
        default:
            return nil
        }
    }
}

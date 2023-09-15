//
//  ChipView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI
import CoreData

struct ChipView: View {
    @ObservedObject var viewModel: SelectedBookViewModel

    @Binding var chips: [TempChipData]
    var type: EntityType
    
    @Binding var chipViewHeight: CGFloat
    
    var fontSize: CGFloat = 16
    
    @Namespace private var animation
    
    var body: some View {
        
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(getRows(containerWidth: containerWidth, chips: chips.filter { EntityType(rawValue: $0.entity) == type }), id: \.self) { rows in
                    HStack(spacing: 1) {
                        ForEach(rows) { row in
                            IndividualChip(viewModel: viewModel, chip: row, label: createLabel(for: row), type: type, onDeleteChip: {
                                if let index = chips.firstIndex(where: { $0.id == row.id }) {
                                    chips.remove(at: index)            //                        }
                                }
                            }
                            )}
//                        .padding(.bottom, 2)
                        .fixedSize(horizontal: false, vertical: false)
//                        .frame(minWidth: 250)
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
            }
        }
//        .padding(.bottom, 100)
    }
    
    func createLabel(for chip: TempChipData) -> String {
        guard let entityType = EntityType(rawValue: chip.entity) else {
            return chip.tempValue1 // Default return if entity type is not recognized
        }
        
        let attribute1DisplayName = entityType.attribute.field1.displayName
        let attribute2DisplayName = entityType.attribute.field2.displayName
        
        switch chip.tempValue2 {
        case .string:
            return chip.tempValue1
        case .int16(let intValue):
            return (intValue != 0) ? "\(chip.tempValue1) - Part \(intValue)" : chip.tempValue1
        }
    }

    
    // MARK: - RowView Function
    @ViewBuilder
    func RowView(chip: TempChipData) -> some View {
        if let chipType = EntityType(rawValue: chip.entity) {
            let label = createLabel(for: chip)
            IndividualChip(viewModel: viewModel, chip: chip, label: createLabel(for: chip), type: type, onDeleteChip: {
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
            })
            .font(.system(size: fontSize))
            .padding(.horizontal, 5)
            .lineLimit(1)
            .frame(maxWidth: 300)
            .matchedGeometryEffect(id: chip.id, in: animation)
            .onTapGesture {
                // Update the ViewModel's edited attributes based on the tapped chip
                viewModel.updateEditedAttributes(for: chip)

                // Check if the chip exists in the chips array
                if let index = chips.firstIndex(where: {
                    $0.tempValue1 == chip.tempValue1 &&
                    (String(describing: $0.tempValue2) == String(describing: chip.tempValue2))
                }) {
                    // Remove the old chip
                    chips.remove(at: index)
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


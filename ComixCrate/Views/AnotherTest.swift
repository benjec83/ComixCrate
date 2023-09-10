//
//  AnotherTest.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/7/23.
//
//
import SwiftUI

//struct AnotherTest: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.presentationMode) var presentationMode
//    
//    // Example state to switch between fetch requests
//    @State private var selectedType: EntityType = .storyArc
//    @State private var isEditing: Bool = false
//    @State private var newName: String = ""
//    
//    // Separate fetch requests for each entity type
//    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
//    private var allStoryArcs: FetchedResults<StoryArc>
//    
//    @FetchRequest(entity: Characters.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Characters.characterName, ascending: true)])
//    
//    private var allCharacters: FetchedResults<Characters>
//    
//    var body: some View {
//          VStack {
//              Picker("Type", selection: $selectedType) {
//                  Text("Story Arc").tag(EntityType.storyArc)
//                  Text("Character").tag(EntityType.character)
//              }
//              .pickerStyle(SegmentedPickerStyle())
//              .padding()
//              // Add new data
//              HStack {
//                  TextField("Enter new name", text: $newName)
//                  Button("Add Story Arc") {
//                      switch selectedType {
//                      case .storyArc:
//                          addStoryArc(name: newName)
//                      case .character:
//                          addCharacter(name: newName)
//                      }
//                      newName = ""
//                  }
//              }
//              .padding()
//              
//              // Conditionally display content based on selected type
//              switch selectedType {
//              case .storyArc:
//                  List {
//                      ForEach(allStoryArcs, id: \.self) { arc in
//                          TextField("Story Arc Name", text: Binding(
//                              get: { arc.storyArcName ?? "" },
//                              set: { arc.storyArcName = $0 }
//                          ))
//                      }
//                      .onDelete(perform: deleteStoryArc)
//                  }
//              case .character:
//                  List {
//                      ForEach(allCharacters, id: \.self) { character in
//                          TextField("Character Name", text: Binding(
//                              get: { character.characterName ?? "" },
//                              set: { character.characterName = $0 }
//                          ))
//                      }
//                      .onDelete(perform: deleteCharacter)
//                  }
//              }
//          }
//      }
//      
//      func addStoryArc(name: String) {
//          let newArc = StoryArc(context: viewContext)
//          newArc.storyArcName = name
//          saveContext()
//      }
//      
//      func addCharacter(name: String) {
//          let newCharacter = Characters(context: viewContext)
//          newCharacter.characterName = name
//          saveContext()
//      }
//       
//       func deleteStoryArc(at offsets: IndexSet) {
//           for index in offsets {
//               let arc = allStoryArcs[index]
//               viewContext.delete(arc)
//           }
//           saveContext()
//       }
//       
//       func deleteCharacter(at offsets: IndexSet) {
//           for index in offsets {
//               let character = allCharacters[index]
//               viewContext.delete(character)
//           }
//           saveContext()
//       }
//       
//       func saveContext() {
//           do {
//               try viewContext.save()
//           } catch {
//               let nsError = error as NSError
//               fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//           }
//       }
//   }
//
//#Preview {
//    AnotherTest()
//}
//
//
enum EntityType {
    case storyArc
    case character
    case events
    
    var entityName: String {
        switch self {
        case .storyArc:
            return "StoryArc"
        case .character:
            return "Character"
        case .events:
            return "Events"
        }
    }
    
    var buttonName: String {
        switch self {
        case .storyArc:
            return "Add a Story Arc"
        case .character:
            return "Add a Character"
        case .events:
            return "Add an Event"
        }
    }
    
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .storyArc:
            return NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)
        case .character:
            return NSSortDescriptor(keyPath: \Characters.characterName , ascending: true)
        case .events:
            return NSSortDescriptor(keyPath: \Event.eventName, ascending: true)
        }
    }
    enum ValueType {
        case string
        case int16
    }

}


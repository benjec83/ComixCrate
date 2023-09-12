//The primary entity in the core data base is 'Book'. Users add books to the library, and the other entities serve as a means of adding more complex information and grouping to the data about those books.
//
//You can see several entities that start with 'Book' and the rest of the name is another entity - 'BookEvents', 'BookStoryArcs' etc etc. You can see the relationships in the information below.
//
//The logic here is, for example, 'Event' can have one record of a value, let's use 'Event1' - but then 'BookEvents' can have several records of that same value,
//
//The functionality I'm trying to work out is maintaining the core data for adding, updating and deleting.
//
//Using the above example, a user should be able to add an event to a book. When adding it, there should be suggestions or autocomplete on existing Events, and if there isn't a match, the user can add a new Event. This should create a new record on Event, and also a new record on BookEvents.
//
//The 'BookEvents/BookStoryArcs' type entities are a bridge to create unique connections between the Book entity and the 'parent' Entity ('Event', 'StoryArc' etc). They also contain some attributes for place the books in order within the Event/Story Arc etc.
//
//The user should then be able to edit or update the name of the Event/Story Arc.
//
//A user should then be able to remove that 'Event' from a book. And if it's the only book within that Event, not only should the record delete on BookEvents, but also on Event, as it's no longer in use. We don't want any orphaned values in the parent entities.
//
//The same type of checks should happen when deleting a book.
//
//break down the requirements and the steps to implement the desired functionality:
//
//    1.    Autocomplete for Adding Events to a Book:
//    •    When a user starts typing an event name, the app should suggest existing events.
//    •    If the user selects an existing event, a new record in BookEvents should be created linking the book to the selected event.
//    •    If the user types a new event name, a new record in Event should be created, and a new record in BookEvents should also be created linking the book to the new event.
//    2.    Editing the Name of an Event/Story Arc:
//    •    When a user edits the name of an event, the corresponding record in the Event entity should be updated.
//    •    Any related records in BookEvents should remain unchanged since they reference the Event entity by ID (or a similar unique identifier).
//    3.    Removing an Event from a Book:
//    •    When a user removes an event from a book, the corresponding record in BookEvents should be deleted.
//    •    The app should then check if there are any other books linked to the event in BookEvents.
//    •    If there are no other books linked to the event, the event record in the Event entity should also be deleted to prevent orphaned values.
//    4.    Deleting a Book:
//    •    When a user deletes a book, all related records in BookEvents (and similar bridge entities) should be deleted.
//    •    For each event that was linked to the book, the app should check if there are any other books linked to the event in BookEvents.
//    •    If there are no other books linked to the event, the event record in the Event entity should also be deleted.
//
//here’s a step-by-step guide on how to implement the desired functionality:
//
//1. Autocomplete for Adding Events to a Book:
//
//    •    Fetching Existing Events:
//    •    Use a fetch request on the Event entity to retrieve all events.
//    •    Display these events as suggestions when the user starts typing in the event name.
//    •    Adding an Existing Event:
//    •    If the user selects an existing event from the suggestions:
//    •    Create a new BookEvents record linking the selected book to the chosen event.
//    •    Adding a New Event:
//    •    If the user types a new event name:
//    •    Create a new Event record with the provided name.
//    •    Create a new BookEvents record linking the selected book to the new event.
//
//2. Editing the Name of an Event/Story Arc:
//
//    •    Updating Event Name:
//    •    Fetch the Event record that the user wants to edit.
//    •    Update the eventName attribute with the new name provided by the user.
//    •    Save the changes to the Core Data context.
//
//3. Removing an Event from a Book:
//
//    •    Deleting BookEvent Record:
//    •    Fetch the BookEvents record that links the book to the event.
//    •    Delete this record.
//    •    Checking for Orphaned Event:
//    •    After deleting the BookEvents record, fetch all BookEvents records that link to the event.
//    •    If no records are found, delete the Event record as it’s no longer linked to any books.
//
//4. Deleting a Book:
//
//    •    Deleting Related BookEvents Records:
//    •    Fetch all BookEvents records linked to the book.
//    •    Delete these records.
//    •    Checking for Orphaned Events:
//    •    For each event that was linked to the book, fetch all BookEvents records that link to the event.
//    •    If no records are found for an event, delete the Event record.
//
//5. Handling Orphaned Values:
//
//    •    Orphaned Events:
//    •    After any operation that might result in orphaned events (e.g., deleting a book or removing an event from a book), check if there are any books linked to the event.
//    •    If not, delete the event to prevent orphaned values.
//    •    Orphaned Story Arcs, Characters, etc.:
//    •    Apply similar logic as above for other entities like StoryArc, Characters, etc. Check for orphaned values after operations that might result in them and delete them if necessary.
//
//Implementation Tips:
//
//    •    Use Core Data’s Cascade Delete Rule: For relationships where deleting one entity should result in the deletion of related entities, consider using Core Data’s cascade delete rule. This can simplify the deletion process.
//    •    Batch Operations: If you’re dealing with a large number of records, consider using batch operations to improve performance.
//    •    Error Handling: Always handle potential errors, especially when dealing with Core Data operations. This ensures data integrity and provides a better user experience.
//    •    UI Feedback: Provide feedback to the user after performing operations, such as confirming that an event has been added or a book has been deleted.
//
//Autocomplete for Adding Events to a Book:
//
//    •    Use a fetch request on the Event entity to retrieve all events. Display these as suggestions when the user starts typing in the event name.
//    •    If the user selects an existing event, use the CoreDataHelper class to save a new BookEvents record linking the book to the selected event.
//    •    If the user types a new event name, use the CoreDataHelper class to save a new Event record and a new BookEvents record.
//
//Editing the Name of an Event/Story Arc:
//
//    •    Fetch the Event record that the user wants to edit.
//    •    Update the eventName attribute and use the CoreDataHelper class to save the changes.
//
//Removing an Event from a Book:
//
//    •    Use the CoreDataDeleter class to delete the BookEvents record linking the book to the event.
//    •    After deleting, fetch all BookEvents records that link to the event. If no records are found, use the CoreDataDeleter class to delete the Event record.
//
//Deleting a Book:
//
//    •    Use the CoreDataDeleter class to delete the book record.
//    •    For each event linked to the book, fetch all BookEvents records that link to the event. If no records are found, use the CoreDataDeleter class to delete the Event record.
//
//Handling Orphaned Values:
//
//    •    After operations that might result in orphaned events, check if there are any books linked to the event. If not, use the CoreDataDeleter class to delete the event.
//
//Recommendations for Implementing Desired Functionalities:
//
//    1.    Autocomplete for Adding Events to a Book:
//    •    In the view where users add events to books, use a fetch request on the Event entity to retrieve all events. Display these as suggestions when the user starts typing in the event name.
//    •    If the user selects an existing event, create a new BookEvents record linking the book to the selected event.
//    •    If the user types a new event name, create a new Event record and a new BookEvents record.
//    2.    Editing the Name of an Event/Story Arc:
//    •    In the view where users edit events, fetch the Event record that the user wants to edit.
//    •    Update the eventName attribute and save the changes.
//    3.    Removing an Event from a Book:
//    •    In the view where users manage events for a book, provide an option to remove an event.
//    •    When an event is removed, delete the BookEvents record linking the book to the event.
//    •    After deleting, fetch all BookEvents records that link to the event. If no records are found, delete the Event record.
//    4.    Deleting a Book:
//    •    When a book is deleted (using the deleteSelectedBooks function), the deleteRelatedEntitiesIfOrphaned function is called to check for orphaned related entities.
//    •    Enhance this function to also check for orphaned Event and StoryArc records and delete them if necessary.
//    5.    Handling Orphaned Values:
//    •    The existing deleteRelatedEntitiesIfOrphaned and checkAndDeleteEntity functions handle the deletion of orphaned entities. Ensure that these functions are called appropriately after operations that might result in orphaned entities.
//
//1. Adding an Event to a Book:
//
//    •    When a user wants to add an event to a book, they should be presented with an input field (possibly a search bar or a text field).
//    •    As they type, you can use a fetch request with a predicate to filter existing events based on the input. This will provide autocomplete or suggestions.
//    •    If the user selects an existing event, you create a new BookEvents record linking the book to the selected event.
//    •    If the user types a new event name and confirms, you create a new Event record and then a new BookEvents record linking the book to the new event.
//
//2. Editing an Event:
//
//    •    When a user wants to edit the name of an event, they can tap on the event chip or name.
//    •    This should present them with an editable text field pre-filled with the current event name.
//    •    Once they make changes and confirm, update the Event record with the new name.
//
//3. Removing an Event from a Book:
//
//    •    When a user wants to remove an event from a book, they can tap on a delete or remove button next to the event chip or name.
//    •    This action should delete the corresponding BookEvents record.
//    •    After this, check if the event has any other associated BookEvents records. If not, delete the Event record to ensure there are no orphaned values.
//
//4. Deleting a Book:
//
//    •    When a user deletes a book, first delete all associated BookEvents records.
//    •    For each event that was associated with the book, check if there are any other associated BookEvents records. If not, delete the Event record.
//
//Implementation Tips:
//
//    •    Fetch Requests: Use fetch requests with predicates to filter and find specific records in your CoreData entities. This will be especially useful for the autocomplete functionality and for checking if an event has any other associated books.
//    •    CoreData Relationships: Leverage the relationships you’ve set up in CoreData. For example, when you want to check if an event has any other associated books, you can simply check the count of the booksInEvent relationship of the Event entity.
//    •    Consistency: Ensure that all changes to your CoreData entities are consistent. For example, when deleting a book, make sure to clean up all related records to avoid orphaned values.
//    •    UI Feedback: Provide feedback to the user when they add, edit, or delete events. This can be in the form of a confirmation message, a toast notification, or updating the UI in real-time.
//    •    Error Handling: Implement error handling for all CoreData operations. If an operation fails, inform the user and provide options for retrying or reporting the issue.
//
//Recommendations:
//
//    1.    Code Organization: Consider breaking this file into multiple smaller files. For instance, EntityProtocol and AnyFetchedResults can be in one file, EntityTextFieldView in another, and the enums in separate files. This will make the codebase more modular and easier to navigate.
//    2.    Documentation: Add comments to describe the purpose and usage of each struct, enum, and view. This will make it easier for other developers to understand and work with the code.
//    3.    UI Enhancements:
//    •    For the EntityTextFieldView, consider adding visual feedback when a user tries to add an entity with an empty name.
//    •    Enhance the UI for displaying suggestions. For instance, highlight the matching text in the suggestions.
//    4.    Error Handling: Add error handling for potential issues, such as failed fetch requests or Core Data operations.
//    5.    Optimization: The filteredEntities computed property in EntityTextFieldView filters entities based on user input. Consider optimizing this filtering process, especially if there’s a large number of entities.
//    6.    Testing: Uncomment and update the SpecializedTextBoxes_Previews section to allow for SwiftUI previews. This will help in visualizing and testing the UI components.
//
//Recommendations:
//
//    1.    ViewModel Integration: Integrate the EntityChipTextFieldViewModel with the EntityChipTextFieldView. Currently, the view model is defined but not used within the view. This will allow you to manage the state and logic of the view more effectively.
//    2.    Error Handling: Add error handling for potential issues, such as failed fetch requests or Core Data operations.
//    3.    Code Organization: Consider breaking this file into multiple smaller files. For instance, EntityChipTextFieldView can be in one file and EntityChipTextFieldViewModel in another. This will make the codebase more modular and easier to navigate.
//    4.    UI Enhancements:
//    •    Provide visual feedback when adding, editing, or deleting chips.
//    •    Enhance the UI for displaying chips, such as adding animations or transitions.
//    5.    Documentation: Add comments to describe the purpose and usage of each view and view model. This will make it easier for other developers to understand and work with the code.
//    6.    Testing: Test the functionality of adding, editing, and deleting chips to ensure that it works as expected and integrates well with the rest of the app.
//
//Recommendations:
//
//    1.    Refactoring for Clarity: The EditBookView contains a lot of logic, especially in the helper functions within the extension. Consider breaking down some of these functions into smaller, more focused functions to improve readability and maintainability.
//    2.    UI Enhancements: The current view provides basic text fields for editing attributes. Consider adding more interactive UI components, such as sliders for the read percentage or pickers for selecting story arcs and events from a list.
//    3.    Validation: Before saving changes, validate the user’s input to ensure that it meets certain criteria. For example, ensure that the issue number is a valid integer and that the read percentage is between 0 and 100.
//    4.    Feedback to Users: Provide feedback to users when they save changes, such as a confirmation message or an error message if there’s an issue with the input.
//    5.    Code Comments: While there are some comments in the code, consider adding more detailed comments to explain the purpose and functionality of specific sections, especially the more complex functions.
//    6.    Preview Section: The preview section for the view is currently commented out. If this is not needed, consider removing it to clean up the code. If it is needed for development purposes, consider uncommenting it and ensuring that it provides a representative preview of the view.
//
//Recommendations:
//
//    1.    Expand Placeholder Views: The BookDetailsLibraryView, BookDetailsDetailsView, and BookDetailsCreativesView are currently placeholders. Consider expanding these views to display relevant information about the book, such as its location in the library, additional details, and the creative team behind it.
//    2.    Enhance UI: Consider adding more interactive UI components, such as image carousels for displaying book covers or interactive charts for showing ratings and reviews.
//    3.    Optimize Data Fetching: In the BookMainDetails view, the storyArcNames computed property fetches story arc names by iterating over the bookStoryArcs relationship. Consider optimizing this logic to reduce the number of iterations and improve performance.
//    4.    Validation & Feedback: Before performing actions like marking a book as read/unread, validate the user’s input and provide feedback, such as confirmation messages or error alerts.
//    5.    Refactor for Reusability: Some components, like BookActionButtons, can be refactored to be more reusable. For instance, the logic for updating the read status of a book can be extracted into a separate function or view model.
//    6.    Code Comments: Consider adding detailed comments to explain the purpose and functionality of specific sections and functions, especially for complex logic.
//    7.    Navigation & User Experience: Enhance the user experience by providing smooth navigation between different sections of book details. Consider adding animations or transitions for a more engaging experience.
//
//Recommendations:
//
//    1.    Separation of Concerns: Ensure that the BookTileModel only contains properties and methods relevant to the representation of a book in a tile format. Any complex business logic or database operations should be handled elsewhere.
//    2.    Optimization: If the model fetches data like images, ensure that it does so efficiently, possibly with caching mechanisms to avoid redundant network calls.
//    3.    Data Binding: If using SwiftUI, consider making the model an ObservableObject to easily bind its properties to UI components and reflect changes in real-time.
//    4.    Error Handling: Implement error handling for any data fetching or updating operations, providing feedback to the user when necessary.
//    5.    Documentation: Add comments to describe the purpose and functionality of the model, making it easier for other developers to understand.
//    6.    Testing: Write unit tests to ensure the model’s properties and methods work as expected, especially if there’s any data transformation or computation involved.
//
//Refactoring and Streamlining:
//
//    1.    ViewModels: Consider introducing view models for each of your main views. These view models can encapsulate the business logic, data fetching, and state management for each view, making the views themselves more focused on UI presentation.
//    2.    Core Data Access: Standardize the way you access Core Data across the app. Create a dedicated class or set of functions that handle all Core Data operations, such as fetching, saving, and deleting entities. This will centralize your data access logic and make it easier to manage and modify.
//    3.    Extensions: Use Swift extensions to group related functionality. For instance, you can create extensions for each NSManagedObject subclass to add computed properties, helper functions, or validation logic.
//    4.    Modularize Views: Break down complex SwiftUI views into smaller, reusable components. This not only improves readability but also allows for better code reuse and easier testing.
//    5.    Placeholder Views: Replace placeholder views with actual implementations or remove them if they’re no longer needed.
//
//Data Access:
//
//    1.    Fetching Data: When fetching data from Core Data, consider using NSFetchedResultsController. It’s optimized for use with SwiftUI and can automatically update your views when the underlying data changes.
//    2.    Data Bindings: Use SwiftUI’s data binding mechanisms, like @Binding, @State, and @ObservedObject, to ensure that your views reflect the latest data and changes are propagated correctly.
//    3.    Singleton Data Manager: Consider creating a singleton class that manages all data access, ensuring that there’s a single source of truth for data operations. This class can provide standardized methods for fetching, saving, and deleting data, reducing redundancy and potential errors.
//    4.    Error Handling: Implement comprehensive error handling for data operations. This includes catching Core Data errors, validating data before saving, and providing user feedback for any issues.
//    5.    Data Relationships: Given the complex relationships between entities in your Core Data model, ensure that you’re setting up inverse relationships correctly. This will help with data integrity and make certain operations, like deleting entities, more straightforward.
//    6.    Orphaned Data: Implement checks to ensure that you don’t have orphaned data in your database. For instance, when deleting a book, check if any related events or story arcs are no longer associated with any books and delete them if necessary.
//
//General Recommendations:
//
//    1.    Testing: Write unit tests for your data access logic, view models, and any other critical parts of your app. This will help catch issues early and ensure that your app behaves as expected.
//    2.    Documentation: Add more detailed comments and documentation throughout your codebase. This will help other developers (or future you) understand the logic and structure of your app.
//    3.    Performance: Regularly profile your app using tools like Xcode’s Instruments to identify and address any performance bottlenecks.
//    4.    UI/UX: Continuously gather feedback on your app’s user interface and experience. Consider implementing user-friendly features like search, filters, and sorting options for lists of books or events.
//    5.    Continuous Integration: If not already in place, set up a CI/CD pipeline for your app. This will automate tasks like building, testing, and deploying your app, ensuring that any changes are automatically tested and validated.
//
//1. NSFetchedResultsController:
//
//NSFetchedResultsController is a controller that you use to manage the results of a Core Data fetch request and display data to the user. It’s especially optimized for use with lists and tables.
//
//Advantages:
//
//    •    Automatic Updates: It can monitor the managed object context for changes and automatically update its results and notify its delegate (usually the UI) of changes.
//    •    Memory Efficiency: It fetches objects only in batches, keeping memory overhead low.
//    •    Sectioning: It can automatically divide fetched results into sections, useful for List or TableView with section headers.
//
//Implementation:
//
//    •    Set up an NSFetchedResultsController with a fetch request.
//    •    Implement its delegate methods to respond to changes in the data.
//    •    Use it in conjunction with SwiftUI views to display data and automatically reflect changes.
//
//2. Data Bindings in SwiftUI:
//
//SwiftUI provides a powerful data-binding mechanism that allows views to stay updated with their underlying data.
//
//    •    @State: A property wrapper that reflects a view’s mutable state. When the state changes, the view re-renders.
//    •    @Binding: Allows a property to be shared between views. It provides a reference to a mutable state.
//    •    @ObservedObject: Used with classes that conform to the ObservableObject protocol. When properties marked with @Published in these classes change, the view re-renders.
//
//Usage:
//
//    •    Use @State for private, view-specific mutable state.
//    •    Use @Binding to allow a child view to modify a property owned by a parent view.
//    •    Use @ObservedObject with view models or other external data sources.
//
//3. Singleton Data Manager:
//
//A Singleton provides a globally accessible, shared instance of a class. For data management, this ensures consistent data access and operations.
//
//Advantages:
//
//    •    Centralized Data Logic: All data operations are in one place, reducing redundancy.
//    •    Consistency: Ensures that all parts of the app access data in the same way.
//
//Implementation:
//
//    •    Create a class with a private initializer.
//    •    Provide a shared static instance of the class.
//    •    Implement methods for data operations (fetch, save, delete).
//
//4. Performance Profiling with Xcode’s Instruments:
//
//Instruments is a powerful tool in Xcode that helps identify performance bottlenecks, memory leaks, and other issues.
//
//Usage:
//
//    •    Launch Instruments from Xcode.
//    •    Choose a template (e.g., Time Profiler, Allocations, Core Data).
//    •    Profile your app and inspect the results to identify issues.
//
//Regularly profiling ensures your app remains performant and helps catch issues early.
//
//5. Continuous Integration (CI/CD):
//
//CI/CD automates the building, testing, and deployment of your app.
//
//Advantages:
//
//    •    Automated Testing: Automatically run tests to catch issues early.
//    •    Consistent Builds: Ensure builds are consistent across different environments.
//    •    Faster Deployment: Automate deployment to beta testers or the App Store.
//
//Implementation:
//
//    •    Use platforms like GitHub Actions, Jenkins, or Travis CI.
//    •    Set up workflows to build, test, and deploy your app.
//    •    Integrate with tools like Fastlane for automated app deployment.
//
//The overall parent view of the app is ContentView. It's ever present as the sidebar navigation for the app.
//
//HomeView is presented to the user when they open the app. It's a quick snapshot of books that they've recently added, been recently reading, have added to favorites and eventually will show recent reading lists.
//
//The view I see being used most is LibraryView. It's accessible from the ContentView, and is set up to take a 'focus' as a means of filtering and displaying books. For example, from the HomeView, a user can choose to see more of their favorite books, and LibraryView is presented, taking the focus from the navigation link, and using it to filter the view to only show favorite books. I did it this way to minimize duplicate code, and save on having to update multiple views in the future that are the same, with the exception of the data being displayed.
//
//From there, a user can tap on a book, and be presented with details of the book (BookDetails.swift). The user can then adjust some of the parameters of the book, like a rating, making it favorite, and marking the book as read/unread. Eventually they will also be able to add the book to a reading list, and access more details from the other tabs in the view.
//
//The user can also edit details of the book from this view, using the edit button, which will present EditBookView. At present, this view is light on the book details being presented. A lot of the information will be edited through text fields, but some will be specialized chip/text field view EntityChipTextFieldView (which combines ChipView and EntityTextFieldView. Through the use of EntityChipTextFieldView, users will be able to add Story Arcs, Events, Creators, Eras and some other details to the book. It's a more visually appealing way for the user to engage and edit the data, instead of a straight up list or text box. Comics are colorful and engaging, and I want to make sure that the app isn't boring overall, while still aligning with Apple's design language.
//
//One thing I've been trying to do is avoid explicitly using an entity name/relationship/attribute in the code - I've been trying to generalize code, and rely on enum to detail properties/declarations. When I add an instance of a view, I may need to define the entity in the properties, but as much as possible, the other properties/declarations should be inferred
//
//Recommendations:
//
//    1.    Ensure that the EntityChipTextFieldView is updated to handle the changes we made in the LibraryView. If it uses similar logic for adding and editing entities, it should be consistent with the changes we made earlier.
//    2.    In the EditBookView, when saving changes, consider adding some user feedback, such as a confirmation message or a loading spinner, to enhance the user experience.
//    3.    Ensure that error handling is consistent across all views. For example, when saving changes in the EditBookView, if there’s an error, consider displaying an alert to the user.
//
//Recommendations:
//
//    1.    Refactoring for Reusability: Some views, like BookMainDetails and BookSecondaryDetails, can potentially be refactored into more generic components if similar patterns are used elsewhere in the app.
//    2.    Error Handling: While there are some error print statements, it might be beneficial to add more comprehensive error handling, especially when dealing with CoreData operations.
//    3.    UI Enhancements: Consider adding animations or transitions for a smoother user experience, especially when switching between tabs or performing actions.
//
//
//Here’s a plan for refactoring:
//
//    1.    Combine Related Structures: The code has multiple structures (Chip, ChipView, EntityTextFieldView, EntityChipTextFieldView) that handle the display and management of chips. We can combine related functionalities to reduce redundancy.
//    2.    ViewModel Refactoring: The EntityChipTextFieldViewModel class can be expanded to handle more of the logic currently present in the views. This will make the views cleaner and more focused on UI.
//    3.    Extensions and Protocols: The code uses extensions and protocols to add functionality to existing types. While this is a good practice, we can further streamline these extensions for clarity.
//    4.    Consolidate Fetch Requests: The code has multiple @FetchRequest properties that fetch data from Core Data. We can consolidate these fetch requests into the ViewModel or a separate data manager.
//    5.    Error Handling: The code has some potential points of failure (e.g., force unwrapping, fatalError calls). We can add better error handling to make the code more robust.
//    6.    UI Enhancements: Some UI properties (like padding, colors, etc.) are hardcoded. We can make these properties more dynamic or configurable.
//    7.    Comments and Documentation: While the code is well-commented, we can add more documentation to explain the purpose and usage of each structure and function.
//
//Given the context you’ve provided, the goal is to create a unified component that combines the functionalities of both ChipUtilities and SpecializedTextBoxes, making the data flow and user interactions more seamless. Here’s a plan:
//
//    1.    Unified Data Model: We’ll start by defining a unified data model that can be used by both the chip view and the text boxes. This will ensure that both components are always in sync and that any updates made in one component are immediately reflected in the other.
//    2.    Integrated UI: Instead of having two separate UI components, we’ll design an integrated UI that allows users to easily add, update, or delete data using the text boxes and immediately see the changes in the chip view.
//    3.    Shared Logic: Any shared logic or functionalities (like filtering, data validation, etc.) will be extracted into shared functions or methods. This ensures that there’s a single source of truth and reduces code duplication.
//    4.    Event Handling: We’ll set up event handlers to ensure that interactions in one component trigger the necessary updates in the other. For example, adding a new item using the text box should immediately create a new chip, and deleting a chip should update any related data in the text boxes.
//    5.    Testing: After integrating the components, we’ll test the unified component to ensure that all functionalities work as expected and that there are no unexpected behaviors or bugs.
//
//Refactoring Plan:
//
//    1.    Unify Enums: We’ll start by unifying the enums to avoid redundancy. The ChipType and TextFieldEntities enums have overlapping functionalities. We can combine them into a single enum that provides all the necessary information.
//    2.    Refactor EntityChipTextFieldView: This view will be the unified component that handles both chips and text fields. It will use the unified enum to determine its behavior.
//    3.    Refactor EditBookView: Update the EditBookView to use the new EntityChipTextFieldView and remove any redundant code.
//    4.    Move Functions to ViewModel: Any function that deals with data manipulation, such as saving changes, should be moved to the EntityChipTextFieldViewModel. This will make the view cleaner and more focused on UI.
//
//At present, the app is only dealing with Events and Story Arcs, but there will be other entities that use this view/function we're building, so cases are not an either or, but one of many. So where your questions ask Events and Story Arcs, it's more encompassing than that, they're just the 2 entities in use right now.
//
//As previously mentioned, I tried to make the code as generalized as possible, relying on enum to provide properties that are specific to entities - they have different attributes and attribute types, that are used in these text boxes. Ideally, when this new code is used, a minimum number of properties/declarations should be used. Maybe the entity, and I guess viewModel. Anything else required is fine, but I would prefer to infer as much as possible, based on the entity
//
//Autocomplete and Suggestions:
//
//How do you envision the autocomplete or suggestion mechanism? Is it a dropdown that appears as the user types? I'm open to best practice suggestions, as well as accessibility considerations. At present, there is a drop down below the text field that shows the 5 closest matches to what the user types. I would love to have the closest match populate inside the text field as they type, so they could use enter to complete it, which seems to be pretty common place. There is also a See All button that presents a sheet that has a list of all of the values available for that specific entity.
//Are there any specific design or user experience considerations for this feature? I'm open to suggestions based on best practice, common use and accessibility.
//
//Adding New Events/Story Arcs:
//
//When a user adds a new Event or StoryArc that doesn't exist, do you want any validation or confirmation before it's added to the database? Yes, I think this is a good idea. It will help reinforce, especially as users first use the app, that there is a database of that entity they can match their book information to, not just text.
//Is there a specific UI flow you have in mind for this process? Presently the user adds them in the EditBookView - but I have considered making part of another view also, where the user can manage these entities.
//
//Editing Existing Events/Story Arcs:
//
//When a user edits the name of an existing Event or StoryArc, should this change be reflected across all books associated with that event or story arc? Yes it should.
//Are there any constraints or validations to consider when editing? If they edit it and it's the same as another value on that entity, they should be asked if they would like to merge with it, otherwise rename it.
//
//Deleting Mechanism:
//
//When removing an Event or StoryArc from a book, do you want a confirmation prompt? Yes please.
//When an Event or StoryArc is no longer associated with any book and is set to be deleted, do you want any notifications or logs to be kept? I think the user should be notified that this was the last use of that value
//
//Orphaned Values:
//
//Are there any specific performance considerations or methods you've thought of to periodically check for orphaned values in the parent entities? Maybe something in the background on app start? Is there any best practice suggestions?
//Would you prefer a manual trigger to clean up orphaned values or an automated process? I think automated is fine.
//
//UI/UX for Entity Management:
//
//How do you envision the user interface for managing these relationships? For instance, when adding an Event to a Book, is it a separate screen, a modal, a dropdown, etc.? At the moment the user manages them in the EditBookView using EntityChipTextFieldView, but I think an 'entity maintenance' view will probably be helpful also.
//Are there any specific design guidelines or aesthetics you're aiming for? I'm trying where possible to comply with Apple iOS/iPadOS design guidelines and aesthetics. I'm open to making things a little more fun or engaging, like comics are, since this is a comic reader app.
//
//Performance and Scalability:
//
//Given that there might be a large number of books, events, and story arcs, are there any specific performance concerns you have, especially when checking for orphaned values or updating relationships? This is an area I'm not familiar with, and would be open to suggestions around best use.
//Are there specific parts of the app where you feel the performance could be improved? Not that I'm aware of. The biggest strain on the app/memory at this stage is importing a large number of books at once.
//
//Error Handling:
//
//How do you want to handle errors, especially when dealing with database operations? For example, if there's an issue adding a new event or deleting a relationship. I think an alert would be useful.
//Do you have a specific method of notifying the user about errors or issues? At present no. I'm happy to have one introduced using best practice and accessibility as a guide.
//
//Backup and Data Integrity:
//
//Do you have any mechanisms in place for backing up the database or ensuring data integrity? Not yet. The user will be able to have their database cloud based.
//Are there any specific scenarios where you're concerned about data loss or corruption? Nothing in particular, especially once the cloud based databases are implemented.
//
//summarize the requirements and considerations for the functionality you’re aiming to implement:
//
//Autocomplete and Suggestions:
//
//    •    Implement a dropdown that shows up to 5 closest matches to the user’s input.
//    •    The closest match should be auto-populated inside the text field, allowing users to press enter to complete it.
//    •    A “See All” button will present a sheet with a list of all available values for the specific entity.
//    •    Ensure the design is in line with best practices, common usage patterns, and accessibility considerations.
//
//Adding New Entities:
//
//    •    When a user adds a new entity (e.g., Event, StoryArc) that doesn’t exist, prompt for validation or confirmation before adding it to the database.
//    •    Consider a separate view for users to manage these entities, in addition to the current EditBookView.
//
//Editing Entities:
//
//    •    Changes to the name of an entity should be reflected across all associated books.
//    •    If a user edits an entity name to match an existing entity, prompt them to either merge with the existing entity or rename their entry.
//
//Deleting Mechanism:
//
//    •    Prompt users for confirmation when removing an entity from a book.
//    •    Notify users when an entity is deleted because it’s no longer associated with any book.
//
//Orphaned Values:
//
//    •    Implement an automated process to check for orphaned values in parent entities, possibly during app startup.
//    •    Ensure the process is efficient to handle large datasets without affecting app performance.
//
//UI/UX for Entity Management:
//
//    •    Continue using the EntityChipTextFieldView in the EditBookView for managing relationships.
//    •    Consider introducing an ‘entity maintenance’ view for better management.
//    •    Design should align with Apple’s guidelines but can have elements that make it more engaging, given the comic reader context.
//
//Performance and Scalability:
//
//    •    Be mindful of performance, especially when importing a large number of books or checking for orphaned values.
//    •    Consider best practices for database operations to ensure smooth performance.
//
//Error Handling:
//
//    •    Introduce alerts to notify users of errors, especially during database operations.
//    •    Ensure error notifications are designed with best practices and accessibility in mind.
//
//Backup and Data Integrity:
//
//    •    Plan for mechanisms to back up the database and ensure data integrity.
//    •    Cloud-based databases will be introduced in the future to mitigate data loss concerns.
//
//Given these requirements, the next steps would involve:
//
//    1.    Designing the database operations to handle the addition, editing, and deletion of entities while maintaining relationships.
//    2.    Implementing the UI/UX enhancements you’ve mentioned.
//    3.    Ensuring error handling and performance optimizations are in place.
//
//A "See All" button will present a sheet with a list of all available values for the specific entity.
//- selecting a value should then add it to the text field for the user.
//When you talk about Editing Entities, I'm making the assumption you mean the records in the entity, and not the actual entity in the Core Data themselves.
//
//Absolutely, let’s address your clarifications first:
//
//    1.    “See All” Button Behavior: When the user selects a value from the “See All” sheet, it should populate the text field with the selected value. This will provide a seamless experience for the user, allowing them to quickly choose from existing values without having to type them out.
//    2.    Editing Entities: Yes, when I mentioned “Editing Entities”, I was referring to the records within the entity, not the structure of the Core Data entities themselves. The structure of the entities (like their attributes and relationships) would typically be defined during the initial design of the database and would only change if there’s a need to modify the database schema.
//
//Now, let’s dive into the guidance:
//
//1. Autocomplete and Suggestions:
//
//    •    Implementation: Use a combination of SwiftUI’s TextField and a List (or ScrollView with VStack) to display the suggestions. As the user types, filter the list of available values to match the input.
//    •    Closest Match: To auto-populate the closest match, you can use string similarity algorithms or simple prefix matching based on your dataset’s size and performance considerations.
//    •    “See All” Button: When this button is pressed, present a modal sheet with a list of all available values. On selecting a value, dismiss the sheet and populate the text field.
//
//2. Adding New Entities:
//
//    •    Validation: Before adding a new entity, check if it already exists in the database. If it does, prompt the user to either select the existing entity or provide a different name.
//    •    Entity Management View: Consider creating a separate SwiftUI view (EntityManagementView) where users can see all entities, add new ones, or delete unused ones. This centralized management can be beneficial as your app grows.
//
//3. Editing Entity Records:
//
//    •    Reflect Changes: When an entity record’s name is changed, update all associated books with the new name.
//    •    Merge or Rename: If a user tries to rename an entity record to a name that already exists, present an action sheet asking if they want to merge the two or provide a different name.
//
//4. Deleting Mechanism:
//
//    •    Confirmation: Use an action sheet or alert to confirm the deletion of an entity from a book.
//    •    Orphaned Values Cleanup: Implement a function that checks for orphaned values in parent entities and deletes them. This can be triggered after any deletion operation or periodically, like during app startup.
//
//5. UI/UX Enhancements:
//
//    •    EntityChipTextFieldView: Continue its use but consider adding animations or visual feedback when adding/removing entities.
//    •    Entity Maintenance View: Design this view with a search bar, list of entities, and options to add or delete. Ensure it aligns with Apple’s design guidelines but has comic-themed elements for engagement.
//
//6. Error Handling:
//
//    •    Alerts: Use SwiftUI’s alert modifier to present error messages to the user. Ensure the messages are clear and provide guidance on how to resolve the issue.
//
//7. Performance and Scalability:
//
//    •    Database Operations: Consider using background threads for intensive database operations to ensure the UI remains responsive. Core Data supports background operations, which can be beneficial for tasks like importing books or cleaning up orphaned values.
//
//8. Backup and Data Integrity:
//
//    •    Cloud Integration: As you plan to introduce cloud-based databases, ensure synchronization mechanisms are in place. This will help in keeping local and cloud data consistent.
//
//Next Steps:
//
//    1.    Design the Database Operations: Define functions for adding, editing, and deleting entity records while maintaining relationships.
//    2.    UI/UX Development: Implement the enhancements and new views discussed above.
//    3.    Testing: Regularly test the app, especially after implementing new features, to ensure data integrity and smooth performance.
//
//
//Let’s design the database operations for the entities, focusing on the primary entity, Book, and its relationships with other entities.
//
//1. Adding a Book:
//
//    •    Create a new Book instance.
//    •    Populate the attributes based on user input.
//    •    Save the Book instance to the Core Data context.
//
//2. Adding Relationships to a Book:
//
//For entities like Event, StoryArc, etc.:
//
//    •    Check if the entity value (e.g., EventName) exists in the database.
//    •    If it exists, fetch the entity instance.
//    •    If it doesn’t exist, create a new entity instance and populate its attributes.
//    •    Check the bridge entity (e.g., BookEvents for Event).
//    •    If a relationship between the Book and the entity (e.g., Event) exists, update the relationship attributes.
//    •    If no relationship exists, create a new bridge entity instance (e.g., BookEvents) and establish the relationship between the Book and the entity.
//    •    Save changes to the Core Data context.
//
//3. Editing a Book or its Relationships:
//
//    •    Fetch the Book instance to be edited.
//    •    Update the Book attributes based on user input.
//    •    For relationships:
//    •    If the user edits a relationship (e.g., changes an Event associated with the Book), update the bridge entity (e.g., BookEvents) accordingly.
//    •    If the user removes a relationship, delete the bridge entity instance (e.g., BookEvents).
//    •    If the user adds a new relationship, follow the steps in point 2.
//    •    Save changes to the Core Data context.
//
//4. Deleting a Book:
//
//    •    Fetch the Book instance to be deleted.
//    •    For each relationship of the Book:
//    •    Delete the bridge entity instances (e.g., BookEvents, BookStoryArcs).
//    •    Check if the related entity (e.g., Event) is orphaned (i.e., not related to any other Book).
//    •    If orphaned, delete the entity instance.
//    •    Delete the Book instance.
//    •    Save changes to the Core Data context.
//
//5. Autocomplete and Suggestions for Relationships:
//
//    •    As the user types in a relationship field (e.g., Event), fetch matching entity values from the database.
//    •    Display the matching values to the user for selection.
//    •    If the user selects an existing value, establish the relationship.
//    •    If the user enters a new value, create a new entity instance and establish the relationship.
//
//6. Handling Orphaned Values:
//
//    •    Periodically (e.g., on app startup or during specific user actions), scan the database for orphaned values in entities like Event, StoryArc, etc.
//    •    Delete any orphaned values found.
//
//7. Backup and Data Integrity:
//
//    •    Implement mechanisms to backup the Core Data database, especially if you plan to introduce cloud-based databases.
//    •    Ensure synchronization mechanisms are in place to keep local and cloud data consistent.
//
//Implementation Tips:
//
//    •    Use Background Contexts: For intensive database operations, use background contexts in Core Data to ensure the UI remains responsive.
//    •    Batch Operations: When dealing with a large number of records, consider using batch insert, update, or delete operations in Core Data.
//    •    Error Handling: Always handle potential errors during database operations, such as failed fetch requests or save operations. Inform the user of any issues.
//
//1. Refactor EntityChipTextFieldView:
//
//    •    Generalize the View: Instead of hardcoding specific entities like Event or StoryArc, use an enum to represent the entity type. This will allow the view to adapt based on the entity it’s dealing with.
//    •    Autocomplete & Suggestions: As the user types, fetch matching entity values from the database and display them. If the user selects an existing value, establish the relationship. If they enter a new value, create a new entity instance and establish the relationship.
//    •    Add & Remove Relationships: Provide UI mechanisms (e.g., buttons or gestures) for users to add or remove relationships. Handle the database operations accordingly.
//
//2. Incorporate SelectedBookViewModel:
//
//    •    Manage Book State: Use the SelectedBookViewModel to manage the state of the currently selected book. This includes its attributes and relationships.
//    •    Database Operations: Implement methods in the view model for adding, updating, and deleting relationships. This ensures that the view remains decoupled from the database operations.
//
//3. Refactor EditBookView:
//
//    •    Attribute Editing: Provide UI elements for users to edit the attributes of the selected book. Use the SelectedBookViewModel to manage changes and save them to the database.
//    •    Relationship Editing: Integrate the refactored EntityChipTextFieldView to allow users to edit relationships. Handle the addition, modification, and removal of relationships using the view model.
//
//4. Handle Orphaned Values:
//
//    •    After any operation that might result in orphaned values (e.g., removing a relationship), check for and delete any orphaned values in the database.
//
//Implementation Tips:
//
//    •    Use Bindings: Utilize SwiftUI’s data binding to ensure that the views reflect the current state of the SelectedBookViewModel.
//    •    Optimize Database Fetches: When implementing autocomplete and suggestions, consider optimizing database fetches to ensure performance, especially if there are a large number of records.
//
//Do you have any specific design or UI changes in mind for the refactored views? Trying to stick to Apple design practice. At present I'm using a form for editing the attributes, and incorporating EntityChipTextFieldView for relationships.
//Would you like to start with code examples for refactoring a specific view or the view model? I think we should start with the view, and update the view model as we encounter the need to move code to it, or to add functionality that can live within it.
//Are there any other specific requirements or considerations you'd like to address during this refactoring process? Let's try not to lose anything we want to keep ;)
//
//1. EntityChipTextFieldView Refactoring:
//
//    •    ViewModel Integration: Instead of using @State properties for attributes, we should use the EntityChipTextFieldViewModel to manage the state. This will make the view more declarative and less stateful.
//    •    Generic Entity Fetch: Instead of having separate @FetchRequest for each entity type, we can make it more generic. This will reduce redundancy and make the code more maintainable.
//    •    View Decomposition: The body of the EntityChipTextFieldView can be decomposed into smaller views. This will make the code more readable and modular.
//
//2. ChipView Refactoring:
//
//    •    RowView Decomposition: The RowView function inside ChipView can be extracted as a separate view. This will make the ChipView more concise.
//    •    Chip Creation Logic: The logic to create a chip label based on tempValue1 and tempValue2 can be moved to a utility function or the ViewModel.
//
//3. EntityTextFieldView Refactoring:
//
//    •    Filtered Entities Logic: The logic to filter entities based on the current input can be moved to the ViewModel. This will make the view more declarative.
//    •    Sheet Presentation: Instead of presenting a sheet directly from the EntityTextFieldView, consider using a callback or delegate pattern. This will make the view more reusable and less dependent on specific UI actions.
//
//4. General Refactoring:
//
//    •    Naming: As you mentioned, EntityChipTextFieldView can be renamed to something more concise and descriptive. Maybe something like EntityInputView.
//    •    Enums and Utility Functions: Consider creating utility functions or extensions for repetitive tasks, like fetching entity names or creating chip labels.
//    •    Apple Design Practices: Ensure that the UI components adhere to Apple’s design guidelines. This includes using system fonts, adhering to recommended padding/margins, and ensuring that interactive elements have appropriate touch targets.
//
//Next Steps:
//
//    1.    Refactor EntityChipTextFieldView: Let’s start with this view. We’ll integrate the ViewModel, make the entity fetch generic, and decompose the view.
//    2.    Refactor ChipView and EntityTextFieldView: After refactoring the main view, we’ll move on to these components.
//    3.    General Refactoring: Address naming, utility functions, and design practices.
//
//we can aim to consolidate the functionality into a more cohesive and modular structure. Let’s start by merging the functionalities of EntityTextFieldView and ChipUtilities into a single, more streamlined view. We’ll call this consolidated view EntityInputView
//
//Yes, you can utilize the SelectedBookViewModel within the ChipView to manage the edited attributes. Here’s how you can integrate it:
//
//    1.    Inject the ViewModel into ChipView: You can pass the SelectedBookViewModel instance to ChipView when you instantiate it.
//    2.    Update Attributes: Inside the onTapGesture of the RowView function in ChipView, you can call the updateEditedAttributes(for:) method to update the edited attributes based on the tapped chip.
//    3.    Retrieve Attributes: Whenever you need to retrieve the edited attributes within ChipView, you can directly access the properties of the ViewModel.

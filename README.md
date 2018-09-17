Students will build a simple journal app to practice MVC separation, protocols, master-detail interfaces, table views, and persistence using CloudKit.

Journal is an excellent app to practice basic C.R.U.D functions using CloudKit

Students who complete this project independently are able to:

**Part One - Model Objects and Controllers**

* Create a custom model object with a memberwise initializer and an initializer that takes in a CKRecord
* In the initializer that takes in a CKRecord, use the key-value pairs from the CKRecord to create the entries properties as you would a dictionary
* Add property for the CKRecordID
* Add an extension on CKRecord that initializes an instance of CKRecord with your custom model object. Here is where you set the key-value pairs.
* Understand, create, and use a shared instance
* Create a model object controller with create, read, update, and delete functions

**Part Two - User Interface**

* Implement a master-detail interface
* Implement the `UITableViewDataSource` protocol
* Understand and implement the `UITextFieldDelegate` protocol to dismiss the keyboard
* Create relationship segues in Storyboards
* Understand, use, and implement the 'updateViews' pattern
* Implement 'prepare(for segue: UIStoryboardSegue, sender: Any?)' to configure destination view controllers

**Part Three - Controller Implementation**

* Add data persistence using CloudKit, managing CKRecords and Model Objects.
* Upon launch, fetch the CKRecords from the private database and turn those records into your model object.

**Part One - Model Objects and Controllers**
_Before you begin make sure you have enabled iCloud in your apps Cababilities settings, unchecked the "key-value storage" setting and checked "CloudKit" setting.  It may take sometime for a new CKContainer to appear in the CloudKit dashboard so its important you complete this step first._

**Entry**

Create an Entry model class that will hold title, text, and ckRecordID properties for each entry.

1\. Add a new `Entry.swift` file and define a new `Entry` class
3\. Import `CloudKit`
3\. Add properties for , title, body text and and ckRecordID of type `CKRecordID` or `CKRecord.ID` as of Swift 4.2
4\. Add a memberwise initializer that takes parameters for each property.  Give the CkRecordID you pass in a default parameter value of `CKRecord.ID(recordName: UUID().uuidString))`.
*_This will allow you to refer back to entry objects CKRecord without an optional CKRecordID.
5\. Add a failable convenience initializer that takes in only a `CKRecord` 
6\. Look up the documentation for `CKRecord`. Notice it acts as a dictionary.
7\. Get the value from your properties keys. Typically the value will be the string version of your property names. Its a good idea to create a set of constants outside of your class to make sure these keys stay uniform.

```swift
struct Constants{
        static let titleKey = "Title"
        static let bodyKey = "Body"
    }
```

* You can then use these keys to pull values out of the CKRecord coming from your convenience initalizer.
* You will need to cast these properties as `Strings` as you unwrap them at the beginning of your conveniece initializer.  See the example below for reference.

```swift
 guard let title = ckRecord[Constants.titleKey] as? String else {return nil}
```

Add an extension to `CKRecord` and then create a convenience initializer

1\. In an Extension on `CKRecord` Create a convenience initializer that takes in an Entry as it's only parameter 
2\. Call the designated initializer of the `CKRecord`.  The record type is going to be a string representation of your model object ("Entry").  Add this as a third static property to your `Constants` struct.

`self.init(recordType: Constants.recordKey)`

4\. The record ID is going to be the `ckRecordID` property on the entry object your initializer takes in as a parameter
5\. This is where you set the key-value pairs for the `CKRecord`
6\. After the designated initializer, you can call self.setValue(value: forKey:) (The key is going to be a string representation of your property from your `Constants` struct, the value is going to be the entry parameter's value).  For example:

```swift
self.setValue(entry.title, forKey: Constants.titleKey)
```

**EntryController**

Create a model object controller called `EntryController` that will manage adding, reading, updating, and removing entries. We will follow the shared instance design pattern because we want one consistent source of truth for our entry objects that are held on the controller.

1\. Add a new `EntryController.swift` file and define a new `EntryController` class inside.
2\. Add an entries array property, and set its value to an empty array

**Save**

1\. Create a `save(entry: ...)` function that takes in an `entry`, and `completion: @escaping (Bool) -> ()` that will take in an entry, and save it to the private database
2\. Turn your entry into a `CKRecord` (Using the convenience initializer we used on `CKRecord`)
3\. Access your private database using the CKContainer and then call the save method 

```swift
CKContainer.default().privateCloudDatabase.save(record: CKRecord, completionHandler:(CKRecord?, Error?) -> Void)
```

4\. Handle the error that this function may complete with and pass `false` into the completion.  If you successfully saved your record, unwrap it and call the convenience initalizer to create an entry from the record.  Append this newly initalized entry to your entries array. Finally, call completion and pass in `true`.
*_This process of initalizing another entry from our record may seem redundant, but it ensures the data in CloudKit will match what the user sees locally (i.e. if the record fails to save for some reason, it will not show up on the users phone)._

**Create**

1\. Create a `addEntryWith(title: ...)` function that takes in a `title`, and `body`, and `completion: @escaping (Bool) -> Void` creates a new instance of `Entry`, and adds it to the entries array
2\. Using the `title` and `text properties`, create a new Entry with it's memberwise initializers.
3\. With the Entry you just created, call your `save(entry:completion:)` method created earlier
4\. In the completion handler of the the `save(entry:completion:)`, if you were able to successfully save it to CloudKit, call `completion(true)`. If not, call `completion(false)`

**Fetch**

1\. Create a `fetchEntries(completion: @escaping (Bool)->())` function that only has a completion handler. This will fetch all the entries in your private database.
2\. In order to perform a query to the private databse, you will need to create a `CKQuery`. 
3\. A `CKQuery` takes in two parameters, `recordType: String` and `predicate: NSPredicate` The recordType will be a the string representation of our CKRecord. You can call this string off of the static property in your `Constants` struct. 
4\. `NSPredicate` is a definition of logical conditions (true false) used to constrain a search either for a fetch or for in-memory filtering. For this project we want to get all entries back from the private database, so we will be using the initializer that takes in a value, and we will be setting that value to `true` This tells the predicate to just return everything.
5\. Now call `CKContainer.default().privateCloudDatabase.perform(query: inZoneWith: completionHandler:)`. Plug in your `CKQuery` for the query, and `nil` for inZoneWith. In smaller apps you typically will keep this value nil. 
6\. The completionHandler gives us an optional error and an optional array of `CKRecords`s. Check for error, and if there is an error, call `completion(false)` and return
7\. Unwrap your array of records, and if it's nil. call `completion(false)` and return
8\. Now that you have an array of `CKRecords`, you can loop through the array and attempt to initialize an `Entry` with them. We are able to do this because we created a the failable initializer in the Model that takes in a `CKRecord`
* You might want to create an empty `Entry` array above the loop that you can append the entries to. 
9\. After the loop, you can set `self.entries` to equal your array you created. Call `completion(true)`

_Black Diamonds_

_*Implement the Equatable protocol for the Entry class_
_*Write a function which allows you to delete entries locally and in CloudKit.  You will need to call the delete method on your private database._
_*Write a function which allows you to modify entries in locally and in Cloudkit.  Hint: You will need to use the `CKModifiyRecordsOperation` class.  [Documenation](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)
Second Hint: This might be on your test_

**Part Two - User Interface**

Master List View

Build a view that lists all journal entries. You will use a UITableViewController and implement the UITableViewDataSource functions.

You will want this view to reload the table view each time it appears in order to display newly created entries.

1\. Add a UITableViewController as your root view controller in Main.storyboard and embed it into a UINavigationController
2\. Create an `EntryListTableViewController` file as a subclass of UITableViewController and set the class of your root view controller scene
3\. Implement the UITableViewDataSource functions using the EntryController `entries` array
* Pay attention to your `reuseIdentifier` in the Storyboard scene and your `dequeueReusableCell(withIdentifier:for:)` function call
4\. Set up your cells to display the title of the entry
5\. Add a UIBarButtonItem to the UINavigationBar with the plus symbol
* Select 'Add' in the System Item menu from the Identity Inspector to set the button as a plus symbol, these are system bar button items, and include localization and other benefits

6\. Call the `fetchEntries` function from your `EntryController` in the `ViewDidLoad` of the tableview controller.  In the completion block for `fetchEntries` call `self.tableView.reloadData()`

**Detail View**

Build a view that provides editing and view functionality for a single entry. You will use a UITextField to capture the title, a UITextView to capture the body, a UIBarButtonItem to save the new or updated entry, and a UIButton to clear the title and body text areas.

Your Detail View should follow the 'updateViews' pattern for updating the view elements with the details of a model object. To follow this pattern, the developer adds an 'updateViews' function that checks for a model object. The function updates the view with details from the model object.

1\. Add an `EntryDetailViewController` file as a subclass of UIViewController and an optional `entry` property to the class
2\. Add a UIViewController scene to Main.storyboard and set the class to `EntryDetailViewController`
3\. Add a UITextField for the entry's title text to the top of the scene, add an outlet to the class file called `titleTextField`, and set the delegate relationship
(*To set the delegate relationship control drag from the UITextField to the current view controller in the scene dock or call `myTextField.delegate = self` in the view controller `ViewDidLoad` functions*)
4\. Implement the delegate function `textFieldShouldReturn` to resign first responder to dismiss the keyboard
(\*Before you implement the delegate function be sure to adopt the UITextFieldDelegate protocol\*)
5\. Add a UITextView for the entry's body text beneath the title text field and add an outlet to the class file `bodyTextView`.
6\. Add a UIButton beneath the body text view and add an IBAction to the class file that clears the text in the titleTextField and bodyTextView.
7\. Add a UIBarButtonItem to the UINavigationBar as a `Save` System Item and add an IBAction to the class file called `saveButtonTapped`
(\*You may need to add a segue from `EntryListTableViewController` to see a UINavigationBar on the detail view, and a UINavigationItem to add the UIBarButtonItem to the UINavigationBar, this will be covered in the next section\*)
9\. Add an `updateViews()` function that checks if the optional `entry` property holds an entry. If it does, implement the function to update all view elements that reflect details about the model object `entry` (in this case, the titleTextField and bodyTextView)
10\. Update the `viewDidLoad()` function to call `updateViews()`

**Segue**

You will add two separate segues from the List View to the Detail View. The segue from the plus button will tell the EntryDetailViewController that it should create a new entry. The segue from a selected cell will tell the EntryDetailViewController that it should display a previously created entry, and save any changes to the same.

1\. Add a 'show' segue from the Add button to the EntryDetailViewController scene and give the segue an identifier
(\*When naming the identifier, consider that this segue will be used to add an entry\*)
2\. Add a 'show' segue from the table view cell to the EntryDetailViewController scene and give the segue an identifier
(\*When naming the identifier, consider that this segue will be used to edit an entry\*)
3\. Add a `prepare(for segue: UIStoryboardSegue, sender: Any?)` function to the EntryListTableViewController
4\. Implement the `prepare(for segue: UIStoryboardSegue, sender: Any?)` function. If the identifier is 'toShowEntry' we will pass the selected entry to the DetailViewController, which will call our `updateViews()` function
* You will need to capture the selected entry by using the indexPath of the selected cell
* Remember that the `updateViews()` function will update the destination view controller with the entry details
* Since we aren't passing an entry if the identifier is 'toAddEntry' we don't need to account for this in our `prepare(for segue: UIStoryboardSegue, sender: Any?)`

**Black Diamonds**

* Add swipe to delete functionality which removes entries locally and from CloudKit.
* In the detail view controller, when the save button is tapped, check to see if an entry exists.  If it does, update the entry locally and in CloudKit.  If it does not, create a new entry
* Add a `CKSubscription` that sends an alert when an entry is added

Your app should now function properly. Run the app and test for bugs.
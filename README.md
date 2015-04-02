# Rounded Robot

[![CI Status](http://img.shields.io/travis/Brian Weinreich/RoundedRobot.svg?style=flat)](https://travis-ci.org/Brian Weinreich/RoundedRobot)
[![Version](https://img.shields.io/cocoapods/v/RoundedRobot.svg?style=flat)](http://cocoapods.org/pods/RoundedRobot)
[![License](https://img.shields.io/cocoapods/l/RoundedRobot.svg?style=flat)](http://cocoapods.org/pods/RoundedRobot)
[![Platform](https://img.shields.io/cocoapods/p/RoundedRobot.svg?style=flat)](http://cocoapods.org/pods/RoundedRobot)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 7 or greater

## Installation

RObot is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RoundedRobot"
```

## How to use

RObot a Swift library is built off of [Alamofire](https://github.com/Alamofire/Alamofire) that handles CRUD methods for `NSManagedObjects`. 

To begin, call this line:

    ROBotManager.initialize(YOUR_BASE_URL, token: YOUR_AUTH_TOKEN)

Then, subclass your `NSManagedObject` from `ROBotManagedObect`:

  	@objc(User)
  	class User: ROBotManagedObject {

and override the CRUD API endpoints:

  	override func createUrl() -> String {
    	return "/users"
  	}

  	override func readUrl() -> String {
    	return "/users/me"
  	}

	override func updateUrl() -> String {
   		return "/users/\(id)"
	}

    override func deleteUrl() -> String {
      return "/users/\(id)"
    }

Note that the url path are instance methods, and will populate the variables in the url string when the url methods is called.

The class will look as follows:

  	@objc(User)
  	class User: ROBotManagedObject {

  	@NSManaged var email: String
  	@NSManaged var first_name: String
  	@NSManaged var id: NSNumber
  	@NSManaged var last_name: String
  	@NSManaged var password: String

  	override func createUrl() -> String {
    	return "/users"
  	}

  	override func readUrl() -> String {
    	return "/users/me"
  	}

  	override func updateUrl() -> String {
    	return "/users/\(id)"
  	}

  	override func deleteUrl() -> String {
    	return "/users/\(id)"
  	}

  	}

You can then call CRUD methods on the instances of the model, and the changes will be made to your database and API. 

Create Example:

  	let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext:     managedObjectContext!) as User
  	user.first_name = "Heather"
  	user.last_name = "Sneps"
  	user.email = "test@roundedco.com"
  	user.password = "11111111"

  	// Save the user to db and upload to server
  	user.create()


Update Example:

  	var fetchRequest = NSFetchRequest(entityName: "User")
  	fetchRequest.predicate = NSPredicate(format: "first_name = Heather")
  	var users = managedObjectContext!.executeFetchRequest(fetchRequest, error: err) as [User]

  	var user = users[0] as User
  	user.first_name = "Jane"

  	// Update the user to db and upload the server
  	user.update()

**Read and Delete methods are similar**


## Customization

You can specify a custom mapping from the API response to the database object. If you don't specify a mapping, RObot will map the results from the API directly to the corresponding fields in your database.

To specify a mapping, do the following:

  	User.mapping = ["last_name": "lname", "first_name": "fname"]

Note that a partial mapping can be used. In the case above, the email will still map to email.

## Logging

By default, logging is disabled. To enable logging for all your `ROBotManagedObjects`, use 

  	ROBotManagedObject.verboseLogging = true

to enable logging for a single `ROBotManagedObject` class, use

  User.verboseLogging = true

## Coming soon
We're working on the following:

1. an index route that will return an array of the objects
2. caching of objects when user doesn't have connection
3. Success/fail callbacks for create()/read()/update()/delete() methods

A major limitation for 1 and 2 is the lack of static variables allowed in Swift.


Feel free to submit a pull request and add your own contributions!



## Author

Heather Snepenger, hs@roundedco.com

## License

RObot is available under the MIT license. See the LICENSE file for more info.
# HomeAway Coding Challenge
## Architecture
Every app has the following components:
* View (UIView, UIViewController, etc)
* Data storage (Data model, UserDefaults, CoreData, etc)
* Service (Networking, external services, etc)
* Business logic (Code that makes your app unique)

On a high level, this is how I structure my app. Inside the project, you will find the following directories:
* Views
* View Models (Business logic)
* Data (Data storage)
* API (Service)
* Utility (constants and convenience methods for DRY)

## Building views
My experiences and preferences are using Autolayout to build the entire views programmatically. This gives me the access and full control of the source code. It's also easier to debug and collaborate and resolve conflicts with other engineers.

## Frameworks/Libraries
* URLSession for networking
* Decodable for data serialization
* UserDefaults for lightweight data storage that doesn't need to be secured (password, etc)
* Autolayout for building views
* I didn't use any third-party libraries because:
  1. Honestly it's something I need to get better at. At my previous job, we have a team dedicated to adopting and building libraries for other feature engineers like me to use. Most of times I built things using our internal libraries that were built on top of Apple's or third-party libraries.
  2. I like to learn to build things the native way first so I can learn and understand the advantages and disadvantages before I adopt a third-party library.
  3. Apple's frameworks are always getting better, hence the need to use third-party libraries can change over time.

## Testing
I have unit tests for most critical logic components. I would add UI tests if I have more time.

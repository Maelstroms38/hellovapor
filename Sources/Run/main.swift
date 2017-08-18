import App

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"
import LeafProvider
import PostgreSQLProvider

let config = try Config()
try config.setup()
try config.addProvider(LeafProvider.Provider.self)
try config.addProvider(PostgreSQLProvider.Provider.self)
let drop = try Droplet(config)
try drop.setup()
try drop.run()

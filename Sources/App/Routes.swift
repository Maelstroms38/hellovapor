import Vapor
import PostgreSQLProvider
import Node

final class MyContext: Context {
}

let myContext = MyContext()

extension Context {
    var isMyContext: Bool {
        return self is MyContext
    }
}

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("yo") { req in
            return try self.view.make("yo", Node(node: ["name": "Michael"]))
        }
        
        get("version") { request in
            let postgresqlDriver = try self.postgresql()
            let version = try postgresqlDriver.raw("SELECT version()")
            return JSON(node: version)
        }
        
        get("model") { request in
            let acronym = Acronym(short: "LOL", long: "Laugh out loud")
            return try acronym.makeJSON()
        }
        get("modelTest") { request in
            let acronym = Acronym(short: "AFK", long: "All Four Kegs")
            try acronym.save()
            return try JSON(node: Acronym.all()) //.makeNode(in: Context.self as? Context)
        }
        
        post("new") { request in
            print(request)
            let acronym = try Acronym(node: request.json.makeNode(in: myContext), context: myContext)
            try acronym.save()
            return acronym
        }
        get("all") { request in
            return try JSON(node: Acronym.all().makeNode(in: myContext))
        }
        get("first") { request in
            return try JSON(node: Acronym.makeQuery().first().makeNode(in: myContext))
        }
        get("filterAFK") { request in
            return try JSON(node: Acronym.makeQuery().filter("short", "AFK").all().makeNode(in: myContext))
        }
        get("filternotAFK") { request in
            return try JSON(node: Acronym.makeQuery().filter("short", .notEquals, "AFK").all().makeNode(in: myContext))
        }

        get("update") { request in
            guard let first = try Acronym.makeQuery().first(),
                let long = request.data["long"]?.string else {
                    throw Abort.badRequest
            }
            first.long = long
            try first.save()
            return first
        }
        get("delete") { request in
            let query = try Acronym.makeQuery().filter("short", "AFK")
            try query.delete()
            return try JSON(node: Acronym.all().makeNode(in: myContext))
        }
        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}

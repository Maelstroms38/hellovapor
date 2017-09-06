//
//  User.swift
//  HelloVapor
//
//  Created by Michael Stromer on 8/23/17.
//
//

import Vapor
import FluentProvider
import VaporValidation

final class User: Model, NodeRepresentable, JSONRepresentable, ResponseRepresentable {
    
    let storage = Storage()
    
    /// When using a different name than the class/struct name
    static var entity = "user"
    /// Set to true if the model is retrieved from database
    var exists: Bool = false
    // Needed for conforming to Model
    var id: Node
    /// User name with validator
    var name: String
    /// email with validator
    var email: String
    /// password with validator
    var password: String
    
    
    /// Default initializer
    init(name: String, email: String, password: String) throws {
        self.id = nil
        self.name = name
        self.email = email
        self.password = password //make hashable
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.get("id")
        let nameString = try node.get("name") as String
        let validName = nameString.passes(OnlyAlphanumeric())
        if validName {
            name = nameString
        } else {
            name = ""
        }
        let emailString = try node.get("email") as String
        let validEmail = emailString.passes(EmailValidator())
        if validEmail {
            email = emailString
        } else {
            email = ""
        }
        let passwordString = try node.get("password") as String
        password = passwordString
    }
    
    init(row: Row) throws {
        self.id = try row.get("id")
        self.name = try row.get("name")
        self.email = try row.get("email")
        self.password = try row.get("password")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", self.id)
        try row.set("name", self.name)
        try row.set("email", self.email)
        try row.set("password", self.email)
        return row
    }
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name" : name,
            "email": email,
            "password": password
            ])
        
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("email", email)
        try json.set("password", password)
        return json
    }
    func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
    func register(name: String, email: String, password: String) throws -> User {
        let newb = try User(name: name, email: email, password: password)
        if try User.makeQuery().filter("email", newb.email).first() == nil {
            try newb.save()
            return newb
        } else {
            //TODO - Handle account taken error
            throw Abort.badRequest
        }
    }
}

/// Extension to get all Acronyms for certain user
extension User {
    var children: Children<User, Acronym> {
        return children()
    }
    func acronyms() throws -> [Acronym] {
       return try self.children.all()
    }
}
extension User: Preparation {
    /// Creates the database based on the name and fields passed
    public static func prepare(_ database: Database ) throws {
        try database.create(self) { userDef in
            // Column id will take the default  model definition
            userDef.id()
            // Column ** name ** will be of type String -> Char or varchar in
            // SQL creation
            userDef.string("name")
            // Column ** email ** will be of type String -> Char or varchar in
            // SQL creation
            userDef.string("email")
            // Column ** password ** will be of type String -> Char or varchar in
            // SQL creation
            userDef.string("password")
        }
    }
    
    /// Defines the drop database
    static func revert(_ database: Database ) throws {
        try database.delete(self)
    }
}

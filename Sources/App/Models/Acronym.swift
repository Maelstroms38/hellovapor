//
//  Acronym.swift
//  HelloVapor
//
//  Created by Michael Stromer on 8/18/17.
//
//
import Vapor
import FluentProvider

final class Acronym: NodeRepresentable, JSONRepresentable, Model, ResponseRepresentable {
    
    let storage = Storage()
    
    var id: Node
    var exists: Bool = false
    
    var short: String
    var long: String
    
    var userID: Identifier
    
    var owner: Parent<Acronym, User> {
        return parent(id: userID)
    }
    
    init(short: String, long: String, userID: Identifier = nil) {
        self.id = nil
        self.short = short
        self.long = long
        self.userID = userID
    }
    init(node: Node, context: Context) throws {
        id = try node.get("id")
        short = try node.get("short")
        long = try node.get("long")
        userID = try node.get("user_id")
    }
    init(row: Row) throws {
        self.id = try row.get("id")
        self.short = try row.get("short")
        self.long = try row.get("long")
        self.userID = try row.get("user_id")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("short", self.short)
        try row.set("long", self.long)
        try row.set("user_id", self.userID)
        return row
    }
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id,
            "short": short,
            "long": long,
            "user_id": userID
        ])
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("short", short)
        try json.set("long", long)
        try json.set("user_id", userID)
        return json
    }
    func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
    func user() throws -> User? {
        return try owner.get()
    }
}
// MARK: Fluent Preparation

extension Acronym: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("short")
            builder.string("long")
            builder.string("user_id")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

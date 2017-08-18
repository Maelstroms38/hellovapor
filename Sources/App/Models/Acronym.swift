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
    
    var id: Node?
    var exists: Bool = false
    
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.id = nil
        self.short = short
        self.long = long
    }
    init(node: Node, context: Context) throws {
        id = try node.get("id")
        short = try node.get("short")
        long = try node.get("long")
    }
    init(row: Row) throws {
        self.short = try row.get("short")
        self.long = try row.get("long")
    }
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("short", self.short)
        try row.set("long", self.long)
        return row
    }
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id ?? 0,
            "short": short,
            "long": long
        ])
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("short", short)
        try json.set("long", long)
        return json
    }
    func makeResponse() throws -> Response {
        return try makeJSON().makeResponse()
    }
}
// MARK: Fluent Preparation

extension Acronym: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("short")
            builder.string("long")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

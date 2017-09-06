//
//  UserController.swift
//  HelloVapor
//
//  Created by Michael Stromer on 8/23/17.
//
//

import Vapor
import HTTP

final class UserController {
    
    private let droplet: Droplet
    
    var context: Context?
    
    init(droplet: Droplet) {
        self.droplet = droplet
    }
    func addRoutes() {
        let basic = droplet.grouped("users")
        basic.get(handler: index)
        basic.post(handler: create)
        basic.delete(User.parameter, handler: delete)
        basic.get(User.parameter, "acronyms", handler: acronymIndex)
        
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: User.all().makeNode(in: context))
    }
    
    /// POST a new JSON containing the user
    func create(request: Request) throws -> ResponseRepresentable {
        //let user = try request.parameters.next(User.self)
        guard let name = request.data["name"]?.string else { throw Abort.badRequest }
        guard let email = request.data["email"]?.string else { throw Abort.badRequest }
        guard let password = request.data["password"]?.string else { throw Abort.badRequest }
        let user = try User(name: name, email: email, password: password)
        try user.save()
        return try user.makeResponse()
    }
    
    /// Searches through the database by acronym.id,
    /// the one passed in url path
    /// It basically does this : ** GET users/:id **
    /// ``swift
    /// func finduserById(request: Request, userID: Int) throws -> ResponseRepresentable {
    /// guard let user = try User.find(userID) else {
    /// throw Abort.notFound
    ///}
    /// ``
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        /// That's why we return the directly retrieved user
        return try JSON(node: [
            "user" : user.name,
            "email" : user.email,
            "id" : user.id
            ])
    }
    
    /// List The Acronymns For A particular User
    func acronymIndex(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(User.self)
        let children = try user.acronyms()
        return try JSON(node: children.makeNode(in: context))
    }
    
    
    /// Pay attention as it issues a PATCH not a PUT
    /// ** PATCH users/:id **
    func update(request: Request, user: User) throws -> ResponseRepresentable  {
        ///Get the updates
        let new = try request.user()
        /// Get the user to be updated ** see show **
        let user = user
        user.name = new.name
        user.email = new.email
        user.password = new.password
        try user.save()
        return try user.makeResponse()
    }
    
    func delete(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(User.self)
        try user.delete()
        return JSON([:])
    }
}

/// Useful for convertiong the request to an User
extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(node: json.makeNode(in: myContext), in: myContext)
    }
}

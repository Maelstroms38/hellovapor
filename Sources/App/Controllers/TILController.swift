//
//  TILController.swift
//  HelloVapor
//
//  Created by Michael Stromer on 8/19/17.
//
//

import Foundation
import Vapor
import HTTP

final class TILController {
    
    var drop: Droplet?
    var context: Context?
    
    func addRoutes(drop: Droplet) {
        self.drop = drop
        drop.get("til", handler: indexView)
        drop.post("til", handler: addAcronym)
        drop.post("til", Acronym.parameter, "delete", handler: delete)
        drop.get("register", handler: registerView)
        drop.post("register", handler: register)
        
    }
    func indexView(request: Request) throws -> ResponseRepresentable {
        let acronyms = try Acronym.all().makeNode(in: context)
        let params = try Node(node: [
            "acronyms": acronyms,
        ])
        guard let drop = self.drop else { throw Abort.badRequest }
        return try drop.view.make("index", params)
    }
    func addAcronym(request: Request) throws -> ResponseRepresentable {
        guard let short = request.data["short"]?.string else { throw Abort.badRequest }
        guard let long = request.data["long"]?.string else { throw Abort.badRequest }
        //guard let id = request.data["user_id"]?.int else { throw Abort.badRequest }
        let acronym = Acronym(short: short, long: long) //, userID: Identifier(id)
        try acronym.save()
        return try indexView(request: request)
        
    }
    func delete(request: Request) throws -> ResponseRepresentable {
        let acronym = try request.parameters.next(Acronym.self)
        try acronym.delete()
        return try self.indexView(request: request)
    }
    func registerView(request: Request) throws -> ResponseRepresentable {
        guard let drop = self.drop else { throw Abort.badRequest }
        return try drop.view.make("register")
    }
    func register(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let name = request.formURLEncoded?["name"]?.string,
            let password = request.formURLEncoded?["password"]?.string else {
                return "Missing Email, Password or Name"
        }
        let user = try User(name: name, email: email, password: password)
        _ = try user.register(name: user.name, email: user.email, password: user.password)
        return Response(redirect: "/users")
    }
    
    
}

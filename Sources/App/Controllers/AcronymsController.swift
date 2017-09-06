//
//  AcronymsController.swift
//  HelloVapor
//
//  Created by Michael Stromer on 8/19/17.
//
//

import Foundation
import Vapor
import HTTP

final class AcronymsController {
   
    private let droplet: Droplet
    
    var context: Context?
    
    init(droplet: Droplet) {
        self.droplet = droplet
    }
    func addRoutes() {
        let basic = droplet.grouped("acronyms")
        basic.get(handler: index)
        basic.get(Acronym.parameter, handler: show)
        basic.post(handler: create)
        basic.delete(Acronym.parameter, handler: delete)
        basic.patch(Acronym.parameter, handler: update)
        basic.get(Acronym.parameter, "user", handler: showUser)
        
    }
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Acronym.all().makeJSON())
    }
    func create(_ request: Request) throws -> ResponseRepresentable {
        let acronym = try request.parameters.next(Acronym.self)
        try acronym.save()
        return acronym
    }
    func show(request: Request) throws -> ResponseRepresentable {
        let acronym = try request.parameters.next(Acronym.self)
        return acronym
    }
    func update(request: Request) throws -> ResponseRepresentable {
        let newAcronym = try request.acronym()
        let acro = try request.parameters.next(Acronym.self)
        acro.short = newAcronym.short
        acro.long = newAcronym.long
        try acro.save()
        return acro
    }
    func delete(request: Request) throws -> ResponseRepresentable {
        let acronym = try request.parameters.next(Acronym.self)
        try acronym.delete()
        return JSON([:])
    }
    func showUser(request: Request) throws -> ResponseRepresentable {
        let acronym = try request.parameters.next(Acronym.self)
        let user = acronym.user //owner.get()
        guard let json = try user.get()?.makeJSON() else {throw Abort.badRequest}
        return JSON(json: json)
    }
    
}

extension Request {
    func acronym() throws -> Acronym {
        guard let json = json else { throw Abort.badRequest }
        return try Acronym(node: json.makeNode(in: myContext), context: myContext)
    }
}

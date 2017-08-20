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

final class AcronymsController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Acronym.all().makeJSON())
    }
    func makeResource() -> Resource<Acronym> {
        return Resource(
            index: index,
            store: create,
            show: show,
            destroy: delete
        )
    }
    func create(_ request: Request) throws -> ResponseRepresentable {
        let acronym = try request.acronym()
        try acronym.save()
        return acronym
    }
    func show(request: Request, acronym: Acronym) throws -> ResponseRepresentable {
        return acronym
    }
    func update(request: Request, acronym: Acronym) throws -> ResponseRepresentable {
        let newAcronym = try request.acronym()
        let acro = acronym
        acro.short = newAcronym.short
        acro.long = newAcronym.long
        try acro.save()
        return acro
    }
    func delete(request: Request, acronym: Acronym) throws -> ResponseRepresentable {
        try acronym.delete()
        return JSON([:])
    }
    
}

extension Request {
    func acronym() throws -> Acronym {
        guard let json = json else { throw Abort.badRequest }
        return try Acronym(node: json.makeNode(in: myContext), context: myContext)
    }
}

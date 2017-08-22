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
    
    func addRoutes(drop: Droplet) {
        self.drop = drop
        drop.get("til", handler: indexView)
        drop.post("til", handler: addAcronym)
        drop.post("til", Acronym.parameter, "delete", handler: delete)
        
    }
    func indexView(request: Request) throws -> ResponseRepresentable {
        let acronyms = try Acronym.all().makeNode(in: myContext)
        let params = try Node(node: [
            "acronyms": acronyms,
        ])
        guard let drop = self.drop else { throw Abort.badRequest }
        return try drop.view.make("index", params)
    }
    func addAcronym(request: Request) throws -> ResponseRepresentable {
        guard let short = request.data["short"]?.string else { throw Abort.badRequest }
        guard let long = request.data["long"]?.string else { throw Abort.badRequest }
        let acronym = Acronym(short: short, long: long)
        try acronym.save()
        return try indexView(request: request)
        
    }
    // Delete with ID path parameter
//    func delete(request: Request, acronymId: Int) throws -> ResponseRepresentable {
//        guard let acronym = try Acronym.find(acronymId) else {
//            throw Abort.notFound
//        }
//        try acronym.delete()
//        return acronym //try indexView(request: request)
//    }
    func delete(request: Request) throws -> ResponseRepresentable {
        let acronym = try request.parameters.next(Acronym.self)
        print(acronym)
        try acronym.delete()
        return try self.indexView(request: request)
    }
    
    
}

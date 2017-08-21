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
    }
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        let acronyms = try Acronym.all().makeNode(in: myContext)
        let params = try Node(node: [
            "acronyms": acronyms,
        ])
        guard let drop = self.drop else { throw Abort.badRequest }
        return try drop.view.make("index", params)
    }
    
}

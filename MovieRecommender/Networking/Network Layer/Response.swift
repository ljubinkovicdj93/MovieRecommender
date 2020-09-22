//
//  Response.swift
//  MovieRecommender
//
//  Created by Djordje Ljubinkovic on 9/22/20.
//

import Foundation

public struct Response {
    let httpUrlResponse: HTTPURLResponse
    let originRequest: Request

    let rawResponse: Data
}

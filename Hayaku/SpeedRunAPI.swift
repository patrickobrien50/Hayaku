//
//  SpeedRunAPI.swift
//  Hayaku
//
//  Created by Patrick O'brien on 6/5/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import Foundation
import Siesta


let SpeedRunAPI = _SpeedRunAPI()


class _SpeedRunAPI {
    
    
    private let service = Service(
        baseURL: "https://www.speedrun.com/api/v1",
        standardTransformers: [.text, .image])
    
    
    fileprivate init() {
        
        let jsonDecoder = JSONDecoder()
        
        service.configureTransformer("/games/*") {
            try jsonDecoder.decode(GamesResponse.self, from: $0.content)
        }
        
        service.configureTransformer("/games/*?embed=categories,variables,platforms") {
            try jsonDecoder.decode(VariablesResponse.self, from: $0.content)
        }
        
        func games(searchText: String) -> Resource {
            return service
                .resource("/games")
            
        }
        
    }
    
    
    
    

}

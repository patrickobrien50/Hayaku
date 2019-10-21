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
        


        

        func getLeaderboards() -> Resource {
            return service
                .resource("/leaderboards")
        }
        
    }
    
    
    
    

}

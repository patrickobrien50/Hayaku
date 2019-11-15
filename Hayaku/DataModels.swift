//
//  DataModels.swift
//  Hayaku
//
//  Created by Patrick O'Brien on 5/20/18.
//  Copyright © 2018 Patrick O'Brien. All rights reserved.
//

import Foundation
import UIKit

struct ResultsUsersResponse : Codable {
    var data : [ResultsUsers]
    var pagination : PaginationData?
}

struct ResultsSeriesResponse: Codable {
    var data : [ResultsSeries]
    var pagination: PaginationData?
}

struct GameSeriesResponse : Codable {
    var data : ResultsSeries
    var pagination : PaginationData?
}

struct ResultsGameResponse : Codable {
    var data : [ResultsGame]
    var pagination: PaginationData?
}

struct ResultsUsers : Codable {
    var id : String
    var names : Names
    var weblink : String
    var twitch : SocialMediaLink?
    var youtube : SocialMediaLink?
    var speedrunslive: SocialMediaLink?
    var twitter : SocialMediaLink?
    
}
struct ResultsSeries : Codable {
    var id : String
    var names : Names
    var assets : GameAssets
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case assets = "assets"
        case names = "names"
    }
}

struct ResultsGame : Codable {
    var id : String
    var names : Names
    var releaseDate : String
    var assets : GameAssets
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case names = "names"
        case releaseDate = "release-date"
        case assets = "assets"
    }
}

struct GamesResponse : Codable {
    var data: Game
    var pagination: PaginationData?
    

}

struct UserResponse : Codable {
    var data: [User]
    var pagination : PaginationData?
    
}


struct PopularGamesResponse : Codable {
    var data : [Game]
    var pagination: PaginationData?
}

struct User : Codable {
    var place : Int
    var game: PersonalBestGameResponse?
    var category : PersonalBestCategoryResponse?
    var run : Run
    
}

struct PersonalBestGameResponse : Codable {
    var data : PersonalBestGame
    var pagination : PaginationData?
}

struct PersonalBestGame : Codable {

    
    var id: String
    var names: Names
    var categories: CategoriesResponse?
    var releaseDate: String
    var assets: GameAssets
    var platforms: [String]
    var variables: VariablesResponse?
    var links : [Links]
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case names = "names"
        case categories = "categories"
        case releaseDate = "release-date"
        case assets = "assets"
        case platforms = "platforms"
        case variables = "variables"
        case links = "links"
    }
}

struct Game : Codable {
    var id: String
    var names: Names
    var categories: CategoriesResponse?
    var releaseDate: String
    var assets: GameAssets
    var platforms: PlatformsResponse?
    var variables: VariablesResponse?
    var links : [Links]
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case names = "names"
        case categories = "categories"
        case releaseDate = "release-date"
        case assets = "assets"
        case platforms = "platforms"
        case variables = "variables"
        case links = "links"
    }
}


struct Links : Codable {
    var rel : String
    var uri : String
}

struct GameAssets : Codable {
    var logo: GameImageData
    var coverSmall: GameImageData
    var coverMedium: GameImageData
    var coverLarge: GameImageData
    var icon: GameImageData
    var trophy1st: GameImageData
    var trophy2nd: GameImageData
    var trophy3rd: GameImageData
    var background: GameImageData?
    
    func cover(for size: CGSize) -> GameImageData? {
        let references = [coverMedium, coverLarge, coverSmall].compactMap({ $0 })
        return references.first(where: { $0.size.width > size.width && $0.size.height > size.height}) ?? references.last
    }
    
    enum CodingKeys: String, CodingKey {
        case logo = "logo"
        case coverSmall = "cover-small"
        case coverMedium = "cover-medium"
        case coverLarge = "cover-large"
        case icon = "icon"
        case trophy1st = "trophy-1st"
        case trophy2nd = "trophy-2nd"
        case trophy3rd = "trophy-3rd"
        case background = "background"
    }
}

struct GameImageData : Codable {
    var uri: String
    var height: Int?
    var width: Int?
    
    var size: CGSize {
        return CGSize(width: width!, height: height!)
    }
}

struct Names : Codable {
    var international: String
    var japanese: String?
    var twitch: String?
}

struct CategoriesResponse : Codable {
    var data: [Category]

}

struct PersonalBestCategoryResponse : Codable {
    var data: Category
}

struct Category : Codable {
    var id: String
    var name: String
    var rules: String?
    var variables: VariablesResponse?
    var links : [Links]
    
}

struct PlatformsResponse : Codable {
    var data: [Platforms]
}

struct Platforms : Codable {
    var id: String
    var name: String
}

struct VariablesResponse : Codable {
    var data: [Variable]
}

struct Variable : Codable {
    var id: String
    var name: String
    var values: VariablesValues
    var isSubcategory: Bool

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case values = "values"
        case isSubcategory = "is-subcategory"
    }

}

struct Choices : Codable , Comparable {
    static func < (lhs: Choices, rhs: Choices) -> Bool {
        return lhs.label < rhs.label
    }
    
    var label: String
    var rules: String?
}

struct VariablesValues : Codable {
    var values : [String: Choices]
}


struct PaginationData : Codable {
    var offset: Int
    var size: Int
    var max: Int
}


struct LeaderboardsResponse : Codable {
    var data : Leaderboards
}

struct Leaderboards : Codable {
    var runs: [RunPosition]
    var players: PlayersResponse?
}

struct PlayersResponse: Codable {
    var data: [Player]
}

struct Player: Codable {
    var id: String?
    var rel: String
    var name: String?
    var names: Names?
    var twitch: MediaPlatform?
    var youtube: MediaPlatform?
    var twitter: MediaPlatform?
    var speedrunslive: MediaPlatform?
}

struct RunPosition : Codable {
    var place: Int
    var run: Run
}

struct Run : Codable {
    var id : String
    var players: [Player]
    var comment: String?
    var times: Times
    var weblink: String
    var videos: Video?
    var values: [String : String]?
    var status : Status?
    var variablesText: String?
}


struct Times : Codable {
    var primary: String
    var primary_t: TimeInterval
    var realtime_t: TimeInterval
}

struct Video : Codable {
    var links: [MediaPlatform]?
}

struct MediaPlatform : Codable {
    var uri: String?
}

struct TwitchResponse : Codable {
    var data: [Twitch]
}

struct Twitch : Codable {
    var title : String?
    var description : String?
    var thumbnailUrl : String
    
    enum CodingKeys : String, CodingKey{
        case title = "title"
        case description = "description"
        case thumbnailUrl = "thumbnail_url"
    }
    
}

struct PopularStream {
    var title: String
    var viewers : String
    var username: String
    var imageLink: String
    var weblink: String
}

struct PopularGame {
    var name: String
    var playerCount: String
    var imageLink: String
    
}
struct Status : Codable {
    var status : String?
    var examiner : String?
    var verifiedDate : String?
    
    enum CodingKeys : String, CodingKey {
        case status = "status"
        case examiner = "examiner"
        case verifiedDate = "verify-date"
    }
}

struct SocialMediaLink : Codable {
    var uri: String
}

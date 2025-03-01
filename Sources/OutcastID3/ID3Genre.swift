//
//  ID3Genre.swift
//  OutcastID3
//
//  Created by Andy on 01/03/2025.
//


import Foundation

/**
 An enum that contains the genres supported by the ID3 standard using specific identifiers.
 */
public enum ID3Genre: Int, Equatable, Hashable, CaseIterable {
    /// Blues genre.
    case blues = 0
    /// Classic rock genre.
    case classicRock = 1
    /// Country genre.
    case country = 2
    /// Dance genre.
    case dance = 3
    /// Disco genre.
    case disco = 4
    /// Funk genre.
    case funk = 5
    /// Grunge genre.
    case grunge = 6
    /// Hip hop genre.
    case hipHop = 7
    /// Jazz genre.
    case jazz = 8
    /// Metal genre.
    case metal = 9
    /// New age genre.
    case newAge = 10
    /// Oldies genre.
    case oldies = 11
    /// Other genre.
    case other = 12
    /// Pop genre.
    case pop = 13
    /// R&B genre.
    case rAndB = 14
    /// Rap genre.
    case rap = 15
    /// Reggae genre.
    case reggae = 16
    /// Rock genre.
    case rock = 17
    /// Techno genre.
    case techno = 18
    /// Industrial genre.
    case industrial = 19
    /// Alternative genre.
    case alternative = 20
    /// Ska genre.
    case ska = 21
    /// Death metal genre.
    case deathMetal = 22
    /// Pranks genre.
    case pranks = 23
    /// Soundtrack genre.
    case soundtrack = 24
    /// Euro techno genre.
    case euroTechno = 25
    /// Ambient genre.
    case ambient = 26
    /// Tip hop genre.
    case tripHop = 27
    /// vocal genre.
    case vocal = 28
    /// Jazz funk genre.
    case jazzFunk = 29
    /// Fusion genre.
    case fusion = 30
    /// Trance genre.
    case trance = 31
    /// Classical genre.
    case classical = 32
    /// Instrumental genre.
    case instrumental = 33
    /// Acid genre.
    case acid = 34
    /// House genre.
    case house = 35
    /// Game genre.
    case game = 36
    /// Soundclip genre.
    case soundClip = 37
    /// Gospel genre.
    case gospel = 38
    /// Noise genre.
    case noise = 39
    /// Altern rock genre.
    case alternRock = 40
    /// Bass genre.
    case bass = 41
    /// Soul genre.
    case soul = 42
    /// Punk genre.
    case punk = 43
    /// Space genre.
    case space = 44
    /// Meditative genre.
    case meditative = 45
    /// Instrumental pop genre.
    case instrumentalPop = 46
    /// Instrumental rock genre.
    case instrumentalRock = 47
    /// Ethnic genre.
    case ethnic = 48
    /// Gothic genre.
    case gothic = 49
    /// Darkwave genre.
    case darkwave = 50
    /// TechnoIndustrial genre.
    case technoIndustrial = 51
    /// Electronic genre.
    case electronic = 52
    /// Pop folk genre.
    case popFolk = 53
    /// Eurodance genre.
    case eurodance = 54
    /// Dream genre.
    case dream = 55
    /// Souther rock genre.
    case southernRock = 56
    /// Comedy genre.
    case comedy = 57
    /// Cult genre.
    case cult = 58
    /// Gangsta genre.
    case gangsta = 59
    /// Top 40 genre.
    case top40 = 60
    /// Christian rap genre.
    case christianRap = 61
    /// Pop funk genre.
    case popFunk = 62
    /// Jungle genre.
    case jungle = 63
    /// Native american genre.
    case nativeAmerican = 64
    /// Cabaret genre.
    case cabaret = 65
    /// New wave genre.
    case newWave = 66
    /// Psychadelic genre.
    case psychadelic = 67
    /// Rave genre.
    case rave = 68
    /// Showtunes genre.
    case showtunes = 69
    /// Trailer genre.
    case trailer = 70
    /// Lofi genre.
    case loFi = 71
    /// Tribal genre.
    case tribal = 72
    /// Acid punk genre.
    case acidPunk = 73
    /// Acid jazz genre.
    case acidJazz = 74
    /// Polka genre.
    case polka = 75
    /// Retro genre.
    case retro = 76
    /// Musical genre.
    case musical = 77
    /// Rock and roll genre.
    case rockAndRoll = 78
    /// Hard rock genre.
    case hardRock = 79
    /// Remix genre.
    case remix = 80
    /// Cover genre.
    case cover = 81
}

public extension ID3Genre {
    var displayName: String {
        switch self {
        case .blues: return "Blues"
        case .classicRock: return "Classic Rock"
        case .country: return "Country"
        case .dance: return "Dance"
        case .disco: return "Disco"
        case .funk: return "Funk"
        case .grunge: return "Grunge"
        case .hipHop: return "Hip Hop"
        case .jazz: return "Jazz"
        case .metal: return "Metal"
        case .newAge: return "New Age"
        case .oldies: return "Oldies"
        case .other: return "Other"
        case .pop: return "Pop"
        case .rAndB: return "R&B"
        case .rap: return "Rap"
        case .reggae: return "Reggae"
        case .rock: return "Rock"
        case .techno: return "Techno"
        case .industrial: return "Industrial"
        case .alternative: return "Alternative"
        case .ska: return "Ska"
        case .deathMetal: return "Death Metal"
        case .pranks: return "Pranks"
        case .soundtrack: return "Soundtrack"
        case .euroTechno: return "Euro Techno"
        case .ambient: return "Ambient"
        case .tripHop: return "Trip Hop"
        case .vocal: return "Vocal"
        case .jazzFunk: return "Jazz Funk"
        case .fusion: return "Fusion"
        case .trance: return "Trance"
        case .classical: return "Classical"
        case .instrumental: return "Instrumental"
        case .acid: return "Acid"
        case .house: return "House"
        case .game: return "Game"
        case .soundClip: return "Sound Clip"
        case .gospel: return "Gospel"
        case .noise: return "Noise"
        case .alternRock: return "Alternative Rock"
        case .bass: return "Bass"
        case .soul: return "Soul"
        case .punk: return "Punk"
        case .space: return "Space"
        case .meditative: return "Meditative"
        case .instrumentalPop: return "Instrumental Pop"
        case .instrumentalRock: return "Instrumental Rock"
        case .ethnic: return "Ethnic"
        case .gothic: return "Gothic"
        case .darkwave: return "Darkwave"
        case .technoIndustrial: return "Techno Industrial"
        case .electronic: return "Electronic"
        case .popFolk: return "Pop Folk"
        case .eurodance: return "Eurodance"
        case .dream: return "Dream"
        case .southernRock: return "Southern Rock"
        case .comedy: return "Comedy"
        case .cult: return "Cult"
        case .gangsta: return "Gangsta"
        case .top40: return "Top 40"
        case .christianRap: return "Christian Rap"
        case .popFunk: return "Pop Funk"
        case .jungle: return "Jungle"
        case .nativeAmerican: return "Native American"
        case .cabaret: return "Cabaret"
        case .newWave: return "New Wave"
        case .psychadelic: return "Psychedelic"
        case .rave: return "Rave"
        case .showtunes: return "Showtunes"
        case .trailer: return "Trailer"
        case .loFi: return "Lo-Fi"
        case .tribal: return "Tribal"
        case .acidPunk: return "Acid Punk"
        case .acidJazz: return "Acid Jazz"
        case .polka: return "Polka"
        case .retro: return "Retro"
        case .musical: return "Musical"
        case .rockAndRoll: return "Rock & Roll"
        case .hardRock: return "Hard Rock"
        case .remix: return "Remix"
        case .cover: return "Cover"
        }
    }
}

extension ID3Genre {
    
    static var allCasesMapping : [String : ID3Genre] {
        [
            "blues" : ID3Genre.blues,
            "classicRock" : ID3Genre.classicRock,
            "country" : ID3Genre.country,
            "dance" : ID3Genre.dance,
            "disco" : ID3Genre.disco,
            "funk" : ID3Genre.funk,
            "grunge" : ID3Genre.grunge,
            "hipHop" : ID3Genre.hipHop,
            "jazz" : ID3Genre.jazz,
            "metal" : ID3Genre.metal,
            "newAge" : ID3Genre.newAge,
            "oldies" : ID3Genre.oldies,
            "other" : ID3Genre.other,
            "pop" : ID3Genre.pop,
            "rAndB" : ID3Genre.rAndB,
            "rap" : ID3Genre.rap,
            "reggae" : ID3Genre.reggae,
            "rock" : ID3Genre.rock,
            "techno" : ID3Genre.techno,
            "industrial" : ID3Genre.industrial,
            "alternative" : ID3Genre.alternative,
            "ska" : ID3Genre.ska,
            "deathMetal" : ID3Genre.deathMetal,
            "pranks" : ID3Genre.pranks,
            "soundtrack" : ID3Genre.soundtrack,
            "euroTechno" : ID3Genre.euroTechno,
            "ambient" : ID3Genre.ambient,
            "tripHop" : ID3Genre.tripHop,
            "vocal" : ID3Genre.vocal,
            "jazzFunk" : ID3Genre.jazzFunk,
            "fusion" : ID3Genre.fusion,
            "trance" : ID3Genre.trance,
            "classical" : ID3Genre.classical,
            "instrumental" : ID3Genre.instrumental,
            "acid" : ID3Genre.acid,
            "house" : ID3Genre.house,
            "game" : ID3Genre.game,
            "soundClip" : ID3Genre.soundClip,
            "gospel" : ID3Genre.gospel,
            "noise" : ID3Genre.noise,
            "alternRock" : ID3Genre.alternRock,
            "bass" : ID3Genre.bass,
            "soul" : ID3Genre.soul,
            "punk" : ID3Genre.punk,
            "space" : ID3Genre.space,
            "meditative" : ID3Genre.meditative,
            "instrumentalPop" : ID3Genre.instrumentalPop,
            "instrumentalRock" : ID3Genre.instrumentalRock,
            "ethnic" : ID3Genre.ethnic,
            "gothic" : ID3Genre.gothic,
            "darkwave" : ID3Genre.darkwave,
            "technoIndustrial" : ID3Genre.technoIndustrial,
            "electronic" : ID3Genre.electronic,
            "popFolk" : ID3Genre.popFolk,
            "eurodance" : ID3Genre.eurodance,
            "dream" : ID3Genre.dream,
            "southernRock" : ID3Genre.southernRock,
            "comedy" : ID3Genre.comedy,
            "cult" : ID3Genre.cult,
            "gangsta" : ID3Genre.gangsta,
            "top40" : ID3Genre.top40,
            "christianRap" : ID3Genre.christianRap,
            "popFunk" : ID3Genre.popFunk,
            "jungle" : ID3Genre.jungle,
            "nativeAmerican" : ID3Genre.nativeAmerican,
            "cabaret" : ID3Genre.cabaret,
            "newWave" : ID3Genre.newWave,
            "psychadelic" : ID3Genre.psychadelic,
            "rave" : ID3Genre.rave,
            "showtunes" : ID3Genre.showtunes,
            "trailer" : ID3Genre.trailer,
            "loFi" : ID3Genre.loFi,
            "tribal" : ID3Genre.tribal,
            "acidPunk" : ID3Genre.acidPunk,
            "acidJazz" : ID3Genre.acidJazz,
            "polka" : ID3Genre.polka,
            "retro" : ID3Genre.retro,
            "musical" : ID3Genre.musical,
            "rockAndRoll" : ID3Genre.rockAndRoll,
            "hardRock" : ID3Genre.hardRock,
            "remix" : ID3Genre.remix,
            "cover" : ID3Genre.cover,
        ]
    }
    
    
    static func parseString(_ string: String) -> ID3Genre? {
        for genreMapping in ID3Genre.allCasesMapping {
            let genreName = genreMapping.0
            let genre = genreMapping.1
            if string.localizedCaseInsensitiveCompare(genreName) == .orderedSame {
                return genre
            }
        }
        return nil
    }

}

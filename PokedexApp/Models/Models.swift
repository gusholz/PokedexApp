//
//  Models.swift
//  PokedexApp
//
//  Created by Gustavo Holzmann on 29/06/23.
//

import Foundation

struct PokemonModel: Codable, Identifiable{
    var id: Int
    var nome: String?
    var tipo: [PokemonType]? = []
    var sprite: Sprites?
    var weight: Int
}

struct Pokemon: Codable, Hashable {
    var name: String
    var url: String
}

struct PokemonList: Codable {
    var results: [Pokemon]
}

struct PokemonSprite: Codable {
    var sprites: Sprites
}

struct Sprites: Codable {
    var frontDefault: String
    var frontShiny: String
}

struct PokeType: Codable {
    var types: [TypeDetails]
}

struct TypeDetails: Codable {
    var type: PokemonType
}

struct PokemonType: Codable, Hashable {
    var name: String
}

//
//  PokemonViewModel.swift
//  PokedexApp
//
//  Created by Gustavo Holzmann on 29/06/23.
//

import Foundation

class PokemonViewModel: ObservableObject {
    @Published var pokemonList: [PokemonModel] = []
    
    func fetchAllPokemon() async throws {
        
        let pokeApiUrl = "https://pokeapi.co/api/v2/pokemon?limit=463"
        
        guard let url = URL(string: pokeApiUrl) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            let fetchedPokemonList = try decoder.decode(PokemonList.self, from: data)
            
            try await withThrowingTaskGroup(of: PokemonModel.self, body: { group in
                for pokemon in fetchedPokemonList.results{
                    group.addTask {
                        let types = try await self.fetchPokemonTypes(pokemonName: pokemon.name)
                        let sprites = try await self.fetchPokemonSprites(pokemonName: pokemon.name)
                        let id = try await self.fetchPokemonID(pokemonName: pokemon.name)
                        return PokemonModel(id: id,nome: pokemon.name, tipo: types, sprite: sprites)
                    }
                }
                
                while let result = try await group.next(){
                    pokemonList.append(result)
                }
                
            })
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchPokemonTypes(pokemonName: String) async throws -> [PokemonType] {
        let pokeApiType = "https://pokeapi.co/api/v2/pokemon/\(pokemonName)"
        
        guard let url = URL(string: pokeApiType) else{
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let pokemonDetails = try decoder.decode(PokeType.self, from: data)
            let types = pokemonDetails.types.map { $0.type }
            return types
        } catch {
            print("Error: \(error.localizedDescription)")
            throw NetworkError.invalidConversion
        }
    }
    
    func fetchPokemonSprites(pokemonName: String) async throws -> Sprites {
        let pokeApiPokemonSprite = "https://pokeapi.co/api/v2/pokemon/\(pokemonName)"
        
        guard let url = URL(string: pokeApiPokemonSprite) else{
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let pokemonDetails = try decoder.decode(PokemonSprite.self, from: data)
            return pokemonDetails.sprites
        } catch {
            print("Error: \(error.localizedDescription)")
            throw NetworkError.invalidConversion
        }
    }
    
    func fetchPokemonID(pokemonName: String) async throws -> Int {
        let pokeApiPokemonSprite = "https://pokeapi.co/api/v2/pokemon/\(pokemonName)"
        
        guard let url = URL(string: pokeApiPokemonSprite) else{
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let pokemonDetails = try decoder.decode(PokemonModel.self, from: data)
            return pokemonDetails.id
        } catch {
            print("Error: \(error.localizedDescription)")
            throw NetworkError.invalidConversion
        }
    }
}

//
//  ContentView.swift
//  PokedexApp
//
//  Created by Gustavo Holzmann on 23/06/23.
//

import SwiftUI

struct PokemonModel {
    var nome: String
    var tipo: [String]
    var sprite: Sprites
}

class PokemonViewModel: ObservableObject{
    @Published var pokemonList: [PokemonModel] = []
    
    init(){
        
    }
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
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}

struct PokeType: Codable {
    var types: [TypeDetails]
}

struct TypeDetails: Codable {
    var type: PType
}

struct PType: Codable, Hashable {
    var name: String
}

struct ContentView: View {
    
    @State private var pokemonsList: [Pokemon] = []
    @State private var pokemonSprites: [String: PokemonSprite] = [:]
    @State private var pokemonTypes: [String: [PType]] = [:]
    @State private var searchTerm: String = ""
    @State private var pokemonViewList: [Pokemon] = []
    
    var body: some View {
        VStack {
            Text("Pokedex")
                .font(.largeTitle)
            HStack{
                TextField("procure um pokemon", text: $searchTerm)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                Button("search") {
                    if searchTerm.isEmpty{
                        pokemonViewList = pokemonsList
                    }else{
                        pokemonViewList = pokemonsList.filter{ pokemon in
                            pokemon.name.contains(searchTerm.lowercased())
                        }
                    }
                }
            }
            List {
                ForEach(pokemonViewList, id: \.self) { pokemon in
                    if let pokemonSprite = pokemonSprites[pokemon.name] {
                        PokemonDetailedView(pokemon: pokemon, pokemonSprite: pokemonSprite, pokemonTypes: pokemonTypes[pokemon.name]) // Alteração aqui
                    }
                }
            }
        }
        .padding()
        .task {
            do {
                let fetchedPokemon = try await getPokemon()
                pokemonsList = fetchedPokemon
                pokemonViewList = pokemonsList
                await fetchPokemonSprites() // Obter os sprites dos pokémons
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getPokemon() async throws -> [Pokemon] {
        let pokeApiUrl = "https://pokeapi.co/api/v2/pokemon?limit=463"
        
        guard let url = URL(string: pokeApiUrl) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            
            let decoder = JSONDecoder()
            let PokemonList = try decoder.decode(PokemonList.self, from: data)
            
            return PokemonList.results
        } catch {
            print("Error: \(error.localizedDescription)")
            throw NetworkError.invalidConversion
        }
    }
    
    
    func fetchPokemonSprites() async {
        for pokemon in pokemonsList {
            do {
                let fetchedSprite = try await getPokemonSprites(pokemonName: pokemon.name)
                let pokemonSprite = PokemonSprite(sprites: fetchedSprite)
                pokemonSprites[pokemon.name] = pokemonSprite
                
                let fetchedTypes = try await fetchPokemonTypes(pokemonName: pokemon.name)
                pokemonTypes[pokemon.name] = fetchedTypes
            } catch {
                print("Error fetching sprite for \(pokemon.name): \(error.localizedDescription)")
            }
        }
    }

    
    func fetchPokemonTypes(pokemonName: String) async throws -> [PType] {
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

    
    func getPokemonSprites(pokemonName: String) async throws -> Sprites {
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
            let pokemonDetails = try decoder.decode(PokemonSprite.self, from: data)
            return pokemonDetails.sprites
        } catch {
            print("Error: \(error.localizedDescription)")
            throw NetworkError.invalidConversion
        }
    }
}


struct PokemonDetailedView: View {
    
    var pokemon: Pokemon
    var pokemonSprite: PokemonSprite
    var pokemonTypes: [PType]?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(pokemon.name.capitalized)
                    .font(.largeTitle)
            }
            VStack (alignment: .leading){
                Text("Tipo: ")
                    .font(.headline)
                if let types = pokemonTypes {
                    ForEach(types, id: \.self) { type in
                        Text(type.name.capitalized)
                            .font(.subheadline)
                    }
                }
            }.padding(.top,10)
            HStack {
                AsyncImage(url: URL(string: pokemonSprite.sprites.frontDefault)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                } placeholder: {
                    Color.gray
                        .frame(width: 150, height: 150)
                }
                
                AsyncImage(url: URL(string: pokemonSprite.sprites.frontShiny)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                } placeholder: {
                    Color.gray
                        .frame(width: 150, height: 150)
                }
            }
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidConversion
}

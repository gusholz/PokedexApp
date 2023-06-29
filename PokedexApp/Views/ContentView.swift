//
//  ContentView.swift
//  PokedexApp
//
//  Created by Gustavo Holzmann on 23/06/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var pokemonsList: [PokemonModel] = []
    @State private var pokemonViewList: [PokemonModel] = []
    
    @State private var searchTerm: String = ""
    
    var pokemonVM = PokemonViewModel()
    
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
                            .stroke(Color.yellow, lineWidth: 2)
                    )
                Button("search") {
                    if searchTerm.isEmpty{
                        pokemonViewList = pokemonsList.sorted(by: {$0.id < $1.id})
                    }else{
                        pokemonViewList = pokemonsList.filter{ pokemon in
                            pokemon.nome!.contains(searchTerm.lowercased())
                        }
                    }
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.blue)
                }
                .foregroundColor(.yellow)
            }
            List {
                ForEach(pokemonViewList, id: \.id) { pokemon in
                    PokemonDetailedView(pokemon: pokemon)
                }
            }
        }
        .padding()
        .background(.red)
        .task {
            do {
                try await pokemonVM.fetchAllPokemon()
                let fetchedPokemon = pokemonVM.pokemonList
                pokemonsList = fetchedPokemon
                pokemonViewList = pokemonsList.sorted(by: {$0.id < $1.id})
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
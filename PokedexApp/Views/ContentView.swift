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
    @State private var pressedXtimes: Int = 0
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
                        }.sorted(by: { $0.id < $1.id} )
                    }
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.blue)
                }
                .foregroundColor(.yellow)
            }
            .padding(.bottom)
            Button("Organizar por peso", action: {
                if pressedXtimes % 2 == 0 {
                    pokemonViewList = pokemonsList.sorted(by: {$0.weight > $1.weight})
                } else {
                    pokemonViewList = pokemonsList.sorted(by: {$0.weight < $1.weight})
                }
                
                pressedXtimes += 1
            })
            .padding()
            .background{
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.blue)
            }
            .foregroundColor(.yellow)
            Button("Organizar por altura", action: {
                if pressedXtimes % 2 == 0 {
                    pokemonViewList = pokemonsList.sorted(by: {$0.height > $1.height})
                } else {
                    pokemonViewList = pokemonsList.sorted(by: {$0.height < $1.height})
                }
                
                pressedXtimes += 1
            })
            .padding()
            .background{
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.blue)
            }
            .foregroundColor(.yellow)
            List {
                ForEach(pokemonViewList, id: \.id) { pokemon in
                    PokemonDetailedView(pokemon: pokemon)
                }
            }
            .scrollContentBackground(.hidden)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.yellow, lineWidth: 2)
            )
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

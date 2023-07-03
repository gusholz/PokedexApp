//
//  PokemonDetailedView.swift
//  PokedexApp
//
//  Created by Gustavo Holzmann on 29/06/23.
//

import SwiftUI

struct PokemonDetailedView: View {
    
    var pokemon: PokemonModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(pokemon.nome?.capitalized ?? "")
                    .font(.largeTitle)
            }
            VStack (alignment: .leading){
                Text("Tipo: ")
                    .font(.headline)
                ForEach(pokemon.tipo ?? [], id: \.self) { type in
                        Text(type.name.capitalized)
                            .font(.subheadline)
                    }
                HStack {
                    VStack {
                        Text("Peso")
                            .font(.headline)
                            .padding(.top)
                        Text("\(pokemon.weight)")
                    }
                    Spacer()
                    VStack {
                        Text("Altura")
                            .font(.headline)
                            .padding(.top)
                        Text("\(pokemon.height)")
                    }
                }
            }
            .padding(.top,10)
            HStack {
                AsyncImage(url: URL(string: pokemon.sprite?.frontDefault ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                } placeholder: {
                    Color.gray
                        .frame(width: 150, height: 150)
                }
                
                AsyncImage(url: URL(string: pokemon.sprite?.frontShiny ?? "")) { image in
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

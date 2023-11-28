//
//  SystemSymbolPickerView.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import SwiftUI
import CrossPlatform

struct SystemSymbolPickerView: View {
    
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var selectedSymbolName: String
    
    @State
    var selectedSymbolLocal: String = ""
    
    @State
    var symbols = [String]()
    
    @State
    var error: String?
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Choose system symbol")
                .font(.title)
                .bold()
            
            Divider()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 8) {
                    ForEach(symbols, id: \.self) { symbolName in
                        let isSelected = symbolName == selectedSymbolLocal
                        
                        VStack {
                            ZStack {
                                Image(systemName: symbolName)
                            }
                            .padding(8)
                            .background(Color(CPColor.systemGroupedBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: isSelected ? 2 : 1)
                                    .foregroundStyle(isSelected ? Color.accentColor : Color(CPColor.tertiaryLabel))
                            )
                            Text(symbolName)
                        }.onTapGesture {
                            selectedSymbolLocal = symbolName
                        }
                    }
                }
            }
            
            if let error {
                Label {
                    Text(error)
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                }.foregroundStyle(Color.red)
            }
            
            Spacer()
            
            Divider()
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
                
                Button {
                    self.selectedSymbolName = selectedSymbolLocal
                    dismiss()
                } label: {
                    Text("Select")
                }
                .disabled(selectedSymbolLocal == "")
                .buttonStyle(BorderedProminentButtonStyle())
            }
            
        }
        .padding(16)
        .frame(minWidth: 300, minHeight: 400)
        .background(Color(CPColor.systemGroupedBackground))
        .onAppear {
            print("Retrieving symbols")
            do {
                let listOfSymbols = try getListOfSymbols()
                self.symbols = listOfSymbols.map { $0.name }
                
                print("Finished processing symbols")
            } catch {
                self.error = "Could not get symbols: \(error)"
            }
        }
    }
    
    func getListOfSymbols() throws -> [Symbol] {
        let sfsymbolsAppUrl = URL(fileURLWithPath: Constants.sfSymbolsPath)
        let nameAvailabilityFile = sfsymbolsAppUrl.appendingPathComponent(Constants.nameAvailabilityPath)
        guard let fallbackNameAvailabilityFile = Bundle.main.url(forResource: "name_availability", withExtension: "plist") else {
            throw SystemSymbolPickerError.cannotMakeNameAvailabilityURLInBundle
        }
        
        guard
            let nameAvailability =
                (try? SFNameAvailabilityHelper.readNameAvailabilityFile(file: nameAvailabilityFile))
             ?? (try? SFNameAvailabilityHelper.readNameAvailabilityFile(file: fallbackNameAvailabilityFile))
        else {
            throw SystemSymbolPickerError.cannotRetrieveListOfSFSymbols
        }
        
        let groupedSymbols = SFNameAvailabilityHelper.makeGoupedSymbols(from: nameAvailability)
        
        let sortedSymbols = groupedSymbols.sorted(by: { $0.key < $1.key })
        
        return sortedSymbols.flatMap { $0.value }
    }
    
    enum SystemSymbolPickerError: Error, LocalizedError {
        /// Cannot make url to name_availability property list.
        case cannotMakeNameAvailabilityURLInBundle
        
        /// Cannot retrieve list of system symbols.
        case cannotRetrieveListOfSFSymbols
        
        var errorDescription: String? {
            switch self {
            case .cannotMakeNameAvailabilityURLInBundle:
                "Cannot make url to name_availability property list."
            case .cannotRetrieveListOfSFSymbols:
                "Cannot retrieve list of system symbols."
            }
        }
    }
}

#Preview {
    @State
    var selected = ""
    
    return SystemSymbolPickerView(selectedSymbolName: $selected)
}

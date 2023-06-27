//
//  ContentView.swift
//  Hogevor Erger
//
//  Created by Акоп Погосян on 21.06.2023.
//

import SwiftUI



struct ContentView: View {
    let songList = Array(1...1000)
    @State var searchText: String = ""
    @State var showLogo = true
    
    var filteredSongList: [Int] {
        if searchText.isEmpty {
            return songList
        } else {
            return songList.filter { String($0).contains(searchText) }
        }
    }
    
    var body: some View {
        if showLogo {
            Image("logo")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showLogo = false
                        }
                    }
                }
                .preferredColorScheme(.dark)
        } else {
        NavigationView {
            VStack {
                Text("Hogevor Ergaran")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                SearchBar(text: $searchText, placeholder: "Search songs by number")
                    .padding(.top, 10)
                    .padding(.bottom, -10)
                
                List(filteredSongList, id: \.self) { song in
                    NavigationLink(destination: SongView(songNumber: song)) {
                        Text("\(song)")
                    }
                }
            }
            .preferredColorScheme(.dark)
            .background(
                Image("background")
                    .edgesIgnoringSafeArea(.all))
            }
        }
    }
    
    
    
    struct SearchBar: UIViewRepresentable {
        @Binding var text: String
        var placeholder: String
        
        class Coordinator: NSObject, UISearchBarDelegate {
            @Binding var text: String
            
            init(text: Binding<String>) {
                _text = text
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                text = searchText
            }
        }
        
        func makeCoordinator() -> SearchBar.Coordinator {
            return Coordinator(text: $text)
        }
        
        func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
            let searchBar = UISearchBar()
            searchBar.delegate = context.coordinator
            searchBar.placeholder = placeholder
            searchBar.autocapitalizationType = .none
            return searchBar
        }
        
        func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
            uiView.text = text
        }
    }
    
    
    struct SongView: View {
        let songNumber: Int
        @State var songText: String = ""
        @GestureState private var translation: CGSize = .zero
        @State private var currentPage: Int = 0
        
        var body: some View {
            VStack {
                VStack {
                    Text("Երգ \(currentPage)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(-UIScreen.main.bounds.width * 0.1)
                }
                
                ScrollView {
                    if songText.isEmpty {
                        Text("Loading song...")
                            .padding()
                    } else {
                        Text(songText)
                            .font(.system(size: 18))
                            .padding()
                            .foregroundColor(.black)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.8)
                .background(Color(.white))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .onAppear {
                    if let filePath = Bundle.main.path(forResource: "\(songNumber)", ofType: "txt", inDirectory: "songs") {
                        do {
                            let contents = try String(contentsOfFile: filePath)
                            songText = contents
                        } catch {
                            songText = "Error loading song"
                        }
                    } else {
                        songText = "Song not found"
                    }
                }
                .gesture(DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // Переходим на следующую страницу песни
                            if currentPage < 1000 {
                                currentPage += 1
                                loadSongText()
                            }
                        } else if value.translation.width > 0 {
                            // Переходим на предыдущую страницу песни
                            if currentPage > 1 {
                                currentPage -= 1
                                loadSongText()
                            }
                        }
                    })
            }
            .background(
                Image("background")
                    .edgesIgnoringSafeArea(.all))
            .foregroundColor(.white)
            .onAppear {
                currentPage = songNumber
                loadSongText()
            }
            .preferredColorScheme(.dark)
        }
        
        func loadSongText() {
            if let filePath = Bundle.main.path(forResource: "\(currentPage)", ofType: "txt", inDirectory: "songs") {
                do {
                    let contents = try String(contentsOfFile: filePath)
                    songText = contents
                } catch {
                    songText = "Error loading song"
                }
            } else {
                songText = "Song not found"
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

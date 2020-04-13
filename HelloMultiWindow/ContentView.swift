import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            Button(action: {
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil)
            }, label: { Text("Open new window")})
                .font(.title)
                .tabItem {
                    VStack {
                        Text("New window")
                    }
                }
                .tag(0)
            AlbumGridView()
                .font(.title)
                .tabItem {
                    VStack {
                        Text("Drag and drop")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

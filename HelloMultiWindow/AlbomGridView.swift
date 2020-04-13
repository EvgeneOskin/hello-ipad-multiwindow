import SwiftUI
import UIKit

class CellContent: NSObject, NSItemProviderReading, NSItemProviderWriting {
    public var counter = 0
    
    required init(counter: Int) {
        self.counter = counter
    }
    static var writableTypeIdentifiersForItemProvider: [String] {
        return ["TerminalApp"]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let encoded = "\(counter)".toBase64()
        completionHandler(Data(base64Encoded: encoded), nil)
        return nil
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return Self.writableTypeIdentifiersForItemProvider
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        print(data.debugDescription, typeIdentifier)
        return Self(counter: Int(data.base64EncodedString().fromBase64()!)!)
    }
}

class AlbumPrivateCell: UICollectionViewCell {
    private static let reuseId = "AlbumPrivateCell"
    public var counter = 0
    lazy var cellController: DragAndDropViewControoler? = nil

    static func registerWithCollectionView(collectionView: UICollectionView) {
        collectionView.register(AlbumPrivateCell.self, forCellWithReuseIdentifier: reuseId)
    }

    static func getReusedCellFrom(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> AlbumPrivateCell{
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! AlbumPrivateCell
    }

    var albumView: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(self.albumView)

        albumView.text = "\(self.counter)"
        albumView.textAlignment = .center
        albumView.font = UIFont(name: "Helvetica Bold", size: 80.0)
        albumView.translatesAutoresizingMaskIntoConstraints = false

        albumView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        albumView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        albumView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        albumView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        cellController = DragAndDropViewControoler()

        cellController?.customEnableDragging(on: self)
    }
    
    func update() {
        albumView.text = "\(self.counter)"
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not been implemented")
    }
}

struct AlbumGridView: UIViewRepresentable {
    var data = [1,2,3,4,5,6,7,8,9]
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator

        context.coordinator.controller.customEnableDropping(on: collectionView)

        AlbumPrivateCell.registerWithCollectionView(collectionView: collectionView)
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        //
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        private var parent: AlbumGridView
        let controller: DragAndDropViewControoler = DragAndDropViewControoler()
        
        init(_ albumGridView: AlbumGridView) {
            self.parent = albumGridView
        }

        // MARK: UICollectionViewDataSource

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.parent.data.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let albumCell = AlbumPrivateCell.getReusedCellFrom(collectionView: collectionView, cellForItemAt: indexPath)
            albumCell.backgroundColor = .lightGray
            albumCell.counter = self.parent.data[indexPath.item]
            albumCell.update()
            return albumCell
        }

        // MARK: UICollectionViewDelegateFlowLayout

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width / 3
            return CGSize(width: width, height: width)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.parent.data[indexPath.item] += 1
            collectionView.reloadData()
        }
        
        func addCellData(_ counter: Int) {
            self.parent.data.append(counter)
        }
    }
}



extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}


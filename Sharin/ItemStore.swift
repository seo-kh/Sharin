//
//  ItemStore.swift
//  Sharin
//
//  Created by james seo on 2023/04/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import Combine

class ItemStore {
    private let ref = Firestore.firestore().collection("item")
    let items = CurrentValueSubject<[Item], Never>([])
    
    init() {
        fetchAllItems()
    }
    
    func fetchAllItems() {
        ref.getDocuments { snapshot, _ in
            if let snapshot = snapshot {
                let docu = snapshot.documents
                    .compactMap { docu -> Item? in
                        let data = docu.data()
                        guard let id = data["id"] as? String,
                              let name = data["name"] as? String,
                              let img = data["img"] as? String,
                              let usdz = data["usdz"] as? String else { return nil }
                        return Item(id: id, name: name, img: img, usdz: usdz)
                    }
                self.items.send(docu)
            }
        }
    }
}

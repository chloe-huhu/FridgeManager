//
//  FirebaseManager.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

enum CollectionName: String {
    case users = "users"
    case fridges = "fridges"
    case recipes = "recipe"
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum FirebaseError: String, Error {
    case decode = "Firebase decode error"
}

enum FirebaseRef {
    
    case collection(CollectionReference)
    
    case document(DocumentReference)
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
   
    func getCollection (ref: CollectionName) -> CollectionReference {
        
        switch ref {
        case.fridges: return Firestore.firestore().collection(ref.rawValue)
        case .users: return Firestore.firestore().collection(ref.rawValue)
        case .recipes: return Firestore.firestore().collection(ref.rawValue)
        }
    }

    func listen(ref: FirebaseRef, handler: @escaping () -> Void ) {
        
        switch ref {
        
        case .collection(let ref):
            
            ref.addSnapshotListener { (_, _) in
                handler()
            }
            
        case .document(let ref):
            
            ref.addSnapshotListener { (_, _) in
                handler()
            }
        }
        
    }
    

    func read<T: Codable>(ref: FirebaseRef, dataType: T.Type, handler: @escaping (Result<[T]>) -> Void) {
        
        switch ref {
        
        case .collection(let ref):
        
            ref.getDocuments { (querySnapShot, error) in
                
                guard let querySnapShot = querySnapShot else {
                    
                    handler(.failure(error!))
                    
                    return
                    
                }
                
                self.decode(dataType, documents: querySnapShot.documents) { (result) in
                    switch result {
                    case .success(let data): handler(.success(data))
                    case .failure(let error): handler(.failure(error))
                        
                    }
                }
            }
            
        case .document(let ref):
        
            ref.getDocument { (documentSnapshot, error) in
                
                guard let data = try? documentSnapshot?.data(as: dataType) else {
                    
                    handler(.failure(FirebaseError.decode))
                    
                    return
                }
                
                handler(.success([data]))
            }
        }
        
        
    }

    func decode<T: Codable>(_ dataType: T.Type, documents: [QueryDocumentSnapshot], handler: @escaping (Result<[T]>) -> Void) {
        
        var datas: [T] = []
        
        for document in documents {
            guard let data = try? document.data(as: dataType) else {
                handler(.failure(FirebaseError.decode))
                
                return
            }
            
            datas.append(data)
        }
        handler(.success(datas))
    }
}

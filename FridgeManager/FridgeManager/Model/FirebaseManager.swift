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
    //    case users = "users"
    case fridges = "fridges"
    //    case recipes = "recipes"
}

enum Result<T> {
    case success(T)
    case failure(Error)
}
enum FirebaseError: String, Error {
    case decode = "Firebase decode error"
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    var currentTimeStamp: Timestamp {
        
        return Timestamp()
        
    }
    
    func getCollection (ref: CollectionName) -> CollectionReference {
        
        switch ref {
        
        case.fridges: return Firestore.firestore().collection(ref.rawValue)
            
        }
    }

    func listen(ref: CollectionReference, handler: @escaping () -> Void ) {
        
        ref.addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            // 監聽新增項目
            documents.documentChanges.forEach { diff in
                if diff.type == .added {
//                    print("新增: \(diff.document.data())")
                }
                if diff.type == .modified {
//                    print("修改: \(diff.document.data())")
                }
                if diff.type == .removed {
//                    print("刪除: \(diff.document.data())")
                }
            }
                handler()
        }
        
    }
    

    func read<T: Codable>(ref: CollectionReference, dataType: T.Type, handler: @escaping (Result<[T]>) -> Void) {
        
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

//
//  MainPresenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/22/23.
//

import UIKit


protocol MainViewPresenterProtocol {
    func getNumberOfRowsInSection(for section: Int) -> Int
    func makeSearch(searchExpression: String?, completion: @escaping () -> Void)
    func getSearchResult(for indexPath: IndexPath) -> ResultForDisplay?
    func getImage(for indexPath: IndexPath) -> UIImage?
    func loadImageAsync(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void)
}


class MainViewPresenter: MainViewPresenterProtocol {
    
    private var urlString = "https://imdb-api.com/API/Search/k_ngzy512q/"
    // результаты поиска
    private var searchResults: [ResultForDisplay] = []
    // словарь для хранения изображений с измененными размерами
    private var resizeImagesCache: [IndexPath: UIImage] = [:]
        
    func getNumberOfRowsInSection(for section: Int) -> Int {
        (section == 0) ? searchResults.count : 0
    }
    
    // сервис асинхронной загрузки картинки по url
    func loadImageAsync(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        
        guard let url = URL(string: searchResults[indexPath.row].imageURLString) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("run service.loadImageAsync - \(indexPath)")
            
            guard let contentOfURL = try? Data(contentsOf: url) else {
                print("Ошибка, не удалось загрузить изображение")
                completion(nil)
                return
            }
            // если загрузка изображения произошла, то заносим в словарь
            let loadedImage = UIImage(data: contentOfURL)!.scalePreservingAspectRatio(targetSize: CGSize(width: 100, height: 100))
            self.resizeImagesCache[indexPath] = loadedImage
            completion(loadedImage)
            
            print("ended service.loadImageAsync - \(indexPath)")
        }
    }
    
    // сервис API запроса
    func makeSearch(searchExpression: String?, completion: @escaping () -> Void) {
        // Обнуляем результаты предыдущего запроса
        searchResults = []
        resizeImagesCache = [:]
        
        guard let searchExpression = searchExpression,
              let url = URL(string: urlString + searchExpression) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else { return }
            guard let networkModel = self.parseDecoder(data: data) else { return }
            // преобразование networkModel в массив структур ResultForDisplay
            self.searchResults = Array(networkModel.results.map{ResultForDisplay(networkModel: $0)})
            print(self.searchResults)
            completion()
        }
        
        print("Запрос с параметром - \(searchExpression)")
        task.resume()
    }
    
    // сервис декодирования JSON в network model
    private func parseDecoder(data: Data) -> SearchResults? {
        guard let decode = try? JSONDecoder().decode(SearchResults.self, from: data) else {
            print("Ошибка декодирования - \(data)")
            return nil
        }
        return decode
    }
    
    func getSearchResult(for indexPath: IndexPath) -> ResultForDisplay? {
        searchResults.isEmpty ? nil : searchResults[indexPath.row]
    }
    
    func getImage(for indexPath: IndexPath) -> UIImage? {
        resizeImagesCache[indexPath]
    }
}

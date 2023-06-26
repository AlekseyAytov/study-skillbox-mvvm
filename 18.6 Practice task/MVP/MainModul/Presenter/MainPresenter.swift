//
//  MainPresenter.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 6/22/23.
//

import UIKit


protocol MainViewPresenterProtocol {
    func getNumberOfRows(for section: Int) -> Int
    func makeSearch(searchExpression: String?, completion: ((Bool) -> Void)?)
    func getSearchResult(for indexPath: IndexPath) -> ResultForDisplay?
    func getOrLoadImage(for indexPath: IndexPath, completion: (() -> Void)?) -> UIImage?
}


class MainViewPresenter: MainViewPresenterProtocol {
    
    private var urlString = "https://imdb-api.com/API/Search/k_ngzy512q/"
    // результаты поиска
    private var searchResults: [ResultForDisplay] = []
    // словарь для хранения изображений с измененными размерами
    private var resizeImagesCache: [IndexPath: UIImage] = [:]
        
    func getNumberOfRows(for section: Int) -> Int {
        (section == 0) ? searchResults.count : 0
    }
    
    // сервис API запроса
    func makeSearch(searchExpression: String?, completion: ((Bool) -> Void)?) {
        // Обнуляем результаты предыдущего запроса
        searchResults = []
        resizeImagesCache = [:]
        
        guard let searchExpression = searchExpression,
              let url = URL(string: urlString + searchExpression) else {
            completion?(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else {
                completion?(false)
                return
            }
            guard let networkModel = self.parseDecoder(data: data) else {
                completion?(false)
                return
            }
            // преобразование networkModel в массив структур ResultForDisplay
            self.searchResults = Array(networkModel.results.map{ResultForDisplay(networkModel: $0)})
            print(self.searchResults)
            completion?(true)
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
    
    // метод возвращает картинку по ключу indexPath либо асинхронно её загружает и сохраняет в словарь,
    // при повторном использованиии метода возвращает загруженную картинку
    func getOrLoadImage(for indexPath: IndexPath, completion: (() -> Void)?) -> UIImage? {
        if let image = resizeImagesCache[indexPath] {
            return image
        } else {
            guard let url = URL(string: searchResults[indexPath.row].imageURLString) else {
                setPlaceholderImage(for: indexPath)
                completion?()
                return nil
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                print("run service.loadImageAsync - \(indexPath)")
                
                guard let contentOfURL = try? Data(contentsOf: url) else {
                    print("Ошибка, не удалось загрузить изображение")
                    self.setPlaceholderImage(for: indexPath)
                    completion?()
                    return
                }
                // если загрузка изображения произошла, то заносим в словарь
                guard let loadedImage = UIImage(data: contentOfURL)?.scalePreservingAspectRatio(targetSize: CGSize(width: 100, height: 100)) else {
                    self.setPlaceholderImage(for: indexPath)
                    completion?()
                    return
                }
                self.resizeImagesCache[indexPath] = loadedImage
                completion?()
                print("ended service.loadImageAsync - \(indexPath)")
            }
        }
        return nil
    }
    
    private func setPlaceholderImage(for indexPath: IndexPath) {
        self.resizeImagesCache[indexPath] = UIImage(named: "No-Image-Placeholder")
    }
}
